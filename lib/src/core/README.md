# Core Module

This directory contains shared functionality used across all features.

## Folder Structure

```
core/
├── assets/           # Generated asset files
├── constants/        # App-wide constant values
├── controllers/      # Global state providers
├── extensions/       # Dart extensions
├── foundation/       # Base classes and type definitions
├── hooks/            # Custom Flutter hooks
├── i18n/             # Generated localization files
├── packages/         # Third-party integrations
├── pages/            # Global pages
├── routing/          # Navigation configuration
├── utils/            # Utility functions
└── widgets/          # Shared UI components
```

---

## constants/

App-wide constant values used throughout the application.

**Should contain:**
- `app_constants.dart` - Application metadata (name, version)
- `api_constants.dart` - Network timeouts and API configuration
- `spacing.dart` - UI spacing values
- `radii.dart` - Border radius values
- `durations.dart` - Animation durations

**Existing files:**
- `constants.dart` - Contains all constants (`AppConstants`, `ApiConstants`, `Spacing`, `Radii`, `Durations`, `Pagination`)

**Pattern:**
```dart
abstract class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

---

## controllers/

Global state management providers that are used across multiple features.

**Should contain:**
- `auth_controller.dart` - Authentication state
- `theme_controller.dart` - Theme/appearance state
- `branch_controller.dart` - Current branch selection
- `connectivity_controller.dart` - Network status

**Pattern:**
```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async => _loadCurrentUser();
}
```

---

## extensions/

Dart extension methods to enhance existing types.

**Should contain:**
- `context_extensions.dart` - BuildContext helpers (theme, navigator, etc.)
- `string_extensions.dart` - String manipulation (capitalize, truncate, etc.)
- `datetime_extensions.dart` - Date formatting and comparison
- `num_extensions.dart` - Number formatting (currency, percentages)

**Pattern:**
```dart
extension StringX on String {
  String get capitalized => '${this[0].toUpperCase()}${substring(1)}';
}
```

---

## foundation/

Base classes, interfaces, and type definitions that form the foundation of the architecture.

**Should contain:**
- `failure.dart` - Error handling sealed class
- `pb_record.dart` - PocketBase record base class
- `pb_repository.dart` - Repository interface
- `type_defs.dart` - Type aliases (Json, FutureEither, etc.)

**Pattern:**
```dart
typedef Json = Map<String, dynamic>;
typedef FutureEither<T> = Future<Either<Failure, T>>;
```

---

## hooks/

Custom Flutter hooks for use with flutter_hooks.

**Should contain:**
- `use_debounce.dart` - Debounced value/callback
- `use_async_effect.dart` - Async version of useEffect
- `use_form_controller.dart` - Form state management
- `use_pagination.dart` - Pagination logic

**Pattern:**
```dart
T useDebounce<T>(T value, {Duration delay = const Duration(milliseconds: 300)}) {
  final debouncedValue = useState(value);
  // ...
  return debouncedValue.value;
}
```

---

## packages/

Third-party package integrations and wrappers.

**Should contain:**
- `pocketbase/` - PocketBase client provider and helpers
- `storage/` - Local storage provider (shared_preferences, hive)
- `analytics/` - Analytics service wrapper
- `notifications/` - Push notification setup

**Pattern:**
```dart
@riverpod
PocketBase pocketBase(Ref ref) {
  return PocketBase(Environment.apiUrl);
}
```

---

## pages/

Global pages that don't belong to any specific feature.

**Should contain:**
- `app_root.dart` - Main shell/scaffold with navigation
- `splash_page.dart` - Initial loading screen
- `error_page.dart` - Global error display
- `not_found_page.dart` - 404 page

---

## routing/

Navigation configuration using GoRouter.

**Should contain:**
- `router.dart` - Main GoRouter configuration
- `routes/` - Route definitions organized by domain
  - `_root.routes.dart` - Shell and root routes
  - `members.routes.dart` - Members feature routes
  - `products.routes.dart` - Product feature routes
  - etc.

**Pattern:**
```dart
@TypedGoRoute<MembersRoute>(
  path: '/members',
  routes: [
    TypedGoRoute<MemberDetailRoute>(path: ':id'),
  ],
)
class MembersRoute extends GoRouteData { ... }
```

---

## utils/

Utility functions and helpers.

**Should contain:**
- `validators.dart` - Form validation functions
- `formatters.dart` - Data formatting (dates, currency, etc.)
- `file_picker.dart` - File selection utilities
- `window_utils.dart` - Desktop window management

**Existing files:**
- `window_utils.dart` - Desktop window configuration

**Pattern:**
```dart
class Validators {
  static String? required(String? value) =>
      value?.isEmpty ?? true ? 'Required' : null;
}
```

---

## widgets/

Reusable UI components shared across features.

**Should contain:**
- `adaptive_shell.dart` - Responsive layout shell
- `loading_overlay.dart` - Loading indicator overlay
- `error_view.dart` - Error display widget
- `empty_state.dart` - Empty list placeholder
- `form_fields/` - Custom form field widgets
  - `date_picker_field.dart`
  - `dropdown_field.dart`
  - `search_field.dart`

**Pattern:**
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  // ...
}
```

---

## Guidelines

1. **No feature-specific code** - Core should only contain shared functionality
2. **No business logic** - Business logic belongs in feature services
3. **Minimal dependencies** - Core should not depend on features
4. **Well-documented** - Public APIs should have dartdoc comments
5. **Tested** - Core utilities should have unit tests
