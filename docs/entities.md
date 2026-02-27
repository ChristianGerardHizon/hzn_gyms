# Project Entities

This document contains all entities (domain models) in the project with their fields, relationships, and collection names.

---

## Entity Overview

| Domain | Entity | Collection | Description |
|--------|--------|------------|-------------|
| Organization | User | `users` | System users (all types) |
| Organization | UserRole | `userRoles` | Role definitions and permissions |
| Organization | Branch | `branches` | Business branches/locations |
| Member | Member | `members` | Gym members |
| Member | MemberCard | `memberCards` | Physical ID cards for members |
| Membership | Membership | `memberships` | Membership plan templates |
| Membership | MembershipAddOn | `membershipAddOns` | Add-on options for membership plans |
| Membership | MemberMembership | `memberMemberships` | Member subscriptions |
| Membership | MemberMembershipAddOn | `memberMembershipAddOns` | Selected add-ons on purchased memberships |
| Check-In | CheckIn | `checkIns` | Member check-in records |
| Product | Product | `products` | Products/inventory items |
| Product | ProductCategory | `productCategories` | Product categories (hierarchical) |
| Product | ProductStock | `productStocks` | Stock lots with expiration |
| Product | ProductAdjustment | `productAdjustments` | Stock adjustments |
| POS | PosGroup | `posGroups` | Cashier layout groups |
| POS | PosGroupItem | `posGroupItems` | Products in POS groups |
| Sales | Sale | `sales` | Transaction records |
| Sales | SaleItem | `saleItems` | Product items in transactions |
| Sales | Payment | `payments` | Payment records |
| Sales | Cart / CartItem | `carts` / `cartItems` | Shopping cart (temporary) |

---

## Entity Relationship Diagram

```
                          ┌────────────┐
                          │  UserRole  │
                          └─────┬──────┘
                                │
                                ▼
                          ┌────────────┐
                          │    User    │
                          └─────┬──────┘
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                  │
              ▼                 ▼                  ▼
        ┌───────────┐    ┌───────────┐     ┌───────────┐
        │  Branch   │    │  Member   │     │   Sale    │
        └─────┬─────┘    └─────┬─────┘     └─────┬─────┘
              │                │                  │
              │      ┌────────┼────────┐    ┌────┴────┐
              │      │        │        │    │         │
              ▼      ▼        ▼        ▼    ▼         ▼
         Products  Member   CheckIn  Sales  SaleItem  Payment
                   Membership


        ┌─────────────────┐          ┌─────────────┐
        │   Membership    │◄─────────│   Member     │
        │   (plan)        │          │  Membership  │
        └─────────────────┘          └──────────────┘


        ┌─────────────────┐          ┌─────────────┐          ┌─────────────────┐
        │ ProductCategory │◄─────────│   Product   │─────────►│  ProductStock   │
        │   (hierarchy)   │          └──────┬──────┘          └────────┬────────┘
        └─────────────────┘                 │                          │
                                            ▼                          ▼
                                   ┌────────────────┐         ┌────────────────┐
                                   │   PosGroup     │         │ ProductAdjust  │
                                   │   PosGroupItem │         └────────────────┘
                                   └────────────────┘
```

---

## Organization Domain

### User

All system users with role-based access.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | User name |
| `email` | String | Yes | Email address |
| `avatar` | String | No | Avatar filename |
| `verified` | bool | Yes | Email verification status |
| `role` | String (FK) | Yes | FK to UserRole |
| `branch` | String (FK) | No | FK to Branch |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `users`

**Relationships:**
- `role` -> UserRole
- `branch` -> Branch (optional)

---

### UserRole

Role definitions with permissions.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Role name (e.g., "Admin", "Staff", "Cashier") |
| `description` | String | No | Role description |
| `permissions` | List\<String> | Yes | List of permission keys |
| `isSystem` | bool | Yes | Whether this is a system-defined role |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `userRoles`

---

### Branch

Business branches or locations.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Branch name |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `branches`

**Referenced by:** User, Member, Product, Sale, MemberMembership, CheckIn

---

## Member Domain

### Member

