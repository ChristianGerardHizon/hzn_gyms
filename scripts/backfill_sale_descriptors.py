#!/usr/bin/env python3
"""Backfill sales.descriptor from saleItems + customerName.

Usage:
  python3 -u scripts/backfill_sale_descriptors.py

Reads PB_LOCAL_* from .env (or PB_URL / PB_EMAIL / PB_PASSWORD overrides).
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".env"
PAGE_SIZE = 200
ITEM_CHUNK = 40
WORKERS = 16


def log(msg: str) -> None:
    print(msg, flush=True)


def load_env() -> dict[str, str]:
    values: dict[str, str] = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"').strip("'")
    return values


def request_json(
    method: str,
    url: str,
    token: str | None = None,
    body: dict | None = None,
):
    data = None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = token
    if body is not None:
        data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            raw = resp.read().decode("utf-8")
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} -> {exc.code}: {detail}") from exc


def build_descriptor(
    items: list[dict],
    customer_name: str | None,
    *,
    is_walk_in: bool = False,
) -> str:
    name = (customer_name or "").strip()
    if not items:
        if name:
            return name
        return "Walk-in" if is_walk_in else "Sale"

    membership = next((i for i in items if i.get("itemType") == "membership"), None)
    if membership is not None:
        plan_name = (membership.get("productName") or "").strip()
        add_on_count = sum(1 for i in items if i.get("itemType") == "addon")
        if is_walk_in:
            parts = ["Walk-in"]
            if name and name != "Walk-in":
                parts.append(name)
            if plan_name:
                parts.append(plan_name)
            base = " · ".join(parts)
        elif name and plan_name:
            base = f"{name} · {plan_name}"
        elif plan_name:
            base = plan_name
        else:
            base = name or "Membership"
        if add_on_count <= 0:
            return base
        suffix = "add-on" if add_on_count == 1 else "add-ons"
        return f"{base} +{add_on_count} {suffix}"

    product_items = [
        i
        for i in items
        if not i.get("itemType") or i.get("itemType") in ("product", "")
    ]
    named = product_items or items
    first = (named[0].get("productName") or "").strip()
    if len(named) == 1:
        return first or "Sale"
    label = first or "Item"
    return f"{label} +{len(named) - 1} more"


def fetch_items_for_sales(base: str, token: str, sale_ids: list[str]) -> dict[str, list[dict]]:
    items_by_sale: dict[str, list[dict]] = {sid: [] for sid in sale_ids}
    for i in range(0, len(sale_ids), ITEM_CHUNK):
        chunk = sale_ids[i : i + ITEM_CHUNK]
        or_filter = " || ".join(f'sale="{sid}"' for sid in chunk)
        item_filter = urllib.parse.quote(f"({or_filter})")
        page = 1
        while True:
            item_url = (
                f"{base}api/collections/saleItems/records"
                f"?page={page}&perPage=500"
                f"&filter={item_filter}"
                f"&fields=sale,productName,itemType"
                f"&skipTotal=1"
            )
            item_payload = request_json("GET", item_url, token=token)
            items = item_payload.get("items") or []
            for item in items:
                sale_id = item.get("sale")
                if sale_id in items_by_sale:
                    items_by_sale[sale_id].append(item)
            if len(items) < 500:
                break
            page += 1
    return items_by_sale


def main() -> int:
    env = load_env()
    base = (os.environ.get("PB_URL") or env.get("PB_LOCAL_URL") or "").rstrip("/") + "/"
    email = os.environ.get("PB_EMAIL") or env.get("PB_LOCAL_EMAIL")
    password = os.environ.get("PB_PASSWORD") or env.get("PB_LOCAL_PASSWORD")
    if not base or not email or not password:
        print("Missing PocketBase URL/credentials", file=sys.stderr)
        return 1

    log(f"Auth against {base} ...")
    auth = request_json(
        "POST",
        f"{base}api/collections/_superusers/auth-with-password",
        body={"identity": email, "password": password},
    )
    token = auth.get("token")
    if not token:
        print(f"Auth failed: {auth}", file=sys.stderr)
        return 1
    log("Authenticated.")

    updated = 0
    skipped = 0
    failed = 0
    page = 1

    # Walk all sales newest-first; skip rows that already have a descriptor.
    # Avoids expensive empty-descriptor COUNT queries on 100k+ rows.
    while True:
        list_url = (
            f"{base}api/collections/sales/records"
            f"?page={page}&perPage={PAGE_SIZE}&sort=-created"
            f"&fields=id,customerName,descriptor,member"
            f"&skipTotal=1"
        )
        log(f"Fetching sales page {page} ...")
        payload = request_json("GET", list_url, token=token)
        sales = payload.get("items") or []
        if not sales:
            break

        need = [
            s
            for s in sales
            if not (s.get("descriptor") or "").strip()
        ]
        skipped += len(sales) - len(need)
        log(
            f"page {page}: {len(sales)} sales, "
            f"{len(need)} need descriptor "
            f"(running totals updated={updated} skipped={skipped} failed={failed})"
        )

        if need:
            sale_ids = [s["id"] for s in need]
            items_by_sale = fetch_items_for_sales(base, token, sale_ids)

            def patch_one(sale: dict) -> str:
                member = (sale.get("member") or "").strip()
                descriptor = build_descriptor(
                    items_by_sale.get(sale["id"], []),
                    sale.get("customerName"),
                    is_walk_in=not bool(member),
                )
                request_json(
                    "PATCH",
                    f"{base}api/collections/sales/records/{sale['id']}",
                    token=token,
                    body={"descriptor": descriptor},
                )
                return sale["id"]

            with ThreadPoolExecutor(max_workers=WORKERS) as pool:
                futures = [pool.submit(patch_one, sale) for sale in need]
                for fut in as_completed(futures):
                    try:
                        fut.result()
                        updated += 1
                    except Exception as exc:  # noqa: BLE001
                        failed += 1
                        print(f"  failed: {exc}", file=sys.stderr, flush=True)

            log(
                f"page {page} done: updated={updated} skipped={skipped} failed={failed}"
            )

        if len(sales) < PAGE_SIZE:
            break
        page += 1

    log(f"Done. updated={updated} skipped={skipped} failed={failed}")
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
