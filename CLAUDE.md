# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/claude-code) when working with code in this repository.

## Project Overview

This is **ebe_gym** - a Flutter multi-platform gym management system. The application supports Android, iOS, macOS, Linux, Windows, and Web platforms.

## PocketBase Schema Changes

**IMPORTANT RULE: NEVER create, edit, delete, rename, or rewrite any file under `server/pb_migrations/`.**

- Do **not** hand-write migration scripts
- Do **not** "fix" a failing migration by editing the `.js` file
- Do **not** add schema changes by writing a new migration file

Apply all PocketBase schema changes (collections, fields, indexes, views, API rules) via the **PocketBase Admin API** or admin UI only. PocketBase auto-generates migration files from those changes — leave generated files alone unless a human explicitly asks otherwise.

If a migration fails: diagnose the query/schema issue, fix it via the Admin API (e.g. PATCH the collection), and let PocketBase regenerate migrations. Never patch the broken `.js` file yourself.

See the `pocketbase-schema-change` skill for the Admin API authentication/patch workflow (credentials, curl commands).

## Common Commands

```bash
# Run code generation (mappers, serializers, routes)
# IMPORTANT: Always use --low-resources-mode to prevent memory issues
dart run build_runner build --delete-conflicting-outputs --low-resources-mode

# Or use watch mode for continuous rebuilds
dart run build_runner watch -d --low-resources-mode
```

## Key Patterns

### State Management
- Use `@riverpod` annotation for providers
- AsyncNotifier for async state with loading/error handling
- Controllers extend `AsyncNotifier<T>` or use `Notifier<T>`

### Widget Patterns
- **Always use `HookConsumerWidget`** for widgets that need Riverpod and/or local state
- Use **flutter_hooks** for local state management (`useState`, `useEffect`, `useMemoized`, etc.)
- Use **fpdart** for functional programming patterns (`Either`, `Option`, `Task`, etc.)
- Prefer hooks over `StatefulWidget` for cleaner, more composable code
- Example:
  ```dart
  class MyWidget extends HookConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final counter = useState(0);
      final data = ref.watch(myProvider);

      useEffect(() {
        // Side effect on mount
        return () { /* cleanup */ };
      }, []);

      return Text('${counter.value}');
    }
  }
  ```

### Controller Naming (Singular vs Plural)
- **IMPORTANT:** Use singular/plural names consistently based on what the controller manages:
  - **Plural** (`PatientsController`) - Manages a **list** of entities (e.g., `List<Patient>`)
  - **Singular** (`memberProvider`) - Fetches/manages a **single** entity by ID
- Examples:
  - `MembersController` → `membersControllerProvider` → returns `List<Member>`
  - `member(id)` → `memberProvider(id)` → returns `Member?`
  - `MemberMembershipsController(memberId)` → `memberMembershipsControllerProvider(memberId)` → returns `List<MemberMembership>`
  - `memberMembership(id)` → `memberMembershipProvider(id)` → returns `MemberMembership?`

### Provider File Setup
- Keep list controllers and single-entity providers in separate files.
- File names should match singular/plural intent:
  - `*_records_controller.dart` or `*_controller.dart` for list controllers
  - `*_record_provider.dart` or `*_provider.dart` for single-entity providers
- Each provider file has its own `part '...g.dart';` and must be regenerated when renaming files.

### Routing
- Routes defined in `lib/src/core/routing/`
- Each feature has its own `*.routes.dart` file
- Use `@TypedGoRoute` annotation with go_router_builder
- **IMPORTANT:** Always use generated route extensions instead of manual navigation
  - Prefer: `const MembersRoute().go(context)` or `MemberDetailRoute(id: memberId).go(context)`
  - Avoid: `context.push('/members')` or `context.go('/members/$memberId')`
- **IMPORTANT:** Use `context.pop()` instead of `Navigator.pop(context)` for consistency with GoRouter

### Models
- Use `@MappableClass()` decorator from dart_mappable
- Extend `PBObject` for PocketBase models
- Include `collectionName` static constant

### Database Field Naming
- **Use camelCase** for PocketBase collection field names (e.g., `oldValue`, `newValue`, `productStock`)
- Avoid snake_case in database fields

### Currency Formatting
- **Use Philippine Peso (₱)** as the currency symbol throughout the application
- Use `NumberFormat.currency(symbol: '₱', decimalDigits: 2)` from intl package
- Example: `₱1,234.56`

### DateTime Handling
- **To server:** Always use `.toUtc()` when sending DateTime to PocketBase
- **From server:** Always use `.toLocal()` when parsing DateTime from PocketBase responses
- Example:
  ```dart
  // Sending to server
  final json = {'date': dateTime.toUtc().toIso8601String()};

  // Receiving from server (use helper if available)
  final localDate = DateTime.parse(json['date']).toLocal();
  ```
- Use `parseToLocal()` helper from DTOs when available for consistent parsing

### Forms (flutter_form_builder)
- **Always use flutter_form_builder** for forms instead of raw TextField/DropdownMenu widgets
- Wrap forms in `FormBuilder` widget with a `GlobalKey<FormBuilderState>`
- Use form builder widgets: `FormBuilderTextField`, `FormBuilderDropdown`, `FormBuilderDateTimePicker`, `FormBuilderSegmentedControl`, etc.
- Access field values via `_formKey.currentState?.fields['fieldName']?.value`
- Validate with `_formKey.currentState?.saveAndValidate()`

