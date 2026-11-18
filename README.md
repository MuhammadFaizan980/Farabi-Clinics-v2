# Farabi Booking App

Patient-facing booking app for Farabi Clinics (iOS + Android, Flutter).
It consumes the same backend the v2 website uses — no new endpoints, no mock backend.

## Status

| Phase | Scope | State |
| :--- | :--- | :--- |
| 0 | Foundation — flavors, `EndPoints`, `ApiClient`, base classes, DI, tokens, mappers | Done |
| 1 | Auth — splash/session restore, login, register, OTP, forgot/reset, logout | Done, verified live |
| 2 | App shell — bottom nav, routing, shared loading/empty/error widgets | Done |
| 3 | Tab main screens — Home, Doctors, Branches, Specialities, More | Done |
| 4 | Detail screens — doctor, branch, speciality → service | Done |
| 5 | Booking flow — service → branch → slot → checkout-context → confirm | Done for cash/immediate payment; gateway redirect leg and Qitaf not wired |
| 6 | Bookings — list, filters, cancel, reschedule | Done, verified live |
| 7 | Profile — view and edit | Done |
| 8 | Static & support — contact us, careers, blogs | Done |
| 9 | Hardening & release — localisation guards, RTL, a11y, release builds | Done |
| 10 | **Pixel perfection** — match the Figma frames exactly | **Not started, deliberately.** Gated on readable Figma measurements; see `docs/figma-access-findings.md` |

## Running it

```bash
flutter pub get
flutter run -t lib/main_dev.dart     # dev flavor
flutter run -t lib/main_prod.dart    # prod flavor
```

`lib/main.dart` just forwards to the dev entrypoint so a bare `flutter run` works.

## Tests

```bash
flutter analyze                                   # must be clean
flutter test                                      # 96 offline unit tests
flutter test --tags live --run-skipped            # 25 tests against the real dev API
flutter test integration_test -d <device-id>      # 11 UI tests on a simulator
```

The live and integration tests hit the real dev API and write to it (they register a
throwaway patient), so they are tagged and excluded from the default run.

## Architecture

One direction only:

```
Screen  →  ViewModel  →  Repo (abstract + Imp)  →  ApiClient (Dio)
                              ↓
                           Mapper
```

- A screen reads state from, and calls methods on, its view model. Nothing else.
- A view model only talks to repos resolved from `GetIt`. It never sees Dio or the API client.
- A repo never contains widgets, `BuildContext` or navigation. It hands raw payloads to a mapper.
- `ApiClient` is the only file that knows about Dio, base URLs, headers and status codes.
- No endpoint string exists outside `EndPoints`.
- No JSON parsing happens outside `lib/mappers/`.

## API contract worth knowing

Details and captured samples are in `docs/api-inventory.md` and
`docs/api-inventory-addendum.md`. The things that bite:

- **Headers.** Every request carries `device: 1`, `lang`, `country-code` and the bearer.
  `country-code` is a real data scope — `sa` returns 9 branches, `eg` returns 0. Wrong header
  means silently empty screens, which is why the session is restored before any screen can
  fire a request.
- **One envelope.** `{ status, data, meta }` on success, `{ status, message[], code }` on
  failure. On a **422 the `data` slot holds the field errors**, not a payload — `ApiClient`
  keys that off `code == 422`.
- **There is no token refresh.** The API has no refresh endpoint. The contract is
  validate-on-boot (`GET v1/portal/profile`) and hard logout on any later 401. Token-issuing
  endpoints are excluded from that, so a wrong password surfaces on the login screen instead
  of logging the user out.
- **Mobile numbers keep their leading zero** (`0564772491`), with `country_code` sent
  separately on register.
- **Booking list `status` is an integer, not a string.** 1 = Created, 6 = Cancelled. The
  website sends strings and gets a 422 on every call, which is why its booking history is
  always empty. Don't copy it.
- **Timestamps.** A naked `YYYY-MM-DD HH:MM:SS` is read as Asia/Riyadh local; a `Z`-suffixed
  string is read as UTC. Responses always come back UTC.
- Prices are **decimal strings** (`"45.00"`), not numbers.

## Design tokens

Colours come from the website's own CSS custom properties, so the app and site cannot drift:
`--color-primary #c21c22`, `--color-secondary #222`, `--color-error #ea5454`, and the grey ramp.
See `lib/utils/color/app_colors.dart`.

Layout geometry is matched visually against the Figma frames — Dev Mode inspect is paywalled on
the current Figma plan, so exact spacing values are not machine-readable.

**Icons are the open asset gap**: 122 icon paths are referenced by the website but 404 at every
URL, so they still need exporting from the Figma `Components` page.

## Conventions

- Repo pair: `LoginRepo` (abstract) + `LoginRepoImp`.
- Screen + VM pair: `DoctorsListScreen` + `DoctorsListVm`.
- Models suffixed `...RequestModel`, `...ResponseModel`, `...DataModel`, `...ArgsModel`.
- Request models expose `String? validate()` returning a `LocaleKeys` entry or null.
- Private VM fields with `_`; all getters grouped at the bottom under
  `/// getters/setters below this line...`.
- Every user-facing string goes through `LocaleKeys` + `.tr()`. `en-US` and `ar-SA` are kept at
  full key parity.
- Every dimension goes through `lib/utils/extensions/responsive_extensions.dart`
  (`12.rw`, `16.rh`, `14.rf`). No raw pixel literals.

## Release builds

Both verified:

```bash
flutter build ios --release --no-codesign -t lib/main_dev.dart
flutter build ios --release --no-codesign -t lib/main_prod.dart
flutter build apk --release -t lib/main_prod.dart
```

## Known gaps

- `EndPoints.baseUrlProd` still points at the dev host — the production URL is unknown.
- Booking list statuses 2–5 are accepted by the API but unnamed; only 1 and 6 are confirmed.
- `offers` and `blog` return empty arrays on dev, so their item shapes are unverified.
- No API exists for reviews, notifications, or terms/privacy.
- The **gateway payment leg** (PayTabs / Tabby / Tamara redirect and
  `pending-bookings/{id}/confirm`) is not wired; cash and other immediate methods complete.
  **Qitaf** loyalty redemption is likewise not built. Both await a v1 scope decision.
- The **careers application form** is not built — it is a 17-field multipart submission with a CV
  upload, and testing it would file real applications.
- Icons: 122 paths referenced by the website 404 at every URL, so the icon set still has to come
  out of Figma's `Components` page.
