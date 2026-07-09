# Ebe Gym

A Flutter multi-platform gym management system supporting Android, iOS, macOS, Linux, Windows, and Web.

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | SDK ^3.5.4 | Cross-platform UI framework |
| Dart | ^3.5.4 | Programming language |
| Hooks Riverpod | 3.1.0 | State management |
| GoRouter | 15.2.3 | Type-safe navigation |
| PocketBase | 0.22.0 | Backend-as-a-Service |
| dart_mappable | 4.3.0 | Model serialization |
| flutter_form_builder | 10.0.1 | Form handling |
| Slang | 4.7.1 | Localization/i18n |
| fpdart | 1.1.0 | Functional programming |

## Architecture

The project follows a **feature-based clean architecture** pattern:

```
lib/
├── main.dart                 # Application entry point
└── src/
    ├── application.dart      # Root MaterialApp widget
    ├── core/                 # Shared functionality across all features
    └── features/             # Feature-specific modules
```

## Project Structure

### Core Module (`lib/src/core/`)

```
core/
├── assets/              # Generated asset references & i18n
├── behaviors/           # Custom scroll behaviors
├── controllers/         # App-wide Riverpod providers
│   ├── nav_items_controller.dart
│   ├── scaffold_controller.dart
│   └── package_info_controller.dart
├── extensions/          # Dart extension methods
│   ├── date_time_extension.dart
│   ├── string_extension.dart
│   ├── int_extension.dart
│   ├── num_extension.dart
│   └── file_extension.dart
├── hooks/               # Custom Flutter hooks
│   ├── use_infinite_scroll.dart
│   └── use_form_dirty_guard.dart
├── loggers/             # Development logging
│   └── riverpod_logger.dart
├── models/              # Core shared models
│   ├── failure.dart           # Sealed error types
│   ├── pb_record.dart         # PocketBase base class
│   ├── pb_repository.dart     # Repository interfaces
│   ├── page_results.dart      # Pagination model
│   ├── pb_file.dart           # File handling abstraction
│   ├── pb_filter.dart         # Query builder
│   └── type_defs.dart         # Type aliases
├── packages/            # External package integrations
│   ├── pocketbase.dart
│   ├── pocketbase_collections.dart
│   ├── file_downloader.dart
│   └── flutter_secure_storage.dart
├── pages/               # Core template pages
│   ├── app_root.dart          # Root scaffold
│   ├── splash_page.dart
│   ├── not_found_page.dart
│   ├── work_in_progress_page.dart
│   └── more_page.dart
├── routing/             # GoRouter configuration
│   ├── router.dart            # Router setup
│   ├── main.routes.dart       # Route definitions
│   └── routes/                # Feature route files
├── strings/             # Constants & string resources
│   ├── fields.dart
│   ├── endpoints.dart
│   ├── pb_expand.dart
│   └── table_controller_keys.dart
├── utils/               # Utility functions
│   ├── validators.dart
│   ├── form_utils.dart
│   ├── pb_utils.dart
│   ├── router_utils.dart
│   ├── image_compressor_utils.dart
│   ├── file_picker.dart
│   └── parser_utils.dart
└── widgets/             # Reusable UI components
    ├── dynamic_form_fields/   # Form field builders
    ├── dynamic_table/         # Data table components
    ├── dynamic_group/         # Grouped UI components
    ├── loaders/               # Loading indicators
    ├── modals/                # Dialog components
    └── [various widgets]
```

### Feature Modules (`lib/src/features/`)

Features are organized into **domain groups** for better discoverability and maintainability:

```
features/
├── members/                     # Gym member management
├── memberships/                 # Membership plans and subscriptions
├── member_cards/                # Physical ID cards (RFID/barcode)
├── check_in/                    # Member check-in
├── products/                    # Product catalog and inventory
├── pos/                         # Point of sale / cashier
├── sales/                       # Sales history
├── reports/                     # Sales and inventory reports
├── dashboard/                   # Dashboard KPIs and quick actions
├── organization/                # Users, roles, branches
├── settings/                    # System settings
└── auth/                        # Authentication
```

Each feature follows a consistent internal structure:

```
{feature}/
├── data/
│   └── {feature}_repository.dart    # Repository implementation
├── domain/
│   └── {feature}.dart               # Entity/Model with @MappableClass
└── presentation/
    ├── controllers/                  # Riverpod providers
    ├── pages/                        # Full-screen UI
    └── widgets/                      # Feature-specific components
```