Gym members.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Member name |
| `mobileNumber` | String | No | Phone/mobile number |
| `dateOfBirth` | DateTime | No | Date of birth |
| `address` | String | No | Address |
| `sex` | String | No | Gender (male/female/other) |
| `remarks` | String | No | Notes |
| `addedBy` | String (FK) | No | FK to User who registered |
| `rfidCardId` | String | No | RFID card ID for check-in |
| `email` | String | No | Email address |
| `emergencyContact` | String | No | Emergency contact info |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `members`

**Referenced by:** MemberMembership, CheckIn, Sale

---

## Membership Domain

### Membership

Membership plan templates.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Plan name (e.g., "Monthly", "Annual") |
| `description` | String | No | Plan description |
| `durationDays` | int | Yes | Duration in days (30, 90, 365, etc.) |
| `price` | num | Yes | Price in PHP |
| `branch` | String (FK) | No | FK to Branch |
| `isActive` | bool | Yes | Whether plan is currently offered |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `memberships`

**Referenced by:** MemberMembership, MembershipAddOn

---

### MembershipAddOn

Add-on options for membership plans (e.g., "Treadmill Access", "Coach/Instructor", "Pool Access").

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `membership` | String (FK) | Yes | FK to Membership plan |
| `name` | String | Yes | Add-on name |
| `description` | String | No | Add-on description |
| `price` | num | Yes | Price in PHP |
| `isActive` | bool | No | Whether currently offered |
| `isDeleted` | bool | No | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `membershipAddOns`

**Relationships:**
- `membership` -> Membership (cascadeDelete)

**Referenced by:** MemberMembershipAddOn

---

### MemberMembership

Member subscriptions linking members to membership plans.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `member` | String (FK) | Yes | FK to Member |
| `membership` | String (FK) | Yes | FK to Membership plan |
| `startDate` | DateTime | Yes | Start date |
| `endDate` | DateTime | Yes | Expiry date |
| `status` | MemberMembershipStatus | Yes | Subscription status |
| `branch` | String (FK) | Yes | FK to Branch |
| `saleId` | String (FK) | No | FK to Sale (if purchased through POS) |
| `soldBy` | String (FK) | No | FK to User who sold |
| `notes` | String | No | Optional notes |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `memberMemberships`

**Relationships:**
- `member` -> Member
- `membership` -> Membership
- `branch` -> Branch

**Enum:** `MemberMembershipStatus { active, expired, cancelled, voided }`

**Computed Properties:**
- `isCurrentlyActive` - Status is active and current date is within start/end range
- `isExpired` - Current date is past end date
- `daysRemaining` - Days until expiry (0 if expired)

---

### MemberMembershipAddOn

Records of add-ons selected by a member when purchasing a membership. Stores snapshots of add-on name and price at time of purchase.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `memberMembership` | String (FK) | Yes | FK to MemberMembership |
| `membershipAddOn` | String (FK) | Yes | FK to MembershipAddOn |
| `addOnName` | String | Yes | Snapshot of add-on name at purchase |
| `price` | num | Yes | Snapshot of add-on price at purchase (PHP) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `memberMembershipAddOns`

**Relationships:**
- `memberMembership` -> MemberMembership (cascadeDelete)
- `membershipAddOn` -> MembershipAddOn

---

## Member Card Domain

### MemberCard

Physical ID cards linked to gym members for RFID/barcode check-in. Members can have multiple cards.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `member` | String (FK) | Yes | FK to Member |
| `cardValue` | String | Yes | Unique identifier on the physical card |
| `label` | String | No | Human-readable name (e.g., "Primary Card") |
| `status` | MemberCardStatus | Yes | Current card status |
| `deactivatedAt` | DateTime | No | When card was deactivated/reported lost |
| `notes` | String | No | Optional notes |
| `created` | DateTime | No | Creation timestamp (also serves as issued date) |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `memberCards`

**Relationships:**
- `member` -> Member (cascadeDelete)

**Enum:** `MemberCardStatus { active, lost, deactivated }`

**Indexes:**
- Unique index on `cardValue`
- Index on `member`

---

## Check-In Domain

### CheckIn

