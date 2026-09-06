# Deployment & CI/CD

This document describes the GitHub Actions deployment pipeline, branching strategy, and required configuration.

---

## Table of Contents

1. [Branching Strategy](#branching-strategy)
2. [Workflow Files](#workflow-files)
3. [Deployment Flows](#deployment-flows)
4. [Required GitHub Secrets](#required-github-secrets)
5. [GitHub Environment Setup](#github-environment-setup)
6. [Server-Side Requirements](#server-side-requirements)
7. [Build-Time Dart Defines](#build-time-dart-defines)
8. [Android Signing](#android-signing)
9. [Version Management](#version-management)
10. [Build Artifacts & Caching](#build-artifacts--caching)
11. [Platform Support](#platform-support)

---

## Branching Strategy

```
feature branch → staging → main
```

- **All development PRs** merge into `staging`.
- **Only `staging`** can merge into `main` (enforced by `branch-protection.yml`).
- Adding the `deploy` label on a staging PR auto-creates a release PR to `main`.

---

## Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | Main deployment — staging + production builds and releases |
| `scripts/deploy.sh` | SSH/rsync deploy helper invoked by `deploy.yml` |
| `.github/workflows/auto-promote.yml` | Auto-creates a PR from `staging` → `main` when a merged PR has the `deploy` label |
| `.github/workflows/branch-protection.yml` | Blocks PRs to `main` that don't originate from `staging` |

---

## Deployment Flows

### Version labels & release tags

Same model as sannjose_animal_clinic:

| PR label | Effect |
|----------|--------|
| `version:patch` | Bump patch, deploy staging |
| `version:minor` | Bump minor, deploy staging |
| `version:major` | Bump major, deploy staging |
| `deploy` | After merge to staging, open staging→main PR (**requires a `version:*` label too**) |
| `web-only` | Build/deploy **web only** — skip Java, keystore, Android APK, and APK release artifacts. Forwarded to the staging→main PR by auto-promote. |
| *(none, staging only)* | Merge without deploy |
| `minimum version` | *(main only)* Also set minimum required app version |

| Environment | GitHub Release tag | Release title |
|-------------|--------------------|---------------|
| Staging | `staging-X.Y.Z` (or `staging-X.Y.Z-build.N` if tag exists) — prerelease + APK (APK omitted when `web-only`) | `Deploy X.Y.Z to Staging` |
| Production | `vX.Y.Z` — full release + APK (APK omitted when `web-only`) | `vX.Y.Z` |

Auto-promote opens the staging→main PR as **`vX.Y.Z`** (adds `(web-only)` when applicable). The Actions run name uses that PR title.

Manual **Actions → Deploy System → Run workflow** also asks for `version_bump` (`patch` / `minor` / `major`) and optional `web_only`.

### Staging Deployment

**Trigger:** PR merged to `staging` with a `version:*` label, or manual `workflow_dispatch`.

```
PR merged to staging (or manual dispatch)
  │
  ├─ Validate all required secrets exist
  ├─ Setup: Java 17 (Zulu) + Flutter 3.38.3
  ├─ Restore caches (Gradle, Pub, Flutter build)
  ├─ flutter pub get
  │
  ├─ Fetch current version from Version Manager API
  │   → Increment patch → append "-staging" suffix
  │   → Resolve unique tag (append build number if tag exists)
  │
  ├─ Decode KEYSTORE_BASE64 → upload-keystore.jks
  │
  ├─ Build Web (--release --source-maps)
  │   --dart-define=ENV=staging
  │   --dart-define=API_URL=$POCKETBASE_URL_STAGING
  │
  ├─ Build APK (--release, signed) — skipped when `DEPLOY_WEB_ONLY` / `web-only`
  │
  ├─ dart run sentry_dart_plugin (source maps + debug symbols → Sentry project `hzn-gyms`)
  ├─ Strip `*.map` from `build/web` so they are not served from pb_public
  │
  ├─ Setup SSH agent + known_hosts
  ├─ rsync web build → staging server pb_public/
  ├─ rsync migrations → staging server pb_migrations/
  ├─ rsync hooks → staging server pb_hooks/
  ├─ Restart PocketBase staging service
  │
  └─ Create GitHub Release (prerelease)
      Tag: staging-X.Y.Z[-build.N]
      Title: Deploy X.Y.Z to Staging
      Artifact: app-release.apk
```

### Production Deployment

**Trigger:** PR merged to `main` (must come from `staging`). Cannot be triggered manually.

```
PR merged to main
  │
  ├─ "Production" environment approval gate
  │
  ├─ [deploy-production job]
  │   ├─ Validate all required secrets exist
  │   ├─ Setup: Java 17 (Zulu) + Flutter 3.38.3
  │   ├─ Restore caches (Gradle, Pub, Flutter build)
  │   ├─ flutter pub get
  │   │
  │   ├─ Fetch current version from Version Manager API
  │   │   → Increment patch (no suffix)
  │   │
  │   ├─ Decode KEYSTORE_BASE64 → upload-keystore.jks
  │   │
  │   ├─ Build Web (--release --source-maps)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │   --dart-define=SENTRY_DSN=$SENTRY_DSN_PROD
  │   │
  │   ├─ Build APK (--release, signed) — skipped when `DEPLOY_WEB_ONLY` / `web-only`
  │   │
  │   ├─ dart run sentry_dart_plugin (source maps + debug symbols)
  │   ├─ Strip `*.map` from `build/web`
  │   │
  │   ├─ Setup SSH agent + known_hosts
  │   ├─ rsync web build → production server pb_public/
  │   ├─ rsync migrations → production server pb_migrations/
  │   ├─ rsync hooks → production server pb_hooks/
  │   ├─ Restart PocketBase production service
  │   │
  │   └─ Upload APK as GitHub Actions artifact
  │
  └─ [release-and-sync job] (depends on deploy-production)
      ├─ Download APK artifact
      ├─ Create GitHub Release
      │   Tag: vX.Y.Z
      │   Title: vX.Y.Z
      │   Artifact: app-release.apk
      └─ PATCH Version Manager API with new version
```

### Auto-Promote Flow

**Trigger:** PR with `deploy` label merged to `staging`.

```
Labeled PR merged to staging
  │
  ├─ Check if an open staging → main PR already exists
  │   └─ If yes → skip
  │
  └─ Create PR: staging → main
      Title: "vX.Y.Z" (or "vX.Y.Z (web-only)")
      Body: includes source PR number and title
```

---

## Required GitHub Secrets

These must be configured in **Settings → Secrets and variables → Actions**.

| Secret | Required | Used In | Description |
|--------|----------|---------|-------------|
| `VERSION_MANAGER_URL` | Yes | Staging & Production | PocketBase API endpoint for version tracking |
| `VERSION_COLLECTION_ID` | Yes | Staging & Production | Record ID in the version collection |
| `POCKETBASE_URL_STAGING` | Yes | Staging | Staging PocketBase backend URL |
| `POCKETBASE_URL_PROD` | Yes | Production | Production PocketBase backend URL |
| `KEYSTORE_BASE64` | Yes | Staging & Production | Base64-encoded Android signing keystore (`.jks`) |
| `KEYSTORE_PASSWORD` | Yes | Staging & Production | Keystore store password |
| `KEY_ALIAS` | Yes | Staging & Production | Key alias within the keystore |
| `KEY_PASSWORD` | Yes | Staging & Production | Key password |
| `SSH_HOST` | Yes | Staging & Production | Server hostname or IP for SSH deployment |
| `SSH_USER` | Yes | Staging & Production | SSH username (e.g., `deploy`) |
| `SSH_PRIVATE_KEY` | Yes | Staging & Production | Ed25519 or RSA private key (PEM format) for SSH authentication |
| `SENTRY_AUTH_TOKEN` | Yes | Staging & Production | Sentry auth token for `sentry_dart_plugin` (org `christian-hizon`, project `hzn-gyms`) |
| `SENTRY_DSN_PROD` | Yes | Production | Production Sentry DSN (`--dart-define=SENTRY_DSN`). Staging builds do not initialize the SDK. |
| `PB_TOKEN` | Optional | Production (release-and-sync) | Auth token for PATCH-ing the Version Manager after release |

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

---

## GitHub Environment Setup

A **"Production"** environment must be created in the repository:

**Settings → Environments → New environment → "Production"**

This environment acts as an approval gate — production deploys require manual approval before running.

---

## Server-Side Requirements

Both staging and production deploy to the **same server** via SSH. The following must be configured on the server:

### SSH Access
- The `SSH_USER` must have `authorized_keys` configured with the public key matching `SSH_PRIVATE_KEY`
- `rsync` must be installed on the server

### Directory Permissions

The SSH user needs write access to:

| Path | Purpose |
|------|---------|
| `/opt/pocketbase/hzn_gyms_staging/pb_public/` | Staging web build |
| `/opt/pocketbase/hzn_gyms_staging/pb_migrations/` | Staging PocketBase migrations |
| `/opt/pocketbase/hzn_gyms_staging/pb_hooks/` | Staging PocketBase hooks |
| `/opt/pocketbase/hzn_gyms/pb_public/` | Production web build |
| `/opt/pocketbase/hzn_gyms/pb_migrations/` | Production PocketBase migrations |
| `/opt/pocketbase/hzn_gyms/pb_hooks/` | Production PocketBase hooks |

### Passwordless Sudo

The SSH user needs passwordless sudo for restarting PocketBase services. Configured on the server as `/etc/sudoers.d/deploy-hzn-gyms`:

```
deploy-hzngyms ALL=(root) NOPASSWD: /bin/systemctl restart pocketbase_hzn_gyms.service, /bin/systemctl restart pocketbase_hzn_gyms_staging.service
```

Legacy Kylie Gym paths/services remain on the same host but are **not** deploy targets for this repo.

---

## Build-Time Dart Defines

Injected at compile time via `--dart-define`:

| Define | Staging Value | Production Value | Purpose |
|--------|--------------|-----------------|---------|
| `ENV` | `staging` | `prod` | Selects environment configuration |
| `API_URL` | `$POCKETBASE_URL_STAGING` | `$POCKETBASE_URL_PROD` | Backend API endpoint |

---

## Android Signing

The APK build step sets these environment variables, which are read by `android/app/build.gradle.kts`:

| Variable | Source | Purpose |
|----------|--------|---------|
| `CI` | Hardcoded `"true"` | Signals CI environment |
| `CM_KEYSTORE_PATH` | Path to decoded `.jks` file | Keystore file location |
| `CM_KEYSTORE_PASSWORD` | `KEYSTORE_PASSWORD` secret | Keystore password |
| `CM_KEY_ALIAS` | `KEY_ALIAS` secret | Key alias |
| `CM_KEY_PASSWORD` | `KEY_PASSWORD` secret | Key password |

**Signing logic in `build.gradle.kts`:**
- If `CI=true` and `CM_KEYSTORE_PATH` is set → uses CI environment variables
- Otherwise → falls back to local `android/key.properties` file

### Generating `KEYSTORE_BASE64`

To encode your keystore for the secret:

```bash
base64 -i your-keystore.jks | pbcopy   # macOS (copies to clipboard)
base64 -w 0 your-keystore.jks          # Linux (outputs to stdout)
```

---

## Version Management

Versions are tracked via an external PocketBase instance (the "Version Manager").

### How It Works

1. A single PocketBase record stores `major`, `minor`, `patch` fields.
2. **Staging builds** fetch the current version, increment patch, and append `-staging`.
3. **Production builds** fetch the current version, increment patch (no suffix).
4. After a production release, the `release-and-sync` job PATCHes the record with the new patch number.

### Version Formats

| Environment | Version Format | Tag Format | Release title | Example |
|-------------|---------------|------------|---------------|---------|
| Staging | `X.Y.Z-staging` | `staging-X.Y.Z` or `staging-X.Y.Z-build.N` | `Deploy X.Y.Z to Staging` | `1.2.4-staging` / `staging-1.2.4-build.42` |
| Production | `X.Y.Z` | `vX.Y.Z` | `vX.Y.Z` | `1.2.4` / `v1.2.4` |

---

## Build Artifacts & Caching

### Caching Strategy

| Cache | Key | Scope |
|-------|-----|-------|
| Gradle | Managed by `actions/setup-java` | Shared |
| Pub dependencies | `{os}-pub-{hash(pubspec.lock)}` | Shared |
| Flutter build | `{os}-flutter-build-{staging\|prod}-{hash(lib/**, pubspec.lock)}` | Per environment |

Staging and production have **separate** Flutter build caches to prevent conflicts.

### Artifacts

| Environment | Artifact | Destination |
|-------------|----------|-------------|
| Staging | APK | GitHub Release (prerelease) |
| Production | APK | GitHub Actions artifact → GitHub Release (public) |
| Both | Web build | Auto-deployed to server via SSH (rsync) |

---

## Platform Support

| Platform | CI/CD Status | Notes |
|----------|-------------|-------|
| Android (APK) | Disabled | `DEPLOY_WEB_ONLY=true` in deploy workflows — HZN Gyms is web-only |
| Web | Fully automated | Standard builds for both environments. Auto-deployed via SSH/rsync to PocketBase `pb_public/`. |
| iOS | Not configured | Would require macOS runner + signing certificates |
| macOS | Not configured | Would require macOS runner |
| Linux | Not configured | Could use standard Ubuntu runner |
| Windows | Not configured | Would require Windows runner |

---

## Deploy Script (`scripts/deploy.sh`)

Shared bash script used by GitHub Actions (and local Linux/macOS emergency deploys). After SSH agent + known_hosts setup, it:

1. `rsync --delete` `build/web/` → `pb_public/`
2. `rsync --delete` `server/pb_migrations/` → `pb_migrations/`
3. `rsync --delete` `server/pb_hooks/` → `pb_hooks/`
4. `systemctl restart` the PocketBase service

**Required env:** `SSH_HOST`, `SSH_USER`

```bash
# CI (already wired in deploy.yml)
./scripts/deploy.sh staging
./scripts/deploy.sh prod

# Partial deploys
./scripts/deploy.sh staging --hooks-only
./scripts/deploy.sh staging --migrations-only
./scripts/deploy.sh prod --restart-only
```

| Environment | Server root | Service | Port | URL |
|-------------|-------------|---------|------|-----|
| staging | `/opt/pocketbase/hzn_gyms_staging` | `pocketbase_hzn_gyms_staging.service` | 8107 | https://staging.hzngyms.hznsystems.com |
| prod | `/opt/pocketbase/hzn_gyms` | `pocketbase_hzn_gyms.service` | 8106 | https://hzngyms.hznsystems.com |

---

## Quick Reference: Staging vs Production

| Aspect | Staging | Production |
|--------|---------|-----------|
| **Trigger** | PR merged to `staging` or manual dispatch | PR merged to `main` only |
| **Manual dispatch** | Yes | No |
| **Approval gate** | None | "Production" environment approval |
| **Version suffix** | `-staging` | None |
| **Release type** | Prerelease | Public release |
| **Web build** | Standard, deployed via SSH | Standard, deployed via SSH |
| **Version Manager** | Not updated | Updated after release |