## Packages

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | UI framework |
| `cupertino_icons` | 1.0.8 | iOS-style icons |
| `material_design_icons_flutter` | 7.0.7296 | Material icons |
| `intl` | 0.20.2 | Internationalization |

### State Management

| Package | Version | Purpose |
|---------|---------|---------|
| `hooks_riverpod` | 3.1.0 | State management with hooks |
| `riverpod_annotation` | 4.0.0 | Riverpod code generation |
| `flutter_hooks` | 0.21.2 | React-style hooks |

### Navigation

| Package | Version | Purpose |
|---------|---------|---------|
| `go_router` | 15.2.3 | Declarative routing |

### Serialization

| Package | Version | Purpose |
|---------|---------|---------|
| `dart_mappable` | 4.3.0 | Model mapping/serialization |

### Forms & Validation

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_form_builder` | 10.0.1 | Form building |
| `form_builder_validators` | 11.1.1 | Validation rules |
| `form_builder_extra_fields` | 12.0.0 | Additional field types |
| `form_builder_file_picker` | 5.0.0 | File picker field |
| `form_builder_image_picker` | 4.1.0 | Image picker field |
| `mask_text_input_formatter` | 2.9.0 | Input masking |

### Backend & API

| Package | Version | Purpose |
|---------|---------|---------|
| `pocketbase` | 0.22.0 | Backend client |
| `http` | 1.2.2 | HTTP requests |

### Storage & Security

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_secure_storage` | 9.2.2 | Secure credential storage |
| `path_provider` | 2.1.5 | System paths |

### UI Components

| Package | Version | Purpose |
|---------|---------|---------|
| `cached_network_image` | 3.4.1 | Image caching |
| `photo_view` | 0.15.0 | Image viewer with zoom |
| `material_table_view` | 5.0.0 | Table display |
| `table_calendar` | 3.1.3 | Calendar widget |
| `flutter_typeahead` | 5.2.0 | Autocomplete |
| `skeletonizer` | 2.0.1 | Loading skeletons |
| `responsive_builder` | 0.7.1 | Responsive layouts |
| `flutter_side_menu` | 0.5.41 | Side navigation |
| `tab_container` | 3.5.3 | Tab navigation |
| `sliver_tools` | 0.2.12 | Advanced scrolling |

### Localization & Theming

| Package | Version | Purpose |
|---------|---------|---------|
| `slang` | 4.7.1 | i18n code generation |
| `slang_flutter` | 4.7.0 | Flutter i18n integration |
| `theme_provider` | 0.6.0 | Dynamic theming |

### Files & Documents

| Package | Version | Purpose |
|---------|---------|---------|
| `file_picker` | 10.2.0 | File selection |
| `file_saver` | 0.2.14 | File saving |
| `flutter_image_compress` | 2.4.0 | Image compression |
| `image_picker` | 1.1.2 | Image/video picker |
| `pdf` | 3.11.3 | PDF generation |
| `printing` | 5.14.2 | Print support |
| `background_downloader` | 9.2.1 | Background downloads |

### Platform & System

| Package | Version | Purpose |
|---------|---------|---------|
| `window_manager` | 0.5.0 | Desktop window control |
| `package_info_plus` | 8.1.2 | App version info |
| `permission_handler` | 12.0.0+1 | System permissions |
| `url_launcher` | 6.3.1 | URL opening |
| `restart_app` | 1.3.2 | App restart |

### Functional Programming

| Package | Version | Purpose |
|---------|---------|---------|
| `fpdart` | 1.1.0 | Either type for error handling |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | 2.4.13 | Code generation |
| `dart_mappable_builder` | 4.3.0 | Mapper generation |
| `riverpod_generator` | 4.0.0 | Provider generation |
| `go_router_builder` | 4.1.3 | Route generation |
| `slang_build_runner` | 4.7.0 | i18n generation |
| `flutter_launcher_icons` | 0.14.3 | App icon generation |
| `flutter_native_splash` | 2.4.4 | Splash screen |
| `flutter_lints` | 6.0.0 | Lint rules |
| `riverpod_lint` | 3.1.0 | Riverpod linting |

## Entities

See [`docs/entities.md`](docs/entities.md) for the full entity reference. Key domains:

