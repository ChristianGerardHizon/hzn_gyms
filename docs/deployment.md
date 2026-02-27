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
- Adding the `promote-to-main` label on a staging PR auto-creates a release PR to `main`.

---

## Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | Main deployment — staging + production builds and releases |
| `.github/workflows/auto-promote.yml` | Auto-creates a PR from `staging` → `main` when a merged PR has the `promote-to-main` label |
| `.github/workflows/branch-protection.yml` | Blocks PRs to `main` that don't originate from `staging` |

---

## Deployment Flows

### Staging Deployment

**Trigger:** PR merged to `staging`, or manual `workflow_dispatch`.

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
  ├─ Build Web (--release)
  │   --dart-define=ENV=staging
  │   --dart-define=API_URL=$POCKETBASE_URL_STAGING
  │
  ├─ Build APK (--release, signed)
  │   --dart-define=ENV=staging
  │   --dart-define=API_URL=$POCKETBASE_URL_STAGING
  │
  ├─ Setup SSH agent + known_hosts
  ├─ rsync web build → staging server pb_public/
  ├─ rsync migrations → staging server pb_migrations/
  ├─ Restart PocketBase staging service
  │
  └─ Create GitHub Release (prerelease)
      Tag: staging-X.Y.Z[-build.N]
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
  │   ├─ Build Web (--release)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │
  │   ├─ Build APK (--release, signed)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │
  │   ├─ Setup SSH agent + known_hosts
  │   ├─ rsync web build → production server pb_public/
  │   ├─ rsync migrations → production server pb_migrations/
  │   ├─ Restart PocketBase production service
  │   │
  │   └─ Upload APK as GitHub Actions artifact
  │
  └─ [release-and-sync job] (depends on deploy-production)
      ├─ Download APK artifact
      ├─ Create GitHub Release
      │   Tag: vX.Y.Z
      │   Artifact: app-release.apk
      └─ PATCH Version Manager API with new version
```

### Auto-Promote Flow

**Trigger:** PR with `promote-to-main` label merged to `staging`.

```
Labeled PR merged to staging
  │
  ├─ Check if an open staging → main PR already exists
  │   └─ If yes → skip
  │
  └─ Create PR: staging → main
      Title: "Release: promote staging to main"
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
| `/opt/pocketbase/hizonelaundry-staging/pb_public/` | Staging web build |
| `/opt/pocketbase/hizonelaundry-staging/pb_migrations/` | Staging PocketBase migrations |
| `/opt/pocketbase/hizonelaundry/pb_public/` | Production web build |
| `/opt/pocketbase/hizonelaundry/pb_migrations/` | Production PocketBase migrations |

### Passwordless Sudo

The SSH user needs passwordless sudo for restarting PocketBase services. Add to `/etc/sudoers.d/deploy`:

```
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart pocketbase_hizonelaundry-staging.service
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart pocketbase_hizonelaundry.service
```

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

| Environment | Version Format | Tag Format | Example |
|-------------|---------------|------------|---------|
| Staging | `X.Y.Z-staging` | `staging-X.Y.Z` or `staging-X.Y.Z-build.N` | `1.2.4-staging` / `staging-1.2.4-build.42` |
| Production | `X.Y.Z` | `vX.Y.Z` | `1.2.4` / `v1.2.4` |

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
| Android (APK) | Fully automated | Signed release builds for both environments |
| Web | Fully automated | Standard builds for both environments. Auto-deployed via SSH/rsync to PocketBase `pb_public/`. |
| iOS | Not configured | Would require macOS runner + signing certificates |
| macOS | Not configured | Would require macOS runner |
| Linux | Not configured | Could use standard Ubuntu runner |
| Windows | Not configured | Would require Windows runner |

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
