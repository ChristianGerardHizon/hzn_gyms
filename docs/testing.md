# Testing

## Demo Account

email: test@test.com  
password: password101

## Unit tests

Run the suite:

```bash
flutter test
```

Layout mirrors `lib/src/`:

- `test/core/` — utils, foundation, PocketBase filters, sync helpers
- `test/features/` — domain rules and orchestrator/controller coverage
- `test/helpers/` — shared fixtures and `mocktail` mocks

Dependencies: `flutter_test`, `mocktail`.

Covered in the first pass:

- Core: date/membership stacking, `PBFilter`, `Failure` / `ErrorDisplayInfo`, pagination, sort, currency, file validation, outbox helpers
- Domain: memberships, cart pricing, sale payment status, product stock/expiry, user roles, check-in results
- Orchestrators: offline `MembershipPurchaseOrchestrator`, `CheckInController.cardCheckIn`, `CheckoutController.processCheckout`

## Coverage

Requires a one-time install of [`coverde`](https://pub.dev/packages/coverde) (no `sudo` needed):

```bash
dart pub global activate coverde
# ensure ~/.pub-cache/bin is on PATH
```

Generate and summarize (excludes generated `*.g.dart` / `*.mapper.dart`):

```bash
flutter test --coverage

coverde filter \
  -i coverage/lcov.info \
  -o coverage/filtered.lcov.info \
  -m w \
  -f '\.g\.dart$,\.mapper\.dart$,assets\.gen\.dart$'

coverde value -i coverage/filtered.lcov.info --file-coverage-log-level overview

# HTML report
coverde report -i coverage/filtered.lcov.info -o coverage/html
# open coverage/html/index.html
```

`coverage/` is gitignored.