**Key widgets:**
- `FormBuilderTextField` - Text input with validation
- `FormBuilderDropdown<T>` - Dropdown selection
- `FormBuilderDateTimePicker` - Date/time picker
- `FormBuilderChoiceChips<T>` - Choice chips for single selection
- `FormBuilderRadioGroup<T>` - Radio button group
- `FormBuilderCheckbox` - Single checkbox
- `FormBuilderSwitch` - Toggle switch
- `FormBuilderFilterChips<T>` - Filter chips for multi-selection

**Validation:**
- Use `FormBuilderValidators` from `form_builder_validators` package
- Common validators: `.required()`, `.email()`, `.numeric()`, `.minLength()`, `.maxLength()`
- Compose validators: `FormBuilderValidators.compose([...])`

See the `flutter-form-builder` skill for a full example widget pattern and the field-change-listening snippet.

### Error Handling
- Use `Failure` class from `core/foundation/failure.dart`
- Return `Either<Failure, T>` for operations that can fail (using fpdart)

### Snackbars in Dialogs & Bottom Sheets
- **IMPORTANT:** Dialogs and bottom sheets that show snackbars **must** wrap their content in `ScaffoldMessenger` so snackbars render above the dialog overlay instead of behind it.
- Use `useRootMessenger: false` on all snackbar utility calls (`showSuccessSnackBar`, `showErrorSnackBar`, etc.) inside dialogs/sheets so they target the local `ScaffoldMessenger`.
- Use `Builder` to get a new `BuildContext` below the `ScaffoldMessenger`.
- **Skip this pattern** if the dialog never shows snackbars, or if wrapping would cause layout issues (e.g., conflicts with `IntrinsicHeight`). In those cases, note why it was skipped.

**Pattern for AlertDialog / Dialog:**
```dart
return ScaffoldMessenger(
  child: Builder(
    builder: (context) => AlertDialog(
      // ... dialog content
    ),
  ),
);
```

**Pattern for full-screen dialogs or bottom sheets:**
```dart
return ScaffoldMessenger(
  child: Builder(
    builder: (context) => Padding(
      // ... sheet content
    ),
  ),
);
```

### Unimplemented Features
- **IMPORTANT:** Always add a `// TODO:` comment when a feature is not yet implemented
- Use descriptive TODO comments that explain what needs to be done
- Format: `// TODO: <description of what needs to be implemented>`
- Example:
  ```dart
  onPressed: () {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon')),
    );
  },
  ```
- This helps track incomplete work and makes it easy to find and complete later

## Git Workflow

### Branch Protection Rules

**CRITICAL: NEVER push directly to `main` or `staging` branches.**

- `main` and `staging` are protected branches
- Always create a feature or fix branch for any changes
- All changes must go through a Pull Request to `staging`

### Branch Naming Convention

- Features: `feat/<short-description>` (e.g., `feat/member-registration`)
- Bug fixes: `fix/<short-description>` (e.g., `fix/login-validation`)
- Chores/refactoring: `chore/<short-description>` (e.g., `chore/update-dependencies`)

### Workflow

1. Create a new branch from `staging`:
   ```bash
   git checkout staging
   git pull origin staging
   git checkout -b feat/your-feature-name
   ```

2. Make your changes and commit

3. Push your branch and create a PR to `staging`:
   ```bash
   git push -u origin feat/your-feature-name
   gh pr create --base staging
   ```

4. After PR is merged to `staging`, `main` will be updated separately (production releases)

## Pull Requests

- **All PRs must target the `staging` branch**, not `main`.
- When creating PRs with `gh pr create`, always use `--base staging`.
- **Before creating a PR, always ask the user which version label to apply** (`version:patch`/`version:minor`/`version:major`, or no label to skip deploy).
- **Always include a QA Notes section** in the PR description.

See the `create-pr` skill for version label semantics, the `deploy`/`minimum version` labels, release tag naming, and the QA Notes template.

## Testing

Tests are located in `/test` directory mirroring the `lib/` structure.

## Important Directories

- `/lib/src/core/widgets/` - Reusable UI components
- `/lib/src/core/routing/` - All route definitions
- `/lib/src/core/packages/` - Package integrations (PocketBase, storage)
- `/assets/` - Static assets and icons
- `/server/` - Backend server configurations

## Documentation

Detailed documentation is available in the `/docs` directory:

- **[Entities](docs/entities.md)** - All domain models with fields, relationships, and collection names (18 collections, 5 enums)
- **[Folder Structure](docs/folder_structure.md)** - Architecture layers, feature module structure, DTOs, repositories, and code patterns
- **[UI Structure](docs/ui.md)** - Responsive layouts, navigation hierarchy, routing structure, and component architecture
- **[App Overview](docs/app_overview.md)** - High-level application overview with features, screens, and integrations

### Keeping Documentation Updated

**IMPORTANT:** When adding or modifying features, update `docs/app_overview.md` to reflect the changes:

1. **New Feature**: Add to the appropriate section (Primary Features, Secondary Features, or Organization/Admin)
2. **New Collection/Model**: Update the Domain Models section
3. **New Routes**: Update the Navigation Structure section
4. **New Screens**: Add to Key Screens section
5. **Recent Changes**: Add an entry to the "Recent Updates" table at the bottom with date, feature name, and brief description

Example update for Recent Updates table:
```markdown
| Jan 22 | Feature Name | Brief description of what was added |
```


## Testing
 check docs/testing.md for the testing account 


## grepai - Semantic Code Search

**IMPORTANT: You MUST use `grepai search` as your PRIMARY tool for code exploration** instead of Grep/Glob/find, for anything where you're describing what code does rather than matching exact text. Use Grep/Glob only for exact text/path matching, or if grepai fails (not running, index unavailable).

See the `grepai-search` skill for query syntax, trace-command usage, and the recommended workflow.

