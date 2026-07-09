# Offline Mode Rules

Status: proposed / not yet implemented. This doc defines rules for offline-first behavior before any code is written.

## Goals

Offline support is scoped to a small set of high-value flows (member lookup, check-in, quick sale, member/membership creation). Not every collection needs offline read/write — pick the flows that matter, keep the rest online-only.

## Core Architecture

### Local-first writes
- Every offline mutation writes to local DB (Drift/Isar) first, UI updates optimistically.
- Rollback UI state if sync later fails permanently (not just retried).

### Outbox pattern
- Single generic `outbox` table, not one table per feature. Feature-specific tables duplicate sync logic for no benefit; a generic table scales to new features with zero new sync code.
- Schema (conceptual):
  ```
  outbox(
    id,              // uuid, generated client-side
    entityType,      // "member" | "membership" | "sale" | ...
    operation,       // create | update | void
    payload,         // json
    clientRecordId,  // matches local record's id
    dependsOnId,     // nullable, points to another outbox entry
    status,          // pending | synced | failed | conflict
    createdAt,
    attempts,
    lastError
  )
  ```
- Sync worker drains outbox FIFO, respects `dependsOnId` ordering (e.g. membership entry won't send until its member entry is `synced`).
- **Use client-generated UUIDs as the real PocketBase record id at creation time** (PB allows custom id on create). Avoids local-id → server-id remapping entirely.

### Sync status tracking
- Every offline-created/edited local record carries a `_syncStatus` (pending/synced/conflict/error) in the local DB layer only — not part of the PocketBase schema.
- UI shows an explicit offline banner + pending-sync count. Never silently present unsynced data as fully synced.

### Conflict resolution
- Money-related records (sales, payments, void transactions): no silent last-write-wins. Flag conflict for manual staff review.
- Non-critical fields (notes, tags, misc member info): last-write-wins is fine, compare `updated` timestamps.

### Auth
- Cache last valid auth token. Allow read access if token is expired-but-recent. Block writes if token has been dead too long (security boundary, exact threshold TBD).

## Rule: when is a write allowed offline?

| Condition | Offline allowed? |
|---|---|
| No shared/limited resource (e.g. plain record create) | Yes, unrestricted |
| Parent-child dependency only (e.g. membership depends on member existing) | Yes — enforce via `dependsOnId` ordering in outbox, not a block |
| Shared-resource race possible (capacity caps, stock counts) | Yes, but soft: queue optimistically, flag "pending capacity/stock check," reconcile server-side on sync, alert staff if oversold/oversubscribed |
| Involves money finalization (payment, sale checkout) | Yes, queue it, but mark "unconfirmed" in UI until synced |

Cascading failure is not a reason to block a feature. Member and membership are independent outbox entries connected by `dependsOnId` — if membership sync fails after member synced, the member record is unaffected and membership retries independently.

## Feature Matrix

| Feature | Offline read | Offline create | Offline update | Notes |
|---|---|---|---|---|
| Member lookup / list | Yes | — | — | Cache-first, background refresh when online |
| Member details | Yes | — | — | |
| Member creation | Yes | Yes | Yes | No shared resource, client UUID, unrestricted |
| Membership creation (no capacity cap, e.g. standard plan) | Yes | Yes | Yes | Depends on member outbox entry via `dependsOnId` |
| Membership creation (capacity-limited, e.g. class/slot cap) | Yes | Yes (soft) | Yes | Queued optimistically; flagged pending-capacity; reconciled + alerted on sync if oversold |
| Check-in | Yes | Yes | — | High-value flow, no shared resource, safe offline |
| Quick sale / POS | Yes (catalog) | Yes (soft, if stock uncertain) | — | Sale queued; stock finalized server-side on sync; negative-stock alert if oversold |
| Payment / sale finalization | Yes (view) | Yes, marked "unconfirmed" until synced | — | No silent conflict resolution — flag for manual review if conflicting |
| Product/membership catalog | Yes | — | — | Cache-first, read-only offline |
| Schedules / classes | Yes | — | — | Cache-first, read-only offline |
| Everything else (reports, admin settings, etc.) | No | No | No | Online-only, out of scope for offline-first |

## Explicitly out of scope for v1

- Full bidirectional sync across all collections.
- Automatic conflict auto-resolution for money-related records.
- Offline support for admin/reporting features.