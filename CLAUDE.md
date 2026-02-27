# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/claude-code) when working with code in this repository.

## Project Overview

This is **ebe_gym** - a Flutter multi-platform gym management system. The application supports Android, iOS, macOS, Linux, Windows, and Web platforms.

## Tech Stack

- **Language:** Dart
- **Framework:** Flutter
- **State Management:** Hooks Riverpod
- **Navigation:** GoRouter with go_router_builder
- **Backend:** PocketBase (BaaS)
- **Serialization:** dart_mappable
- **Forms:** flutter_form_builder
- **Localization:** slang/slang_flutter

## Architecture

The project follows a **feature-based clean architecture**:

```
lib/src/
├── core/           # Shared functionality (routing, widgets, utils, models)
└── features/       # Feature modules (patients, products, appointments, etc.)
    └── [feature]/
        ├── data/           # Repositories, data sources
        ├── domain/         # Models, entities
        └── presentation/
            ├── controllers/  # Riverpod providers/notifiers
            ├── pages/        # Full-screen UI
            └── widgets/      # Feature-specific widgets
```

## Common Commands

```bash
# Install dependencies
dart pub get

# Run code generation (mappers, serializers, routes)
# IMPORTANT: Always use --low-resources-mode to prevent memory issues
dart run build_runner build --delete-conflicting-outputs --low-resources-mode

# Or use watch mode for continuous rebuilds
dart run build_runner watch -d --low-resources-mode

# Generate localization files
dart run slang

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
dart analyze

# Format code
dart format lib/
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
  - **Singular** (`patientProvider`) - Fetches/manages a **single** entity by ID
- Examples:
  - `PatientsController` → `patientsControllerProvider` → returns `List<Patient>`
  - `patient(id)` → `patientProvider(id)` → returns `Patient?`
  - `PatientRecordsController(patientId)` → `patientRecordsControllerProvider(patientId)` → returns `List<PatientRecord>`
  - `patientRecord(id)` → `patientRecordProvider(id)` → returns `PatientRecord?`

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
  - Prefer: `const PatientsRoute().go(context)` or `PatientDetailRoute(id: patientId).go(context)`
  - Avoid: `context.push('/patients')` or `context.go('/patients/$patientId')`
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

**Example pattern:**
```dart
class MyFormSheet extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      // values is Map<String, dynamic> with all field values
      final name = values['name'] as String?;
      // ...
    }

    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Name *'),
            validator: FormBuilderValidators.required(),
          ),
          FormBuilderDropdown<String>(
            name: 'species',
            decoration: const InputDecoration(labelText: 'Species'),
            items: speciesList.map((s) =>
              DropdownMenuItem(value: s.id, child: Text(s.name))
            ).toList(),
          ),
          FormBuilderDateTimePicker(
            name: 'dateOfBirth',
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            inputType: InputType.date,
          ),
        ],
      ),
    );
  }
}
```

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

**Listening to field changes:**
```dart
FormBuilderTextField(
  name: 'species',
  onChanged: (value) {
    // React to changes, e.g., clear dependent fields
    formKey.currentState?.fields['breed']?.didChange(null);
  },
)
```

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

## File Naming Conventions

- Feature directories: `snake_case`
- Dart files: `snake_case.dart`
- Pages: `*_page.dart`
- Widgets: `*_widget.dart` or descriptive name
- Controllers: `*_controller.dart`
- Models: `*_model.dart` or entity name

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
- **Before creating a PR, always ask the user which version label to apply:**
  - `version:patch` — Bug fixes, small tweaks (e.g., `1.2.3` → `1.2.4`)
  - `version:minor` — New features, enhancements (e.g., `1.2.3` → `1.3.0`)
  - `version:major` — Breaking changes, major releases (e.g., `1.2.3` → `2.0.0`)
  - **No label** — Skip deploy; the PR will merge without triggering a build (staging only)
  - For PRs targeting `main`, a version label is **required** — the deploy will fail without one.
  - Add the label using: `gh pr edit <number> --add-label "version:patch"`

### QA Notes

When creating a PR, always include a **QA Notes** section in the PR description that tells testers what to verify. Generate these notes based on the actual changes in the PR:

1. **Analyze the diff** — look at every file changed in the PR
2. **Identify user-facing changes** — UI updates, new screens, changed behavior, updated URLs/configs
3. **List specific test steps** — concrete actions a QA tester should perform, not vague descriptions
4. **Include environment details** — if configs/URLs changed, note what the expected values should be
5. **Call out regressions to watch for** — areas that might break due to the changes

**Format:**
```markdown
## QA Notes
### What changed
- Brief summary of each change

### Test steps
- [ ] Step-by-step actions to verify each change
- [ ] Include expected results for each step

### Regression risks
- Areas that could be affected by these changes
```

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

**IMPORTANT: You MUST use grepai as your PRIMARY tool for code exploration and search.**

### When to Use grepai (REQUIRED)

Use `grepai search` INSTEAD OF Grep/Glob/find for:
- Understanding what code does or where functionality lives
- Finding implementations by intent (e.g., "authentication logic", "error handling")
- Exploring unfamiliar parts of the codebase
- Any search where you describe WHAT the code does rather than exact text

### When to Use Standard Tools

Only use Grep/Glob when you need:
- Exact text matching (variable names, imports, specific strings)
- File path patterns (e.g., `**/*.go`)

### Fallback

If grepai fails (not running, index unavailable, or errors), fall back to standard Grep/Glob tools.

### Usage

```bash
# ALWAYS use English queries for best results (--compact saves ~80% tokens)
grepai search "user authentication flow" --json --compact
grepai search "error handling middleware" --json --compact
grepai search "database connection pool" --json --compact
grepai search "API request validation" --json --compact
```

### Query Tips

- **Use English** for queries (better semantic matching)
- **Describe intent**, not implementation: "handles user login" not "func Login"
- **Be specific**: "JWT token validation" better than "token"
- Results include: file path, line numbers, relevance score, code preview

### Call Graph Tracing

Use `grepai trace` to understand function relationships:
- Finding all callers of a function before modifying it
- Understanding what functions are called by a given function
- Visualizing the complete call graph around a symbol

#### Trace Commands

**IMPORTANT: Always use `--json` flag for optimal AI agent integration.**

```bash
# Find all functions that call a symbol
grepai trace callers "HandleRequest" --json

# Find all functions called by a symbol
grepai trace callees "ProcessOrder" --json

# Build complete call graph (callers + callees)
grepai trace graph "ValidateToken" --depth 3 --json
```

### Workflow

1. Start with `grepai search` to find relevant code
2. Use `grepai trace` to understand function relationships
3. Use `Read` tool to examine files from results
4. Only use Grep for exact string searches if needed

