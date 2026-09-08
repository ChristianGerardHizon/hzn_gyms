# Auth email templates

Source of truth for HZN Gyms PocketBase auth emails. HTML lives in [`docs/email-templates/`](email-templates/). Apply via Admin API — never hand-edit `server/pb_migrations/`.

## Brand tokens

| Token | Value | Use |
|-------|-------|-----|
| Header background | `#0B0B0B` | Top bar |
| Accent / CTA | `#22C55E` | Header underline + buttons |
| Page background | `#F3F4F6` | Outer email canvas |
| Card | `#FFFFFF` | Content panel |
| Body text | `#111827` / `#374151` | Titles / copy |

Layout: table-based, inline CSS only (Gmail/Outlook-safe). Dark header + green accent mirrors the login screen without a full dark email body.

## Templates (`users` collection)

| File | PocketBase field | Subject | Placeholders |
|------|------------------|---------|--------------|
| `otp.html` | `otp.emailTemplate` | Your {APP_NAME} login code | `{APP_NAME}`, `{OTP}` |
| `verification.html` | `verificationTemplate` | Verify your {APP_NAME} email | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `reset-password.html` | `resetPasswordTemplate` | Reset your {APP_NAME} password | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `confirm-email-change.html` | `confirmEmailChangeTemplate` | Confirm your new {APP_NAME} email | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `auth-alert.html` | `authAlert.emailTemplate` | New login to your {APP_NAME} account | `{APP_NAME}`, `{ALERT_INFO}` |

### Link targets

- **Verification** → Flutter route: `{APP_URL}/confirm-verification/{TOKEN}`
- **Password reset** → PocketBase UI (no Flutter confirm page yet): `{APP_URL}/_/#/auth/confirm-password-reset/{TOKEN}`
- **Email change** → PocketBase UI: `{APP_URL}/_/#/auth/confirm-email-change/{TOKEN}`

OTP settings applied with the templates: `enabled: true`, `duration: 180`, `length: 6`.

## Apply to an environment

Credentials from `.env` (names only):

| Target | URL | Email | Password |
|--------|-----|-------|----------|
| local | `LOCAL_API_URL` | `LOCAL_EMAIL` | `LOCAL_PASSWORD` |
| staging | `STAGING_URL` | `STAGING_EMAIL` | `STAGING_PASSWORD` |
| prod | `PROD_URL` | `PROD_EMAIL` | `PROD_PASSWORD` |

```powershell
# From repo root (loads .env automatically)
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 local
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 staging
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\patch-email-templates.ps1 prod
```

Local requires PocketBase running at `LOCAL_API_URL` (usually `http://localhost:8090`).

SMTP/Resend is configured separately in PocketBase Settings → Mailer (`RESEND_*` in `.env`). This script only patches collection email templates.

## QA checklist

1. Request a login code → email shows large 6-digit OTP and HZN header.
2. Wrong/expired code in app → **"Invalid or expired login code."** (not credentials).
3. New staff verification email → CTA opens `/confirm-verification/{token}` on the app host.
4. Forgot password → branded reset email still opens PB confirm UI.
5. Repeat after applying to staging and prod.
