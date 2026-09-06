# UI Structure - Tablet & Mobile

This document outlines the responsive UI structure for tablet and mobile devices, including navigation patterns and routing architecture.

---

## Table of Contents
- [Responsive Breakpoints](#responsive-breakpoints)
- [Mobile Layout](#mobile-layout)
- [Tablet Layout](#tablet-layout)
- [Navigation Hierarchy](#navigation-hierarchy)
- [Routing Structure](#routing-structure)
- [Component Architecture](#component-architecture)
- [Navigation Configuration](#navigation-configuration)

---

## Responsive Breakpoints

```
┌─────────────────────────────────────────────────────────────────┐
│                        BREAKPOINTS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0px          600px         900px        1200px       1600px    │
│  │             │             │             │             │      │
│  │   MOBILE    │   TABLET    │   TABLET    │  DESKTOP    │      │
│  │  (compact)  │  (medium)   │   (large)   │  (expanded) │      │
│  │             │             │             │             │      │
│  │ Bottom Nav  │   Nav Rail  │ Expanded    │ Full Side   │      │
│  │ + Drawer    │   (icons)   │ Rail+labels │ Menu        │      │
│  │             │             │             │             │      │
│  │ Single Col  │ Master-Det  │ Master-Det  │ Multi-panel │      │
│  │ Layout      │ Optional    │ Always      │ Layout      │      │
│  │             │             │             │             │      │
└─────────────────────────────────────────────────────────────────┘
```

| Breakpoint | Range | Layout Type | Navigation |
|------------|-------|-------------|------------|
| Mobile     | 0-599px | Single column | Bottom Nav + Drawer |
| Tablet Medium | 600-899px | Master-detail (optional) | Navigation Rail (icons) |
| Tablet Large | 900-1199px | Master-detail (always) | Firebase-style sidebar (260px, collapsible) |
| Desktop | 1200px+ | Multi-panel | Firebase-style sidebar (260px, collapsible) |

---

## Mobile Layout

### Main Structure (< 600px)

```
┌─────────────────────────────────────┐
│ ☰  Page Title              [Actions]│  <- App Bar with hamburger menu
├─────────────────────────────────────┤
│                                     │
│                                     │
│                                     │
│           CONTENT AREA              │
│                                     │
│                                     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  🏠    ✅    💰    ⋯               │  <- Bottom Navigation (3 items + More)
│ Home  Check  POS  More              │
└─────────────────────────────────────┘
```

### Mobile Drawer (accessed via hamburger or "More")

```
┌───────────────────────┐
│  ╭─────╮              │
│  │ LOGO│   Ebe Gym    │
│  ╰─────╯              │
├───────────────────────┤
│ 🏠 Dashboard          │
│ ✅ Check-In            │
│ 💰 Cashier             │
│ 📋 Sales History       │
│ 📦 Products            │
│ 👥 Members             │
│ 💳 Memberships         │
│ 📊 Reports             │
│ 🏢 Organization        │
│ ⚙️ System              │
├───────────────────────┤
│ 🚪 Logout             │
└───────────────────────┘
```

---

## Tablet Layout

### Portrait Mode - Navigation Rail + Content (600px - 900px)

```
┌────┬──────────────────────────────────────────┐
│    │  Page Title                    [Actions] │
│ 🏠 ├──────────────────────────────────────────┤
│    │                                          │
│ ✅ │                                          │
│    │                                          │
│ 💰 │              CONTENT AREA                │
│    │                                          │
│ 📋 │                                          │
│    │                                          │
│ 📦 │                                          │
│    │                                          │
│ 👥 │                                          │
│    │                                          │
│ 💳 │                                          │
│    │                                          │
│ 📊 │                                          │
│    │                                          │
│ 🏢 │                                          │
│    │                                          │
│ ⚙️ │                                          │
│────│                                          │
│ 👤 │                                          │  <- User avatar at bottom
└────┴──────────────────────────────────────────┘
  ↑
Navigation Rail (72px width, icons only)
```

### Tablet Master-Detail Layout (Members, Memberships)

```
┌────┬─────────────────┬────────────────────────────────────┐
│    │ Members         │  Member Detail                     │
│ 🏠 ├─────────────────┤────────────────────────────────────┤
│    │ 🔍 Search...    │  Name: John Doe                    │
│ ✅ ├─────────────────┤  Mobile: +63 912 345 6789          │
│    │ ┌─────────────┐ │                                    │
│ 💰 │ │ John Doe  ▶ │ │  ┌────────────────────────────┐   │
│    │ │ Active      │ │  │ Overview│Memberships│Check-ins│ │
│ 📋 │ └─────────────┘ │  └────────────────────────────┘   │
│    │ ┌─────────────┐ │                                    │
│ 📦 │ │ Jane Smith  │ │  Active Membership:                │
│    │ │ Expired     │ │  ┌──────────────────────────────┐  │
│ 👥 │ └─────────────┘ │  │ Monthly Plan - 15 days left  │  │
│    │ ┌─────────────┐ │  │ Expires: Mar 1, 2026         │  │
│ 💳 │ │ Bob Chen    │ │  └──────────────────────────────┘  │
│    │ │ No membership│ │                                    │
│ 📊 │ └─────────────┘ │  [Purchase Membership]             │
└────┴─────────────────┴────────────────────────────────────┘
 Rail    List Panel          Detail Panel
(72px)    (320px)            (Remaining)
```

### Tablet Large / Desktop Sidebar (>= 900px)

Firebase-inspired grouped sidebar with hover flyouts for categories.

```
┌────────────────────────┬──────────────────────────────────────────┐
│  LOGO  Test Gym        │  Org | Branch scope bar                  │
├────────────────────────┼──────────────────────────────────────────┤
│ ● Dashboard            │                                          │
│                        │                                          │
│ SHORTCUTS              │                                          │
│   Check-In             │              CONTENT AREA                │
│   Members              │                                          │
│   Sales                │                                          │
│   Products             │                                          │
│   Show more            │                                          │
│                        │                                          │
│ CATEGORIES             │                                          │
│   People            >  │──► Flyout: Memberships                   │
│   Administration    >  │──► Flyout: Users, Roles, Branches        │
│                        │                                          │
│   System            >  │                                          │
├────────────────────────┤                                          │
│ Logout                 │                                          │
│ ◀ Collapse             │                                          │
└────────────────────────┴──────────────────────────────────────────┘
 260px (72px collapsed)              Remaining
```

**Sidebar sections**

| Section | Contents |
|---------|----------|
| Overview | Dashboard (pill highlight when active) |
| Shortcuts | Check-In, Members, Sales, Products (+ Show more for extra destinations) |
| Categories | Operations, People, Insights, Administration, Account — hover/tap flyout for items not already in shortcuts |
| System | Direct link to `/system` |
| Footer | Platform admin (super-admin), Logout, Collapse toggle |

Org/branch switching stays in the top `ScopeSwitcherBar` above content (not in the sidebar).

---

## Navigation Hierarchy

```
                              ┌─────────────────┐
                              │   App Shell     │
                              │  (StatefulShell)│
                              └────────┬────────┘
                                       │
        ┌──────────────────────────────┼──────────────────────────────┐
        │                              │                              │
        ▼                              ▼                              ▼
┌───────────────┐          ┌───────────────────┐          ┌───────────────┐
│   Primary     │          │    Secondary      │          │    Admin      │
│  Navigation   │          │   Navigation      │          │   Navigation  │
└───────┬───────┘          └─────────┬─────────┘          └───────┬───────┘
        │                            │                            │
   ┌────┴────┐                  ┌────┴────┐                  ┌────┴────┐
   │         │                  │         │                  │         │
   ▼         ▼                  ▼         ▼                  ▼         ▼
┌──────┐ ┌────────┐      ┌──────────┐ ┌────────┐      ┌────────┐ ┌──────────┐
│ Home │ │CheckIn │      │ Members  │ │Products│      │ Org    │ │ System   │
└──────┘ └────────┘      └────┬─────┘ └────────┘      └────┬───┘ └──────────┘
                              │                             │
                         ┌────┴────┐                   ┌────┴────┐
                         │         │                   │         │
                         ▼         ▼                   ▼         ▼
                      Members  Memberships           Users   Branches
                      Detail   Plans                 Roles
```

---

## Routing Structure

### Complete Route Tree

```
/                                    -> Dashboard
│
├── /check-in                        -> Check-In Page
│
├── /cashier                         -> Cashier/POS
│
├── /sales                           -> Sales History
│   └── /sales/:id                   -> Sale Detail
│
├── /products                        -> Products List
│   ├── /products/:id                -> Product Detail
│   ├── /products/categories         -> Categories
│   └── /products/adjustments        -> Adjustments
│
├── /members                         -> Members List
│   └── /members/:id                 -> Member Detail
│
├── /memberships                     -> Memberships List
│   └── /memberships/:id             -> Membership Detail
│
├── /reports                         -> Reports
│
├── /organization                    -> Organization Landing
│   ├── /organization/users          -> Users List
│   │   └── /organization/users/:id  -> User Detail
│   ├── /organization/roles          -> Roles List
│   │   └── /organization/roles/:id  -> Role Detail
│   └── /organization/branches       -> Branches List
│       └── /organization/branches/:id -> Branch Detail
│
├── /system                          -> System Landing
│   ├── /system/product-categories   -> Product Categories
│   │   └── /system/product-categories/:id
│   └── /system/cashier-groups       -> POS Groups
│       └── /system/cashier-groups/:id
│
└── /auth (non-shell routes)
    ├── /login/user                  -> User Login
    └── /recovery                    -> Account Recovery
```

### Shell Branches (10 Total)

| Index | Base Route | Label | Icon |
|-------|------------|-------|------|
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

## Component Architecture

### Shell Widget Structure

```
AppRoot (adaptive shell)
├── MobileShell (< 600px)
│   ├── Scaffold
│   │   ├── AppBar (with drawer toggle)
│   │   ├── Body (content)
│   │   ├── BottomNavigationBar (3 items + More)
│   │   └── Drawer (MobileDrawer)
│
├── TabletShell (600px - 899px)
│   ├── Row
│   │   ├── NavigationRail (icons only)
│   │   │   ├── Leading (Logo)
│   │   │   ├── Destinations (permission-filtered)
│   │   │   └── Trailing (Platform admin, Logout)
│   │   └── Expanded
│   │       └── Scaffold
│   │           ├── ScopeSwitcherBar
│   │           └── Body (content or Master-Detail)
│
└── DesktopSideNavShell (>= 900px)
    └── Row
        ├── DesktopSideNav (260px, collapsible to 72px)
        │   ├── Header (Logo + app title)
        │   ├── Dashboard + Shortcuts + Categories + System
        │   └── Footer (Platform admin, Logout, Collapse)
        └── Expanded
            └── Scaffold
                ├── ScopeSwitcherBar
                └── Body (content)
```

### Adaptive List-Detail Layout

```
AdaptiveListDetail
├── Mobile: Stack-based navigation (push detail)
│   ┌─────────────────┐     ┌─────────────────┐
│   │     List        │ --> │     Detail      │
│   │                 │     │                 │
│   └─────────────────┘     └─────────────────┘
│
└── Tablet: Side-by-side (permanent)
    ┌─────────┬───────────────┐
    │  List   │    Detail     │
    │  (320px)│  (Remaining)  │
    └─────────┴───────────────┘
```

---

## Navigation Configuration

### Mobile Bottom Navigation

| Icon | Label | App Index |
|------|-------|-----------|
| `dashboard` | Dashboard | 0 |
| `how_to_reg` | Check-In | 1 |
| `point_of_sale` | Cashier | 2 |
| `more_horiz` | More | Opens drawer |

### Tablet Navigation Rail (all 10 items)

| Icon | Label | App Index |
|------|-------|-----------|
| `dashboard` | Dashboard | 0 |
| `how_to_reg` | Check-In | 1 |
| `point_of_sale` | Cashier | 2 |
| `receipt_long` | Sales | 3 |
| `inventory_2` | Products | 4 |
| `people` | Members | 5 |
| `card_membership` | Memberships | 6 |
| `analytics` | Reports | 7 |
| `business` | Organization | 8 |
| `settings` | System | 9 |

---

## Member Detail - Memberships, Check-ins & Sales

The Member Detail page (`/members/:id`) uses a **4-section interface** with adaptive handling for mobile vs tablet.

### Section Structure

```
Member Detail Page
├── Section 1: Overview     -> Member info (name, contact, DOB, sex, address, RFID)
├── Section 2: Memberships  -> Active/expired memberships, purchase button
├── Section 3: Check-ins    -> Recent check-in history
└── Section 4: Sales        -> Product purchase history
```

### Data Relationships

```
Member (master)
│
├── MemberMembership[] (subscriptions)
│   ├── membership (FK -> Membership plan)
│   ├── startDate, endDate, status
│   └── expand: { membership.name, membership.price }
│
├── CheckIn[] (gym visits)
│   ├── checkInTime, method
│   └── expand: { member.name }
│
└── Sale[] (via member FK)
    └── saleItems, payments
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/src/core/pages/app_root.dart` | Main shell widget with navigation |
| `lib/src/core/navigation/app_nav_presentation.dart` | Shared nav icons, labels, categories, shortcuts |
| `lib/src/core/widgets/mobile_bottom_nav.dart` | Bottom navigation (3 items + More) |
| `lib/src/core/widgets/mobile_drawer.dart` | Mobile drawer (permission-filtered destinations) |
| `lib/src/core/widgets/tablet_nav_rail.dart` | Tablet-medium navigation rail (600–899px) |
| `lib/src/core/widgets/desktop_side_nav.dart` | Firebase-style sidebar (>=900px) |
| `lib/src/core/utils/breakpoints.dart` | Centralized breakpoint definitions |
