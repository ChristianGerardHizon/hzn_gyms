# Ebe Gym - Application Overview

A comprehensive Flutter multi-platform gym management system supporting Android, iOS, macOS, Linux, Windows, and Web.

---

## Table of Contents

1. [Features](#features)
2. [Core Functionality](#core-functionality)
3. [Domain Models](#domain-models)
4. [Key Screens](#key-screens)
5. [Integrations](#integrations)
6. [Navigation Structure](#navigation-structure)
7. [Architecture Patterns](#architecture-patterns)
8. [Project Structure](#project-structure)
9. [Technology Stack](#technology-stack)

---

## Features

### Primary Features (Main Navigation)

#### Dashboard (`/`)
Home screen with gym metrics and quick actions.

- Responsive layout (single column mobile, single-pane tablet)
- KPI summary cards: Today's Sales, Today's Check-ins, Active Members, New Members — tap any card for a breakdown dialog (aggregate chips + item list)
- Quick action buttons: Check-In, Cashier, Walk-in, Renew, Search Member, New Member
- Search Member: cross-branch name/phone search with branch-activity chips; opens quick-view to renew or purchase at the current branch, or create a new member when no match
- Cashier opens the product POS as a dialog (same layout as `/cashier`; member optional at checkout)
- Walk-in opens a day-pass dialog (customer name + plan with **Membership not required** + optional add-ons); creates a sale only — no member or membership record
- Renew Membership: pick any member, then choose a plan for the current branch; if they still have an active membership, the new period defaults to the day after it ends (start date can be customized)
- Recent Transactions: collapsible preview of today's sales (up to 5); tap opens sale quick view; View All opens today's transactions dialog
- Members grid: tap a member for a quick-view dialog (details + membership summary, Renew / Purchase, Show full details)
- Expiring memberships section (memberships expiring within 7 days)
- Inventory alerts (out of stock, low stock below threshold, expiring products)
- Pull-to-refresh invalidates all dashboard data
- RFID keyboard-wedge listener (same as Check-In); NFC icon is green when active, red when inactive

#### Check-In (`/check-in`)
Member check-in system for tracking gym visits.

- **Features**:
  - Card scan input (RFID/barcode) for quick check-in via member cards
  - RFID keyboard-wedge on Check-In and Dashboard; auto-listens while the window is focused (NFC icon green = active, red = inactive)
  - Fullscreen "Not in focus" overlay when the Check-In window/app loses OS focus (RFID paused)
  - Today's check-ins update live across devices via PocketBase realtime subscription
  - Member search by name or mobile number
  - Active membership status display
  - Manual check-in with membership validation
  - Warning for members without active membership
  - Recent check-ins list for today
  - Success dialog with membership status
  - Audio chimes for check-in outcomes: success, near-expiry (≤7 days), and failure
  - Backward compatibility with legacy `rfidCardId` field on members
  - **Records** app-bar button opens nested Check-In Records (`/check-in/records`)
- **Key Models**: `CheckIn`, `CheckInMethod`
- **Controllers**:
  - `checkInController` - Today's check-ins list + realtime subscribe + manual/card check-in actions
  - `memberCheckIns` - Check-in history for a specific member

#### Check-In Records (`/check-in/records`)
Historical check-in log filtered by calendar date. Opened from Check-In (not a top-level nav item).

- **Features**:
  - Date picker with previous/next day and Today shortcuts
  - Lists members who checked in on the selected date (branch-scoped)
  - Shows check-in time and method (Manual / RFID)
  - Tap a record to open details (date, time, method, membership) with link to member profile
- **Controllers**:
  - `checkInRecordsDateController` - Selected calendar day
  - `checkInRecordsController` - Check-ins for the selected date + branch

#### Members (`/members`)
Member management with membership and check-in tracking.

- **Sub-features**:
  - Members list with search by name or phone
  - Member detail with info and tabbed sections
  - Create/edit member via dialog form; **live camera capture** on web and mobile (with upload fallback) for profile photos
- **Member Detail Sections**:
  - Overview: name, contact, DOB, sex, address, remarks, RFID
  - ID Cards: physical cards (RFID/barcode) with status management (add, deactivate, report lost, delete)
  - Memberships: active/expired memberships, purchase button
  - Check-ins: check-in history
  - Sales History: past product purchases
- **Key Models**: `Member`, `MemberCard`, `MemberCardStatus`
- **Master-Detail Layout**: Tablet shows list + detail side-by-side; mobile navigates between pages

#### Memberships (`/memberships`)
Membership plan management for gym subscriptions.

- **Sub-features**:
  - Membership plans list with search
  - Plan detail with duration, price, active/inactive status
  - Create/edit plans via form with top **Recurring | Walk-in** toggle (Walk-in hides description/duration/all-branches and fixes duration to 1 day)
  - **Add-ons per plan** (e.g., Treadmill Access, Coach/Instructor, Locker, Pool Access) — each with its own price, managed from the plan detail page
  - Purchase membership flow from member detail page with optional add-on selection — total cost = base price + selected add-ons; add-ons with extra days extend the end date (excludes walk-in plans)
  - Walk-in / day-pass sale from dashboard **Walk-in** quick action: customer name + walk-in plan + optional add-ons → sale only (no member membership)
  - Renew from dashboard Quick Action or member membership detail; if the member still has an active membership at the branch, the new period defaults to the day after that membership ends (start date is customizable)
- **Key Models**: `Membership`, `MembershipAddOn`, `MemberMembership`, `MemberMembershipAddOn`, `MemberMembershipStatus`
- **Master-Detail Layout**: Tablet shows list + detail side-by-side

#### Products (`/products`)
Inventory and product management with lot tracking.

- **Sub-features**:
  - Products list with categories
  - Stock lots with FEFO (First-Expire-First-Out) tracking
  - Stock adjustments with audit trail
  - Product detail Sales tab with recent purchase history
  - Hierarchical category organization
- **Key Models**: `Product`, `ProductCategory`, `ProductLot`, `ProductAdjustment`

---

### Secondary Features

#### Point of Sale / Cashier (`/cashier`)
Complete POS system for processing product sales.

- **Features**:
  - **Customizable Cashier Layout** (POS Groups): Create named groups of products per branch to define the cashier page layout. Groups display as scrollable sections with sticky headers. Falls back to default product grid when no groups are configured.
  - Responsive product grid (max-extent tiles) with denser cards and readable Out/Low stock chips
  - **Mobile**: full-width product pane + sticky cart bar; cart opens as a bottom sheet for review/checkout
  - **Tablet/Desktop**: side-by-side products + cart (shared `CashierBody` for `/cashier` and dashboard dialog)
  - Product grid with search and category filtering
  - Search dropdown overlay (grouped mode)
  - Shopping cart with product items
  - Lot selection with FEFO ordering for lot-tracked products
  - Variable price support for products
  - Multiple payment methods (cash, card, check, etc.)
  - Checkout creates the sale, then opens Record Payment before showing the receipt
  - **Walk-in / day pass**: Dashboard **Walk-in** sells plans marked **Membership not required** (name + plan + optional add-ons → sale only). Dashboard **Cashier** opens product POS in a dialog; checkout member remains optional
  - Receipt generation and printing
- **Components**:
  - `CashierBody` - Shared responsive products + cart layout
  - `CashierProductCard` - Shared product tile (flat + grouped modes)
  - `CashierCartBar` - Mobile sticky cart summary / bottom sheet
  - `ProductGrid` - Product selection (default mode)
  - `GroupedCashierView` - Scrollable grouped sections (grouped mode)
  - `CashierSearchDropdown` - Search overlay for grouped mode
  - `CartView` - Shopping cart
  - `CheckoutDialog` - Order summary, member, notes; then payment step
  - `RecordPaymentDialog` - Payment collection after checkout
  - `LotSelectionDialog` - FEFO lot selection
  - `ReceiptDialog` - Receipt display/print

#### Sales History (`/sales`)
View and manage completed transactions.

- Paginated sales history with search
- Sale status display (pending, completed, refunded, voided)
- Search fields dialog can toggle status filters (Paid, Voided, Awaiting Payment)
- Detailed sale view with items and payment info
- Reprint receipt from sale detail (thermal printer and/or PDF), same flow as checkout
- Refund/unrefund functionality with confirmation dialogs

#### Reports (`/reports`)
Tabbed analytics hub with period selector (Day / Week / Month / Year / All Time) and PDF export.

**Mental model — Sales vs Memberships (not duplicate features):**
- **Sales** = money ledger (receipts & payments). Product POS and membership purchases both create `Sale` records.
- **Memberships** = access/lifecycle (who can train, on which plan, until when). Plan catalog + subscriptions.
- Do **not** sum Sales revenue with Membership “plan value” — membership purchases already appear in Sales.

**Tabs:**
- Period selector: **Day** (single calendar date; lists each sale and opens sale detail on tap), **Week** (Mon–Sun From/To), **Month** (calendar months), **Year** (calendar years), **All Time** (years from 2019)
- Trend charts for Week / Month / Year / All Time (hidden on Day — use peak hours for attendance instead)
- **Sales** — cash collected, revenue by item type (product / membership / walk-in / add-on), payment methods, top selling items (products + memberships + guest day-pass), unpaid (AR), staff performance
- **Inventory** — stock status, low stock, expiration alerts, inventory value (via SQL views)
- **Members & Memberships** — new members, active base, renewals vs new, expiring soon, churn/lapse, plan mix; plan value sold (labeled separately from cash collected); excludes walk-in / guest (`memberNotRequired` / `walkIn`) plans
- **Attendance** — check-ins trend (non-Day), unique members, method mix; peak hours on Day only
- Export: **Print Report** menu with Print or Save as PDF; sales PDFs include a footer disclaimer that the document is not an invoice or official BIR record
---

### Organization/Admin Features

#### Organization (`/organization`)
3-panel tablet layout for managing organizational settings.

**Layout** (tablet):
- Panel 1 (80px): Navigation rail with icon + text labels
- Panel 2 (320px): List panel (users, roles, or branches)
- Panel 3 (expanded): Detail panel or empty state

**Modes:**
- **Users** (`/organization/users`) - User CRUD, role assignment, branch association
- **Roles** (`/organization/roles`) - Role and permission management (Admin, Staff, Cashier)
- **Branches** (`/organization/branches`) - Multi-location support with name, code (pill label), optional pill color preset, address, contact, operating hours, and cut-off time (only name + code required)

#### Profile (`/profile`)
Self-service account page for staff (and any user without `users.view`). Shows own profile and allows editing name/username only (no role/branch assignment). Change Password requires the current password plus a new password confirmation.

#### System Settings (`/system`)
3-panel tablet layout for system configuration.

**Modes:**
- **Product Categories** (`/system/product-categories`) - Hierarchical product categories
- **Cashier Layout** (`/system/cashier-groups`) - POS groups management per branch
- **Appearance** (`/system/appearance`) - Theme and default camera (available to all signed-in users)
- **Debug** (`/system/debug`) - Admin tools; simulate RFID check-in dialogs
- **Activity Log** (`/system/activity-log`) - Admin-only system-wide change history with summary list and field-level diffs

---

### Authentication (`/auth`)

- Splash screen
- Login page
- Password recovery
- Session management

---

## Core Functionality

Located in `/lib/src/core/`

### Routing (`/core/routing/`)
- GoRouter configuration with auth redirects
- Route files organized by domain
- Shell-based routing with nested subroutes

### PocketBase Integration (`/core/packages/pocketbase/`)
- `pocketbase_provider.dart` - Singleton instance
- `pocketbase_collections.dart` - Collection name constants
- `pb_filter.dart` - Query filter helpers
- `pb_expand.dart` - Relation expansion helpers

### Foundation (`/core/foundation/`)
- `failure.dart` - Standardized error handling
- `type_defs.dart` - Type aliases (`FutureEither<T>`, `Json`)
- `paginated_state.dart` - Pagination state management

### Shared Widgets (`/core/widgets/`)
- `mobile_bottom_nav.dart` - Bottom navigation (Dashboard, Check-In, Cashier, More)
- `mobile_drawer.dart` - Mobile drawer (all navigation items)
- `tablet_nav_rail.dart` - Tablet navigation rail
- `breadcrumb_nav.dart` - Breadcrumb navigation
- `cached_avatar.dart` - Avatar caching

### Utilities (`/core/utils/`)
- `breakpoints.dart` - Responsive breakpoints
- `currency_format.dart` - Money formatting (Philippine Peso)
- `date_utils.dart` - Date utilities

---

## Domain Models

### Collections across 7 Domains

#### Organization Domain (3 collections)
| Collection | Description |
|------------|-------------|
| `users` | System users (all types) |
| `userRoles` | Role definitions with permissions |
| `branches` | Business branches/locations |

#### Member Domain (1 collection)
| Collection | Description |
|------------|-------------|
| `members` | Gym members with contact info, RFID |

#### Member Card Domain (1 collection)
| Collection | Description |
|------------|-------------|
| `memberCards` | Physical ID cards linked to members for check-in |

#### Membership Domain (2 collections)
| Collection | Description |
|------------|-------------|
| `memberships` | Membership plan templates (Monthly, Annual, etc.) |
| `memberMemberships` | Member subscriptions linking members to plans |

#### Check-In Domain (1 collection)
| Collection | Description |
|------------|-------------|
| `checkIns` | Member check-in records |

#### Product Domain (5 collections)
| Collection | Description |
|------------|-------------|
| `products` | Products/inventory items |
| `productCategories` | Hierarchical categories |
| `productStocks` | Stock lots with expiration |
| `productLots` | Batch/lot numbers (FEFO tracking) |
| `productAdjustments` | Stock change audit trail |
| `activityLogs` | System-wide activity / change audit trail |

#### POS Domain (2 collections)
| Collection | Description |
|------------|-------------|
| `posGroups` | Named groups for cashier layout (per-branch) |
| `posGroupItems` | Many-to-many link between groups and products |

#### Sales Domain (3 collections)
| Collection | Description |
|------------|-------------|
| `sales` | Transaction records |
| `saleItems` | Product items in transaction |
| `payments` | Payment records per sale |

### Enums
- `MemberMembershipStatus` - active, expired, cancelled, voided
- `CheckInMethod` - manual, rfid
- `SaleStatus` - pending, completed, refunded, voided
- `ProductStatus` - inStock, outOfStock, lowStock, noThreshold
- `ProductAdjustmentType` - product, productStock
- `PaymentMethod` - cash, card, check, etc.

---

## Key Screens

### Authentication
- Splash Screen (`/`)
- Login Screen (`/login/user`)
- Password Recovery (`/recovery`)

### Main Navigation
- **Dashboard**: Home with KPIs, quick actions, recent transactions (View All dialog), inventory alerts
- **Check-In**: Member search, check-in with membership validation
- **Cashier/POS**: Product grid and checkout
- **Sales List**: Transaction history
- **Sale Detail**: Receipt view with refund/void sale actions and void individual payment from payment history
- **Products List**: Browse products with categories
- **Product Detail**: Stock, adjustments, and sales history
- **Members List**: Browse all members
- **Member Detail**: 4-tab interface (Overview, Memberships, Check-ins, Sales)
- **Memberships List**: Browse membership plans
- **Membership Detail**: Plan info with edit/delete
- **Reports**: Sales and inventory charts

### Organization (3-panel layout)
- Users Management (list/detail)
- Roles Management (list/detail)
- Branches Management (list/detail)

### System Settings (3-panel layout)
- Product Categories (list/detail)
- Cashier Layout / POS Groups (list/detail)

### Responsive Behavior
| Breakpoint | Layout |
|------------|--------|
| Mobile (< 600px) | Single-column, bottom nav, drawer |
| Tablet (600-900px) | Master-detail, navigation rail |
| Tablet Large (900-1200px) | Expanded rail, permanent side-by-side |
| Desktop (> 1200px) | Multi-panel, collapsible side menu |

---

## Integrations

### Backend: PocketBase
- **Type**: Open-source backend-as-a-service
- **Features**: Real-time database, authentication, file storage

### State Management: Hooks Riverpod
- `@riverpod` annotation for providers
- `AsyncNotifier` for async state
- `FutureEither<T>` pattern for error handling
- Family providers for parameterized state

### Serialization: dart_mappable
- `@MappableClass()` decorator
- Automatic JSON serialization
- DTOs for API-to-Domain mapping

### Forms: flutter_form_builder
- `FormBuilder` widget wrapper
- Specialized fields: TextField, Dropdown, DateTimePicker, ChoiceChips
- `FormBuilderValidators` for validation

### Navigation: GoRouter
- Type-safe routing with `@TypedGoRoute`
- Generated route extensions
- Auth redirect on route change

### Error Handling: fpdart
- `Either<Failure, T>` for error handling
- `TaskEither.tryCatch()` for async operations
- Centralized `Failure` class

---

## Navigation Structure

### Route Hierarchy

```
App Root (Shell)
├── Auth (non-shell)
│   ├── /splash
│   ├── /login/user
│   └── /recovery
│
└── Main Shell (with navigation)
    ├── / (Dashboard)
    ├── /check-in (Check-In)
    │   └── /check-in/records (Check-In Records)
    ├── /cashier (POS)
    ├── /sales (Sales History)
    │   └── /sales/:id (Sale Detail)
    ├── /products (Products)
    │   ├── /products/:id (Detail)
    │   └── /products/... (stocks, categories, adjustments)
    ├── /members (Members)
    │   ├── /members (List)
    │   └── /members/:id (Detail)
    ├── /memberships (Memberships)
    │   ├── /memberships (List)
    │   └── /memberships/:id (Detail)
    ├── /reports (Reports)
    ├── /organization (3-panel layout)
    │   ├── /organization/users
    │   │   └── /organization/users/:id
    │   ├── /organization/roles
    │   │   └── /organization/roles/:id
    │   └── /organization/branches
    │       └── /organization/branches/:id
    ├── /outbox (Offline sync queue)
    └── /system (3-panel layout)
        ├── /system/product-categories
        │   └── /system/product-categories/:id
        └── /system/cashier-groups
            └── /system/cashier-groups/:id
```

### Navigation Components

| Platform | Component | Description |
|----------|-----------|-------------|
| Mobile | Bottom Nav | 3 primary items + More (Dashboard, Check-In, Cashier, More) |
| Mobile | Drawer | Full menu (11 sections) |
| Tablet | Navigation Rail | Icons only (72px) |
| Tablet Large | Expanded Rail | Icons + labels (160px) |

### Navigation Index Mapping

| Index | Route | Label | Icon |
|-------|-------|-------|------|
| 0 | `/` | Dashboard | `dashboard` |
| 1 | `/check-in` | Check-In (Records via app-bar → `/check-in/records`) | `how_to_reg` |
| 2 | `/cashier` | Cashier | `point_of_sale` |
| 3 | `/sales` | Sales | `receipt_long` |
| 4 | `/products` | Products | `inventory_2` |
| 5 | `/members` | Members | `people` |
| 6 | `/memberships` | Memberships | `card_membership` |
| 7 | `/reports` | Reports | `analytics` |
| 8 | `/organization` or `/profile` | Organization (admin) / Profile (staff) | `business` / `person` |
| 9 | `/outbox` | Outbox | `cloud_sync` |
| 10 | `/system` | System | `settings` |

Destinations are filtered by role permissions. Staff typically see Dashboard through Memberships, Profile, and System (Appearance only).

**Sales permissions:** `sales.view` (sales history), `sales.create` (cashier/POS), `sales.void` (void sales and payments — assign explicitly under the Sales category in Roles).

**Product quantity:** `products.editQuantity` is required to change on-hand quantity in Edit Product. Admins (`system.admin`) have it by default; other roles should use Stock Adjustment unless this permission is assigned.

---

## Architecture Patterns

### Clean Architecture Layers
1. **Data Layer**: Repositories, DTOs, data sources
2. **Domain Layer**: Entities, business models
3. **Presentation Layer**: Pages, controllers, widgets

### State Management Pattern
- **List Controllers**: `@Riverpod(keepAlive: true)` for persistent lists
- **Single Entity Providers**: `@riverpod` for detail views
- **Family Providers**: Parameterized state with `build(String id)`

### Error Handling
- All operations return `FutureEither<T>`
- `TaskEither.tryCatch()` for async error handling
- Centralized `Failure` class

### DTO Pattern
```dart
// Create from PocketBase record
factory Dto.fromRecord(RecordModel record)

// Convert to domain entity
Entity toEntity()

// Static method for create payload
static Json toCreateJson(Entity entity)
```

### Naming Conventions
- **Plural** (`MembersController`) = manages list
- **Singular** (`memberProvider`) = manages single entity
- Pages: `*_page.dart`
- Sheets: `*_sheet.dart`
- Routes: `*.routes.dart`

---

## Project Structure

```
lib/src/
├── core/
│   ├── routing/           # GoRouter configuration
│   ├── pages/             # Shell page (app_root.dart)
│   ├── widgets/           # Shared UI components
│   ├── packages/          # External integrations
│   ├── foundation/        # Base classes (Failure, type defs)
│   ├── utils/             # Utilities
│   ├── extensions/        # Dart extensions
│   ├── hooks/             # Custom Flutter hooks
│   ├── constants/         # App constants
│   └── assets/i18n/       # Localization
│
└── features/
    ├── auth/              # Authentication
    ├── dashboard/         # Home/dashboard with KPIs
    ├── check_in/          # Member check-in
    ├── members/           # Member management
    ├── memberships/       # Membership plans & subscriptions
    ├── products/          # Inventory
    ├── quantity_units/    # Quantity unit master data
    ├── pos/               # Point of sale
    ├── sales/             # Sales history
    ├── reports/           # Sales & inventory reports
    ├── settings/          # System settings (categories, POS groups)
    ├── organization/      # Organization settings (3-panel layout)
    └── users/             # User management
        │
        └── [feature]/
            ├── data/
            │   ├── repositories/
            │   └── dto/
            ├── domain/
            └── presentation/
                ├── controllers/
                ├── pages/
                └── widgets/
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | PocketBase | BaaS, real-time database |
| Frontend | Flutter | Multi-platform UI |
| State Management | Riverpod + Hooks | Reactive state |
| Navigation | GoRouter | Type-safe routing |
| Forms | flutter_form_builder | Form handling |
| Serialization | dart_mappable | JSON mapping |
| Error Handling | fpdart | Functional Either/Task |
| Storage | flutter_secure_storage | Sensitive data |
| Localization | slang | i18n support |
| Code Gen | build_runner | Automatic generation |

---

## Recent Updates

| Date | Feature | Description |
|------|---------|-------------|
| Aug 7 | Cashier responsive redesign | Shared CashierBody for web/mobile; denser product tiles with Out/Low chips; mobile sticky cart bar + bottom sheet |
| Aug 7 | Member list row redesign | Members/picker rows use avatar + name/phone on the left and dense branch-activity chips on the right; empty activity uses a muted None chip |
| Aug 7 | Branch pill color presets | Branches can pick a pill color (teal/blue/indigo/purple/pink/orange/green/cyan); used on BranchCodePill and membership/member branch chips |
| Aug 7 | Branch detail + required fields | Branch detail shows all edit fields (incl. code); create/edit only requires Name and Code, with helper text for the pill code |
| Aug 7 | Sale list row redesign | Sales/dashboard rows use a three-zone layout (title+short subtitle, aligned branch pill, fixed amount + status) for better mobile readability |
| Aug 7 | Void stock adjustment | Product Adjustments tab can void manual adjustments (reverse qty + audit row); sale-linked rows stay sale-only; requires `inventory.adjust` |
| Aug 7 | Inventory alerts layout | Dashboard inventory alerts are side-by-side on tablet+ and single-column on mobile |
| Aug 7 | Inventory alerts split | Dashboard inventory alerts separate **Out of Stock** (qty ≤ 0) from **Low Stock** (qty below threshold) |
| Aug 7 | All-branches KPI pills | When viewing All branches, KPI breakdown dialogs and recent transactions show branch code pills (e.g. BCD); cards stay aggregate-only |
| Aug 7 | Branch codes for pills | Branches have a unique `code` (max 5, e.g. BCD/TAL) used on membership/member branch pills; full name stays on tooltip/admin |
| Aug 7 | Cross-branch membership purchase | Purchase/renew/new-member plan picker has **Show all memberships**; sale stays on the selling branch while check-in follows the plan's `validBranches` |
| Aug 7 | Out-of-stock continue warning | Cashier warns when adding an out-of-stock product; Continue still adds it, with optional Don't warn again until tomorrow |
| Aug 7 | Edit product quantity permission | New `products.editQuantity`; Edit Product quantity is read-only without it (admins included via `system.admin`). Prefer Stock Adjustment otherwise. |
| Aug 7 | POS sale stock adjustments | Checkout writes `productAdjustments` linked to the sale UUID; void restores qty and writes a reverse adjustment on the same sale |
| Aug 6 | POS non-lot stock decrement | Cashier checkout now decreases `products.quantity` for `trackStock` products without lots; void restores the same. Lot-tracked path unchanged. |
| Aug 6 | Sales status filters | Sales search fields dialog toggles Paid / Voided / Awaiting Payment; list refreshes with PocketBase status filter |
| Aug 6 | Sale receipt reprint | Sale detail Print Receipt opens the receipt dialog (thermal + PDF); reprint skips auto-print and includes line items |
| Aug 5 | Profile change password | Profile page can change own password with current + new + confirm (PocketBase `oldPassword`) |
| Aug 4 | Membership plan type labels | Plan form toggle and detail plan type use **Recurring \| Walk-in** (replacing Monthly / Standard); Walk-in still simplifies the form (1-day duration, no description / all-branches) |
| Aug 3 | Membership status colors | Expired/voided memberships and voided sales use red; almost expiring (≤7d) orange; active green; cancelled blueGrey |
| Aug 2 | Camera source preference | System → Appearance and member photo capture can select a camera device; last used camera is remembered on device |
| Aug 2 | Per-user Appearance theme | Light/dark/system preference is stored per signed-in user on device so shared tablets keep each user's theme |
| Aug 2 | Product sales history | Product detail has a Sales tab listing recent purchases (qty, price, receipt) with links to sale detail |
| Aug 2 | New Member card step | New Member wizard includes an optional Card step (scan or manual entry) between Photo and Membership; card is saved after member creation |
| Aug 2 | Member photo live capture | New Member wizard and Edit Member form support live camera preview with Capture button on web/mobile; upload from file remains available as fallback |
| Aug 2 | Dashboard Search Member | Quick action searches all branches, shows branch activity chips, routes to renew/purchase at current branch or new-member wizard when not found |
| Aug 5 | Membership purchase guards | Warn when buying an already-active exact plan; UUID `idempotencyKey` on sales / memberMemberships / payments so retries reuse the same records instead of duplicating |
| Aug 5 | Manila (+8) report views | Prod/local SQL views use fixed `+8 hours` (not server `localtime`/UTC) so overnight PH sales/check-ins land on the correct calendar day; `vw_todays_sales` uses Manila day UTC range |
| Aug 2 | Member branch activity labels | Members list shows colored chips for no active branch, single branch, multiple branches, or all branches—using the same check-in access rules as membership plans |
| Aug 1 | Calendar-correct membership duration | Plan duration is now `durationValue` + `durationUnit` (day/week/month/year) instead of a raw day count; end dates use calendar arithmetic (Aug 1 + 1 month = Sep 1) instead of a fixed day offset; existing plans backfilled |
| Aug 1 | Member name format | Member names saved as Title Case with collapsed whitespace (`Chloe Sy`); dashboard/members search tokenizes on spaces; cleanup script backfills via Admin API |
| Aug 1 | Add Card scan-first | Member Detail Add Card waits for RFID/keyboard-wedge scan, then Label/Notes; manual Card ID entry as fallback |
| Aug 1 | Check-In Records nested | Records moved under Check-In as app-bar button (`/check-in/records`); tap a record for details + member profile link; removed top-level nav item |
| Aug 1 | Today's Sales KPI speed | `vw_todays_sales` uses indexable local-day UTC range (not `DATE()`); sales indexes; All-branches sums all view rows; recent transactions list capped at 50 |
| Aug 1 | Activity log | Admin-only system-wide audit trail via PocketBase hooks; summary list + field diff detail under System → Activity Log |
| Aug 1 | Day/Week report speed | Day/Week sales skip all-history SQL views; period-scoped sales+payments+saleItems aggregation; Day attendance uses a single checkIns range query |
| Jul 15 | Check-In Records | New `/check-in-records` nav item lists who checked in on a selected date |
| Jul 15 | Sales report load speed | Split view-based KPIs from lean unpaid/staff/Day list fetch; charts paint first without expand on every sale |
| Jul 14 | Sales report print/PDF | Print Report menu (print or save PDF); sales PDF lists transactions and states it is not an invoice or BIR record |
| Jul 14 | Reports PDF-only + Day date | Generate PDF only (CSV removed); Day period uses a single date picker and lists that day's sales |
| Jul 14 | Sales Day list + range | Day period lists each sale and opens sale detail on tap |
| Jul 14 | Report view local dates | Sales/attendance SQL views bucket `created`/`checkInTime` with SQLite `localtime` so Day reports match Manila calendar (UTC midnight no longer hides overnight sales) |
| Jul 14 | Reports walk-in split | Membership report excludes walk-in / guest plans; Sales includes product + membership + walk-in (`itemType: walkIn`); Day period hides trend charts |
| Jul 14 | Add-on extra days | Membership add-ons can set `durationDays` (e.g. promo +3 months); purchase/renew end date includes plan days + selected add-on days |
| Jul 14 | Renew start date | Purchase/renew membership period defaults to day after current membership; start date can be customized via date picker |
| Jul 14 | Walk-in day pass | Plan flag `memberNotRequired`; dashboard **Walk-in** sells name + plan + add-ons as a sale only (no member membership); dashboard **Cashier** opens product POS dialog; plan list/detail show Walk-in badge; sales store/search Walk-in descriptors and customer labels |
| Jul 14 | Dashboard members layout | Members grid header menu: columns scale by screen (mobile 1–2, tablet 2–4, desktop 2–5) plus photo vs name-only; preference stored in Drift |
| Aug 2 | Camera in member forms | New/Edit Member photo step shows Camera dropdown (Automatic + devices); choice persists like Appearance |
| Aug 2 | Appearance for all users | Theme and default camera under System → Appearance available to every signed-in user (no longer gated by `settings.view`) |
| Jul 14 | Report period bucketing | Day/Week/Month/Year/All Time use calendar ranges; charts bucket daily/weekly/monthly/yearly via PB views |
| Jul 14 | Reports overhaul | Sales vs memberships framing; revenue-by-item-type; attendance tab; AR/renewals/staff; lazy tabs; PB date filters; PDF export |
| Jul 13 | Void payment | Sale detail payment history can void an individual payment/refund; sale paid status recalculates |
| Jul 13 | Member quick view | Tap a dashboard member card to open a details dialog with membership summary, Renew/Purchase shortcut, and Show full details |
| Jul 13 | Sale descriptors | Sales store a `descriptor` (item name or `Member · Plan`) shown as the list title with receipt short code underneath on sales history and dashboard |
| Jul 13 | Sale quick view | Tap a dashboard sale (recent transactions, today's list, sales KPI) to open a details dialog with items, payment status, Record payment when unpaid, and Show full details |
| Jul 13 | KPI breakdown dialogs | Tap dashboard KPIs to see aggregate chips (paid/unpaid, check-in method, plan counts) plus the underlying item list |
| Jul 13 | POS payment step | After completing a product sale checkout, opens Record Payment (same as memberships) before the receipt |
| Jul 14 | Today's transactions dialog | Dashboard Recent Transactions View All opens a dialog instead of `/todays-transactions` |
| Jul 13 | Recent transactions | Collapsible dashboard section under Quick Actions previewing today's sales; View All opens the full-day transactions dialog |
| Jul 13 | Dashboard renew | Quick Action to pick any member and renew with current-branch plans; new periods stack from the day after an still-active membership ends |
| Jul 13 | Multi-branch memberships | Plans have `validBranches` (1, many, or all); check-in gated by plan validity at current branch; members list/search are global; dashboard shows members whose membership is valid at the selected branch |
| Jul 12 | Renew exclude sales | Membership renew dialog can skip creating a sale/receipt (complimentary or admin renewals) |
| Jul 12 | Outbox nav | Added `/outbox` nav destination to inspect pending offline queue entries with payload details |
| Jul 12 | Offline outbox | Member create/update (with photo) and membership renew queue to Drift outbox; sync worker drains when online; pending count in app shell |
| Jul 11 | Domain migration | Staging/prod moved to `*.ebegym.hznsystems.com`; GitHub deploy secrets + fallback API URLs updated |
| Jul 11 | Member branch | Added `branch` FK on members; backfilled all to Talisay; members list + dashboard filter by selected branch |
| Aug 1 | Membership edit/cancel | Member membership detail can edit start/end dates or soft-cancel; gated by `memberships.edit` (admins bypass) |
| Aug 1 | Check-In audio chimes | Success, near-expiry (≤7 days), and failure sounds play on RFID/manual/card check-in outcomes |
| Aug 1 | Dashboard RFID | Dashboard hosts the same RFID listener as Check-In; NFC icon green when active, red when inactive |
| Aug 1 | Check-In realtime | Today's check-ins subscribe via PocketBase realtime so other devices update the list live |
| Aug 1 | Check-In focus overlay | RFID auto-listens on Check-In while focused; fullscreen "Not in focus" pauses scanning when the window blurs |
| Jul 15 | RFID Check-In only | Keyboard-wedge RFID listener scoped to Check-In page (not app-wide) to avoid typing lag |
| Jul 15 | System RFID debug | System → Debug simulates RFID check-in dialogs |
| Jul 15 | RFID all platforms | HID keyboard-wedge listener works on Android, desktop, and web while Check-In is open |
| Jul 11 | Global RFID listener | App-wide HID scanner check-in when logged in; success/error alerts (later scoped to Check-In page) |
| Jul 11 | Multi-branch users | Users keep a default `branch` plus `allowedBranches`; non-admins switch among allowed; admins can pick any branch or All |
| Jul 11 | PB Connectivity | Polls PocketBase `/api/health` to expose online/offline status; shown on AppVersionIndicator |
| Feb 17 | Member Cards | Physical ID cards (RFID/barcode) linked to members with status management; card scan check-in on check-in page with backward compatibility for legacy rfidCardId |
| Feb 16 | Membership Add-Ons | Add-on options per membership plan (e.g., Treadmill, Coach, Pool, promo length) with pricing and optional extra days, selectable during purchase |
| Feb 12 | Dashboard Adaptation | Replaced laundry metrics with gym KPIs (sales, check-ins, active members, new members), added expiring memberships section |
| Feb 12 | Check-In Feature | Created full check-in system with member search, membership validation, and recent check-ins list |
| Feb 12 | Memberships Feature | Created membership plans CRUD, member subscriptions, purchase flow from member detail page |
| Feb 12 | Members Feature | Adapted customers to members with gym-specific fields (RFID, memberships, check-ins tabs) |
| Feb 12 | Laundry Removal | Removed machines, storages, and services features; cleaned up all laundry-specific code |
| Feb 05 | Machines & Storages | (Removed) Previously managed laundry equipment |
| Feb 02 | Cashier Groups | Customizable cashier layout with POS groups per branch |
| Feb 02 | Services Feature | (Removed) Previously managed laundry services |
| Feb 02 | Customers Feature | (Adapted) Renamed to Members with gym-specific fields |
