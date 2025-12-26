# Testing guide

This project includes unit, widget and integration tests. Below are the commands and notes to run and maintain the test suite.

## Run all tests


- Run full suite locally:

```bash
flutter test -r expanded
```

- Run a specific folder:

```bash
flutter test test/unit
flutter test test/widget
flutter test test/integration
```

## Coverage

Generate coverage report (LCOV):

```bash
flutter test --coverage
# lcov info is in coverage/lcov.info
```

## Golden tests

Golden tests are available under `test/golden`. By default they are skipped; to generate or update golden files run:

```bash
export updateGoldens=true
flutter test --update-goldens
```

This will produce images in `test/goldens/`. Commit them if they represent the intended UI.

## CI

A GitHub Actions workflow is installed at `.github/workflows/ci.yml`. It runs `flutter analyze`, `flutter pub get` and the tests and uploads coverage. To update goldens in CI, set the `UPDATE_GOLDENS` environment variable to `'true'` in the workflow or via a manual run.

## Test strategies & notes

- Widget tests avoid `pumpAndSettle` when possible and use deterministic `pump` with short durations to reduce flakiness (especially when `flutter_map` emits tile requests/timers).
- Tests that use Riverpod widgets should wrap widgets with `ProviderScope` and, when needed, override providers to inject deterministic test data (see integration tests in `test/integration`).
- Keep golden updates explicit; changing UIs should be accompanied by golden updates and review.

If you want, I can:
- Add more golden baselines (extra screens),
- Enforce minimum coverage in CI and fail on low coverage,
- Add Flutter integration_test-based e2e tests (takes more setup).

Tell me which of those you want next and I’ll implement it.