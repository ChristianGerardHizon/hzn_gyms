# Bacolod branch stock vs sales check (2026-08-07)

Branch: **Bacolod Branch** (`bryvfom289gaqb8`)

## Verdict

No outstanding Bacolod stock that still needs reconciliation from the POS non-lot bug.

The only `trackStock` products with non-voided sales were already corrected in batch `recon-2026-08-06`:

| Product | Sold (non-void) | Before → After | Adjustment |
|---------|-----------------|----------------|------------|
| pandanon 500ml | 8 (+1 voided) | 106 → 98 | `kuwgbl3n821340t` |
| pandanon 1000ml | 9 | 41 → 32 | `2dbwgerf0mpqj9h` |
| GYM TOWEL | 1 | 36 → 35 | `o95jlstskw3hexp` |

All sale lines had empty `productLot` (non-lot path). No cross-branch product lines.

## Other Bacolod trackStock products

`tshirt 220/250/290`, `CREATINE`, `Whey Core Protein`, `Mass Extreme Gainer`, `ISO Definition` — **0 product sales**, quantities unchanged. Nothing to fix.

## WATER (not a stock bug)

Many Bacolod WATER sales exist, but the product has `trackStock=false`, so quantity is not expected to move. Current qty stays 125 by design.

## Raw export

See [`stock_reconciliation_bacolod_2026-08-07.csv`](stock_reconciliation_bacolod_2026-08-07.csv).

**Do not re-apply** sold-qty subtraction on the three reconciled products — that would double-correct. New sales after the POS fix deploys should decrement automatically.