### Member Management

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `Member` | Gym members | name, mobileNumber, dateOfBirth, sex, address, remarks, rfidCardId |
| `MemberCard` | Physical ID cards | member, cardNumber, status, type |
| `Membership` | Membership plan templates | name, duration, price, isActive |
| `MemberMembership` | Member subscriptions | member, membership, startDate, endDate, status |
| `CheckIn` | Check-in records | member, checkInTime, method |

### Products & Sales

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `Product` | Product catalog | name, price, category, branch, stockThreshold |
| `ProductCategory` | Product categories | name, parent (hierarchical) |
| `ProductLot` | Lot/batch inventory | product, lotNo, quantity, expiration |
| `Sale` | Transaction records | totalAmount, status, customerId, branch |
| `Payment` | Payment records | sale, amount, paymentMethod |

### Organization

| Entity | Description | Key Fields |
|--------|-------------|------------|
| `User` | System users | name, email, role, branch |
| `UserRole` | Role definitions | name, permissions |
| `Branch` | Gym locations | name, address, contactNumber, operatingHours |

## Entity Relationships

```
Branch
  ├── User ──→ UserRole
  ├── Member ──→ MemberCard
  │     ├── MemberMembership ──→ Membership
  │     ├── CheckIn
  │     └── Sale ──→ SaleItem, Payment
  └── Product ──→ ProductCategory
        ├── ProductLot
        └── ProductAdjustment
```

## Key Patterns

### Error Handling
Uses sealed `Failure` class with `FutureEither<T>` for type-safe error handling:
```dart
FutureEither<Member> getMember(String id) {
  return TaskEither.tryCatch(() async {
    final result = await collection.getOne(id);
    return MemberDto.fromRecord(result).toEntity();
  }, Failure.handle).run();
}
```

### Repository Pattern
All data access through repository interfaces with `FutureEither` return types.

### State Management
Riverpod with `@riverpod` annotation and `AsyncNotifier`:
```dart
@riverpod
class Member extends _$Member {
  @override
  Future<Member?> build(String id) async {
    final result = await ref.read(memberRepositoryProvider).getById(id);
    return result.fold((_) => null, (member) => member);
  }
}
```

### Type-Safe Routing
GoRouter with `@TypedGoRoute` annotation:
```dart
@TypedGoRoute<MemberDetailRoute>(path: ':id')
class MemberDetailRoute extends GoRouteData {
  final String id;
  @override
  Widget build(context, state) => MemberDetailPage(memberId: id);
}
```

### Model Serialization
dart_mappable with `@MappableClass()`:
```dart
@MappableClass()
class Member with MemberMappable {
  final String name;
  final DateTime? dateOfBirth;
}
```

## Commands

### Setup
```bash
# Install dependencies
dart pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Generate localization
dart run slang
```

### Development
```bash
# Run the app
flutter run

# Run tests
flutter test

# Analyze code
dart analyze

# Format code
dart format lib/
```

### Code Generation
```bash
# Generate app icons
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create

# Change package name
dart run change_app_package_name:main com.example.app
```

### Deployment
```bash
# Deploy server to Fly.io
flyctl launch --build-only --dockerfile
```

### PocketBase
```bash
# Create admin user
pocketbase admin create admin@test.com password101

# Start server
pocketbase serve --dir .
```

## Environment Configuration

The app supports multiple deployment environments via `--dart-define`:

| Environment | URL | Usage |
|-------------|-----|-------|
| `dev` | `http://127.0.0.1:8090` | Local development |
| `staging` | `https://staging.ebegym.com` | Staging/QA |
| `prod` | `https://ebegym.com` | Production |

### VS Code Launch Configs

Use the VS Code Run and Debug dropdown to select environment:
- **dev** - Connects to local PocketBase
- **staging** - Connects to staging server
- **prod (local test)** - Connects to production server

### Build Commands

```bash
# Development build
flutter build web --dart-define=ENV=dev

# Staging build
flutter build web --dart-define=ENV=staging

# Production build
flutter build web --dart-define=ENV=prod --release
```

### CI/CD

Pass the `--dart-define=ENV=<env>` flag in your build pipeline:

```yaml
# GitHub Actions example
- run: flutter build web --dart-define=ENV=staging
```

### Fallback Behavior

If `ENV` is not specified:
- **Debug mode** (`flutter run`): Uses `dev` URL
- **Release mode** (`flutter build --release`): Uses `prod` URL

## License

This project is proprietary software.
