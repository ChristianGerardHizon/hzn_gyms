# Auth email templates

Source of truth for HZN Gyms PocketBase auth emails. HTML lives in [`docs/email-templates/`](email-templates/). Apply via Admin API — never hand-edit `server/pb_migrations/`.

## Design goals (deliverability)

- Transactional tone only — no marketing urgency, ALL CAPS, or spam-trigger phrasing
- Single clear purpose per message; one primary CTA where needed
- Table layout, inline CSS, web-safe fonts (Gmail / Outlook safe)
- High text-to-image ratio; logo is the only image (`alt` set)
- Hidden preheader for inbox preview text
- Absolute logo URL: `{APP_URL}/email/hzn-logo.png` (shipped from [`web/email/`](../web/email/))
- Footer identifies HZN systems and states the message is automated

## Brand tokens

| Token | Value | Use |
|-------|-------|-----|
| Header | `#0B0B0B` | Brand bar |
| Accent (logo green) | `#02F268` | Accent bar + CTA fill |
| Link | `#047857` | Fallback URLs |
| Page | `#F4F5F7` | Outer background |
| Card | `#FFFFFF` | Content panel |
| Body / muted | `#111827` / `#4B5563` / `#6B7280` | Copy hierarchy |
| Logo | `{APP_URL}/email/hzn-logo.png` | 40×40 header mark |

Local preview copies also live in [`docs/email-templates/assets/`](email-templates/assets/).

## Templates (`users` collection)

| File | PocketBase field | Subject | Placeholders |
|------|------------------|---------|--------------|
| `otp.html` | `otp.emailTemplate` | Your {APP_NAME} sign-in code | `{APP_NAME}`, `{OTP}`, `{APP_URL}` |
| `verification.html` | `verificationTemplate` | Verify your {APP_NAME} email address | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `reset-password.html` | `resetPasswordTemplate` | Reset your {APP_NAME} password | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `confirm-email-change.html` | `confirmEmailChangeTemplate` | Confirm your new {APP_NAME} email address | `{APP_NAME}`, `{APP_URL}`, `{TOKEN}` |
| `auth-alert.html` | `authAlert.emailTemplate` | New sign-in to your {APP_NAME} account | `{APP_NAME}`, `{ALERT_INFO}`, `{APP_URL}` |

### Link targets

- **Verification** → Flutter route: `{APP_URL}/confirm-verification/{TOKEN}`
- **Password reset** → PocketBase UI: `{APP_URL}/_/#/auth/confirm-password-reset/{TOKEN}`
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

**Logo note:** `{APP_URL}/email/hzn-logo.png` is available after a web deploy that includes `web/email/`. Until then, logo images may be broken in received mail even though the HTML body still renders.

## QA checklist

1. Request a login code → formal OTP email with logo + large code; lands in inbox (not spam).
2. Wrong/expired code in app → **"Invalid or expired login code."** (not credentials).
3. Verification email → CTA opens `/confirm-verification/{token}` on the app host.
4. Forgot password → branded reset email still opens PB confirm UI.
5. Confirm logo loads from `{APP_URL}/email/hzn-logo.png` after web deploy.
6. Repeat after applying to staging and prod.