Member check-in records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `member` | String (FK) | Yes | FK to Member |
| `branch` | String (FK) | No | FK to Branch |
| `checkInTime` | DateTime | Yes | Check-in timestamp |
| `method` | CheckInMethod | Yes | How they checked in |
| `checkedInBy` | String (FK) | No | FK to User (for manual) |
| `memberMembership` | String (FK) | No | FK to active MemberMembership |
| `notes` | String | No | Optional notes |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `checkIns`

**Relationships:**
- `member` -> Member
- `branch` -> Branch (optional)

**Enum:** `CheckInMethod { manual, rfid }`

---

## Product Domain

### Product

Products and inventory items.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Product name |
| `description` | String | No | Product description |
| `category` | String (FK) | No | FK to ProductCategory |
| `image` | String | No | Product image filename |
| `branch` | String (FK) | No | FK to Branch |
| `stockThreshold` | num | No | Low stock warning threshold |
| `price` | num | Yes | Product price |
| `forSale` | bool | Yes | Whether product is for sale |
| `quantity` | num | No | Current quantity |
| `expiration` | DateTime | No | Expiration date |
| `trackByLot` | bool | Yes | Track inventory by lot numbers |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `products`

---

### ProductCategory

Product categories with hierarchy support.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Category name |
| `parent` | String (FK) | No | FK to ProductCategory (for hierarchy) |
| `isDeleted` | bool | Yes | Soft delete flag |

**Collection:** `productCategories`

---

### ProductStock

Stock lots with expiration tracking.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `product` | String (FK) | Yes | FK to Product |
| `lotNo` | String | No | Lot/batch number |
| `expiration` | DateTime | No | Expiration date |
| `notes` | String | No | Stock notes |
| `quantity` | int | No | Quantity in stock |
| `isDisposed` | bool | Yes | Whether stock has been disposed |
| `isDeleted` | bool | Yes | Soft delete flag |

**Collection:** `productStocks`

---

### ProductAdjustment

Stock adjustment records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `reason` | String | No | Reason for adjustment |
| `type` | ProductAdjustmentType | Yes | Type of adjustment |
| `oldValue` | num | Yes | Previous value |
| `newValue` | num | Yes | New value |
| `product` | String (FK) | Conditional | FK to Product (if type=product) |
| `productStock` | String (FK) | Conditional | FK to ProductStock (if type=productStock) |

**Collection:** `productAdjustments`

**Enum:** `ProductAdjustmentType { product, productStock }`

---

## Sales Domain

### Sale

Transaction records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `receiptNumber` | String | Yes | Generated receipt number |
| `status` | SaleStatus | Yes | Sale status |
| `total` | num | Yes | Total amount |
| `member` | String (FK) | No | FK to Member |
| `branch` | String (FK) | No | FK to Branch |
| `soldBy` | String (FK) | No | FK to User |
| `notes` | String | No | Sale notes |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `sales`

**Enum:** `SaleStatus { pending, completed, refunded, voided }`

---

## POS Domain

### PosGroup / PosGroupItem

Cashier layout groups per branch.

**Collection:** `posGroups`, `posGroupItems`

---

## View Collections (SQL Views)

| View | Description |
|------|-------------|
| `vw_inventory_status` | Aggregated inventory status |
| `vw_sales_daily_summary` | Daily sales totals |
| `vw_top_selling_products` | Top selling products |
| `vw_todays_sales` | Today's sales list |
| `vw_lot_quantity_totals` | Lot quantity aggregates |
| `vw_low_stock_products` | Low stock alerts |
| `vw_low_stock_lot_products` | Low stock lot-tracked products |
| `vw_expired_lots` | Expired lot alerts |
| `vw_near_expiration_lots` | Near-expiration lot alerts |
| `vw_pos_search_items` | POS search index |

---

## Summary

**Total Collections:** 20 (+ 9 view collections)

**Enums:**

| Enum | Values |
|------|--------|
| MemberCardStatus | active, lost, deactivated |
| MemberMembershipStatus | active, expired, cancelled, voided |
| CheckInMethod | manual, rfid |
| SaleStatus | pending, completed, refunded, voided |
| ProductStatus | inStock, outOfStock, lowStock, noThreshold |
| ProductAdjustmentType | product, productStock |
| PaymentMethod | cash, card, check, etc. |
