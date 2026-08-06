# Prod stock reconciliation (2026-08-06)

Generated after diagnosing missing POS stock decrements for non-lot `trackStock` products.

## Applied corrections (2026-08-06)

Safe rows only (`verify_with_physical_count` where system qty ≠ hint and live qty still matched the snapshot).  
`DO_NOT_AUTO_CORRECT` products were **not** changed (need physical count).

| Product | Previous qty | New qty | Sold subtracted | Adjustment ID |
|---------|--------------|---------|-----------------|---------------|
| pandanon 500ml | 106 | 98 | 8 | `kuwgbl3n821340t` |
| pandanon 1000ml | 41 | 32 | 9 | `2dbwgerf0mpqj9h` |
| GYM TOWEL | 36 | 35 | 1 | `o95jlstskw3hexp` |

Full revert log: [`stock_reconciliation_applied_2026-08-06.json`](stock_reconciliation_applied_2026-08-06.json) / [`.csv`](stock_reconciliation_applied_2026-08-06.csv)

### How to revert

For each applied row:

1. `PATCH /api/collections/products/records/{product_id}` with `{ "quantity": <previous_quantity> }`
2. `POST /api/collections/productAdjustments/records` with:
   - `type`: `product`
   - `oldValue`: current (new) qty
   - `newValue`: previous qty
   - `product`: product id
   - `reason`: `Revert recon-2026-08-06`

Keep the original adjustment rows for audit; add a reverse adjustment.

## Not applied (physical count required)

Rows flagged `DO_NOT_AUTO_CORRECT_physical_count_required` in [`stock_reconciliation_prod_2026-08-06.csv`](stock_reconciliation_prod_2026-08-06.csv) — sold ≫ system qty (prior manual edits/restocks). Count on-hand, then correct via Stock Adjustment UI.

## Going forward

After the POS non-lot stock decrement fix is deployed, cashier sales decrement `products.quantity` automatically. Manual Stock Adjustments remain the audit trail for corrections like this batch.
