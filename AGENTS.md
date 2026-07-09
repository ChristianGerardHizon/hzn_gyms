# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains all Dart source. Entry point is `lib/main.dart`.
- `lib/src/core/` holds shared app infrastructure (routing, widgets, utils, models).
- `lib/src/features/` is organized by domain modules (members, products, memberships, check_in, etc.) with `data/`, `domain/`, and `presentation/` layers.
- `assets/` contains static assets and icons.
- `test/` mirrors the `lib/` structure for unit/widget tests.
- `docs/` includes architecture references (entities, UI, folder structure).

## Build, Test, and Development Commands
```bash
# Install dependencies
 dart pub get

# Code generation (mappers, routes, etc.)
 dart run build_runner build --delete-conflicting-outputs

# Generate localization files
 dart run slang

# Run the app (device/emulator)
 flutter run

# Run tests
 flutter test

# Static analysis and formatting
 dart analyze
 dart format lib/
```
Use `flutter run` for local development; run `build_runner` and `slang` after model/route/i18n updates.

## Coding Style & Naming Conventions
- Formatting: use `dart format lib/` before committing.
- Linting: follow `flutter_lints` and `custom_lint` (`analysis_options.yaml`), and address `dart analyze` warnings.
- File naming: `snake_case.dart` (e.g., `members_controller.dart`).
- Pages: `*_page.dart`; controllers: `*_controller.dart`; widgets: `*_widget.dart`.
- Controllers are plural when they manage lists (e.g., `members_controller.dart`, `member_memberships_controller.dart`).
- Single-entity providers use singular naming and live in `*_provider.dart` (e.g., `member_provider.dart`, `member_membership_provider.dart`).
- Feature folders use `snake_case` and follow the `data/`, `domain/`, `presentation/` pattern.

## Provider Setup
- Use `@riverpod` for providers and `@Riverpod` when keep-alive is needed.
- Keep list controllers and single-entity providers in separate files with their own `part` directives.
- Provider names should mirror singular/plural intent (e.g., `memberMembershipsControllerProvider` vs `memberMembershipProvider`).

## Testing Guidelines
- Framework: Flutter test runner (`flutter test`).
- Location: `test/` mirrors `lib/` paths.
- Naming: `*_test.dart` for unit/widget tests.
- Add tests for new logic in repositories, controllers, and utilities.

## Commit & Pull Request Guidelines
- Commits follow Conventional Commits (e.g., `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, `chore: ...`).
- PRs should include a clear summary, linked issue (if applicable), and a note of tests run.
- Include screenshots or screen recordings for UI changes.

## Agent-Specific Notes
- See `CLAUDE.md` for code patterns (Riverpod, routing, models) when making architectural changes.

### PocketBase Schema Changes
- **Do NOT create manual migration files** in `server/pb_migrations/`.
- Apply schema changes (collections, fields, indexes, views, API rules) via the **PocketBase Admin API** or admin UI.
- Credentials: `.env` (`PB_LOCAL_*` for local, `PB_STAGING_*` for staging).
- Auth: `POST /api/collections/_superusers/auth-with-password` → use returned `token`.
- Update: `PATCH /api/collections/{nameOrId}` with the changed fields (e.g. `indexes` array).
- PocketBase auto-generates migrations from API/UI changes; never hand-write `.js` migration files.


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

