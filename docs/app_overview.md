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
- KPI summary cards: Today's Sales, Today's Check-ins, Active Members, New Members
- Quick action buttons: Check-In, New Sale, New Member
- Expiring memberships section (memberships expiring within 7 days)
- Inventory alerts (low stock, expiring products)
- Pull-to-refresh invalidates all dashboard data

#### Check-In (`/check-in`)
Member check-in system for tracking gym visits.

- **Features**:
  - Card scan input (RFID/barcode) for quick check-in via member cards
  - Member search by name or mobile number
  - Active membership status display
  - Manual check-in with membership validation
  - Warning for members without active membership
  - Recent check-ins list for today
  - Success dialog with membership status
  - Backward compatibility with legacy `rfidCardId` field on members
- **Key Models**: `CheckIn`, `CheckInMethod`
- **Controllers**:
  - `checkInController` - Today's check-ins list + manual/card check-in actions
  - `memberCheckIns` - Check-in history for a specific member

#### Members (`/members`)
Member management with membership and check-in tracking.

- **Sub-features**:
  - Members list with search by name or phone
  - Member detail with info and tabbed sections
  - Create/edit member via bottom sheet form
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
  - Create/edit plans via bottom sheet form
  - **Add-ons per plan** (e.g., Treadmill Access, Coach/Instructor, Locker, Pool Access) — each with its own price, managed from the plan detail page
  - Purchase membership flow from member detail page with optional add-on selection — total cost = base price + selected add-ons
- **Key Models**: `Membership`, `MembershipAddOn`, `MemberMembership`, `MemberMembershipAddOn`, `MemberMembershipStatus`
- **Master-Detail Layout**: Tablet shows list + detail side-by-side

#### Products (`/products`)
Inventory and product management with lot tracking.

- **Sub-features**:
  - Products list with categories
  - Stock lots with FEFO (First-Expire-First-Out) tracking
  - Stock adjustments with audit trail
  - Hierarchical category organization
- **Key Models**: `Product`, `ProductCategory`, `ProductLot`, `ProductAdjustment`

---

### Secondary Features

#### Point of Sale / Cashier (`/cashier`)
Complete POS system for processing product sales.

- **Features**:
  - **Customizable Cashier Layout** (POS Groups): Create named groups of products per branch to define the cashier page layout. Groups display as scrollable sections with sticky headers. Falls back to default product grid when no groups are configured.
  - Product grid with search and category filtering
  - Search dropdown overlay (grouped mode)
  - Shopping cart with product items
  - Lot selection with FEFO ordering for lot-tracked products
  - Variable price support for products
  - Multiple payment methods (cash, card, check, etc.)
  - Receipt generation and printing
- **Components**:
  - `ProductGrid` - Product selection (default mode)
  - `GroupedCashierView` - Scrollable grouped sections (grouped mode)
  - `CashierSearchDropdown` - Search overlay for grouped mode
  - `CartView` - Shopping cart
  - `CheckoutDialog` - Payment processing
  - `LotSelectionDialog` - FEFO lot selection
  - `ReceiptDialog` - Receipt display/print

#### Sales History (`/sales`)
View and manage completed transactions.

- Paginated sales history with search
- Sale status display (pending, completed, refunded, voided)
- Detailed sale view with items and payment info
- Refund/unrefund functionality with confirmation dialogs

#### Reports (`/reports`)
Sales and inventory reporting.

- Sales reports with date ranges
- Inventory reports

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
- **Branches** (`/organization/branches`) - Multi-location support with address and contact info

#### System Settings (`/system`)
3-panel tablet layout for system configuration.

**Modes:**
- **Product Categories** (`/system/product-categories`) - Hierarchical product categories
- **Cashier Layout** (`/system/cashier-groups`) - POS groups management per branch

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
- **Dashboard**: Home with KPIs, quick actions, expiring memberships, inventory alerts
- **Check-In**: Member search, check-in with membership validation
- **Cashier/POS**: Product grid and checkout
- **Sales List**: Transaction history
- **Sale Detail**: Receipt view with refund/void actions
- **Products List**: Browse products with categories
- **Product Detail**: Stock and adjustments
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
| Mobile | Drawer | Full menu (10 sections) |
| Tablet | Navigation Rail | Icons only (72px) |
| Tablet Large | Expanded Rail | Icons + labels (160px) |

### Navigation Index Mapping

| Index | Route | Label | Icon |
|-------|-------|-------|------|
| 0 | `/` | Dashboard | `dashboard` |
| 1 | `/check-in` | Check-In | `how_to_reg` |
| 2 | `/cashier` | Cashier | `point_of_sale` |
| 3 | `/sales` | Sales | `receipt_long` |
| 4 | `/products` | Products | `inventory_2` |
| 5 | `/members` | Members | `people` |
| 6 | `/memberships` | Memberships | `card_membership` |
| 7 | `/reports` | Reports | `analytics` |
| 8 | `/organization` | Organization | `business` |
| 9 | `/system` | System | `settings` |

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
| Feb 17 | Member Cards | Physical ID cards (RFID/barcode) linked to members with status management; card scan check-in on check-in page with backward compatibility for legacy rfidCardId |
| Feb 16 | Membership Add-Ons | Add-on options per membership plan (e.g., Treadmill, Coach, Pool) with pricing, selectable during purchase |
| Feb 12 | Dashboard Adaptation | Replaced laundry metrics with gym KPIs (sales, check-ins, active members, new members), added expiring memberships section |
| Feb 12 | Check-In Feature | Created full check-in system with member search, membership validation, and recent check-ins list |
| Feb 12 | Memberships Feature | Created membership plans CRUD, member subscriptions, purchase flow from member detail page |
| Feb 12 | Members Feature | Adapted customers to members with gym-specific fields (RFID, memberships, check-ins tabs) |
| Feb 12 | Laundry Removal | Removed machines, storages, and services features; cleaned up all laundry-specific code |
| Feb 05 | Machines & Storages | (Removed) Previously managed laundry equipment |
| Feb 02 | Cashier Groups | Customizable cashier layout with POS groups per branch |
| Feb 02 | Services Feature | (Removed) Previously managed laundry services |
| Feb 02 | Customers Feature | (Adapted) Renamed to Members with gym-specific fields |
