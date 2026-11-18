# Farabi Booking App — delivery phases

Structured the way you asked: foundation, then auth, then each tab's main screen, then the nested
screens, then the flows that cut across tabs. Scope per phase is pinned to the endpoints verified in
`docs/api-inventory.md` — nothing here depends on an endpoint I haven't confirmed exists.

**Ground rules carried into every phase:** UI → VM → Repo → Mapper → ApiClient with no shortcuts;
zero hardcoded display strings (`LocaleKeys` + `.tr()` from day one, both `en-US` and `ar-SA`);
no raw pixel literals (everything through `sizer`); every async screen has loading / success /
empty / error-with-retry; pull-to-refresh on every data screen; unit tests only, per the updated DoD.

---

## Phase 0 — Foundation (no UI)

Unavoidably first: auth can't be built without the `ApiClient` it posts through.

- Flutter project, the full `lib/` skeleton, `pubspec.yaml`, assets and fonts declared
- `flutter_flavor` with `main_dev.dart` / `main_prod.dart` / `main_app.dart`
- `EndPoints` — all 39 paths, `baseUrlDev` wired (`baseUrlProd` left as a named constant pending **B1**)
- `ApiClient` — Dio singleton; the four context headers (`device`, `lang`, `country-code`, bearer);
  envelope normalisation into `ApiResponseModel` (`success`, `data`, `messages`, `fieldErrors`);
  `fieldErrors` from `data` on 422; **validate-on-boot / hard-logout on 401** (there is no refresh
  endpoint — see **B3**); dev-only logging that never prints tokens
- `AppBaseRepo` / `AppBaseVm` / `AppBaseModel` / `AppBaseMapper`
- `AppDi.initDi()` — core singletons first, **session and country restored before any screen can fire a request**
- `Sizer` + `EasyLocalization` + theme in `main_app.dart`; `navigatorKey`, `onGenerateRoute`
- Design tokens (see *Assets & tokens* below)
- Mappers + unit tests for the 14 end-to-end-verified endpoints

**Exit:** app boots in both flavors, `GET v1/portal/regions` renders through the full chain on a
throwaway smoke screen, `flutter analyze` clean, mapper tests green.

---

## Phase 1 — Auth

- Splash / bootstrap: restore token from secure storage → `GET v1/portal/profile` → restore or hard-logout
- Language selection (en / ar) persisted, applied before first request
- Login — mobile + password (`POST v1/portal/auth/login`)
- Register — first/last name, phone, password + confirmation, `citizen_id_number`,
  `citizen_id_type` picker (the 6 enum values are captured in the inventory)
- OTP verify (`otp/confirm`) with resend + **60s countdown** (`otp/resend`)
- Forgot password (`forgot-password`) → reset (`reset-password`)
- Logout; token only in `flutter_secure_storage`; phone normalised to national digits + `country_code`
- `validate()` on each request model, server `fieldErrors` mapped back onto the right inputs

**Blocked by:** **B6** (no test patient account — none of this can be verified end to end) and
**B4** (`reset-password` body fields unknown). See *Sequencing risk* below.

**Exit:** register → OTP → logged-in session that survives a cold start; wrong-password and
invalid-OTP paths show server messages; VM unit tests for validation and state transitions.

---

## Phase 2 — App shell

The chassis every tab plugs into. Small phase, pays for itself immediately.

- Bottom navigation + tab state, `app_routes.dart` + generator, typed `...ArgsModel` route arguments
- Auth guard: booking requires login (verified — `POST v1/portal/bookings` 401s for guests), so the
  flow must divert to login and **return to where the user left off**
- Shared widgets: shimmer skeletons, empty state, error-with-retry, paginated list (`page`,
  `meta.total`), pull-to-refresh wrapper
- RTL-correct base layout (`EdgeInsetsDirectional`, `start`/`end`, mirrored icons)

**Exit:** tabs navigate, guard works, every shared state widget renders in both locales and directions.

---

## Phase 3 — Tab main screens

All landing screens, breadth first — exactly as you described.

| Screen | Endpoints |
| :--- | :--- |
| **Home** | `services/main`, `home/branches`, `offers` |
| **Doctors** | `doctors` (+ `page`, `search`, `region_id`, `gender`, `ratings`) |
| **Branches** | `branches` (+ `region_id`), `regions` |
| **Specialities** | `services/main` |
| **More** | static menu, no network |

Includes the region/country context selector, since `country-code` and `region_id` scope nearly
every list.

**Watch:** `offers` returns `[]` on the test host, so the offers rail needs a real empty state and
its card design stays unverified (**B5**). Doctors pagination can't be exercised (**B2**) — build to
`meta.total` as documented and treat page 2 as untested until there's data.

**Exit:** four data-backed landing screens with all four states, pagination and pull-to-refresh,
verified in en + ar and LTR + RTL.

---

## Phase 4 — Nested screens per tab

| Screen | Endpoints |
| :--- | :--- |
| Doctor detail | `doctors/{id}` — bio, experience, ratings, per-branch `working_hours` |
| Branch detail | `branches/{id}` — address, phone, map launch, call, services, specialties |
| Speciality detail → sub-services | `services?service_id=` |
| Service detail | `services/{id}` — price, duration, type |

**Watch:** `address`, `phone`, `latitude`, `longitude` are **null on every branch** on the test host
— map and call actions must hide or disable rather than fire empty intents. `price` is a decimal
**string**, not a number.

**Exit:** every list row navigates to a populated detail screen; null-heavy payloads degrade cleanly.

---

## Phase 5 — Booking flow (the core)

The chain is fully verified against the live API, which is why this is the lowest-risk complex phase.

1. Entry from doctor, speciality or home
2. Service picker — `services?doctor_id=`
3. Branch picker — `branches?doctor_id=&service_id=`
4. Date + slot picker — `doctors/{id}/slots?date=&service_id=`; drive enablement off `is_bookable`;
   filter today's past times client-side; render a real **"doctor is off"** state when `is_off` is true
5. Review + price — `checkout-context`; **take `booking_start_time`/`booking_end_time` from
   `appointment.start_time`/`end_time`, never computed locally**
6. Coupon — re-request `checkout-context` with `coupon_code`; map the 422 onto the input
7. Payment method — `payment-gateways`, mapped through `BOOKING_PAYMENT_METHODS`
8. Confirm — `POST v1/portal/bookings`, branching on the two response shapes (direct booking vs
   `pending_booking_id` + gateway), then `pending-bookings/{id}/confirm`
9. Confirmation screen with the booking reference

**Slot-taken race:** re-request `checkout-context` immediately before enabling Confirm and again on
a failed submit. `unavailable_reason` is a **machine enum** (`outside_schedule`, `past_time`) — map
to `LocaleKeys`, never display raw, and fall back to a generic message on unknown codes.

**Decisions needed:** is **Qitaf** loyalty redemption in v1? Are **checkout links** in v1? Both
exist on the website and neither is in the ticket.

**Blocked by:** **B6** for the submit half.

**Exit:** a real booking created against the dev API, end to end, in both locales; slot-taken and
invalid-coupon paths recover without losing the user's selections.

---

## Phase 6 — Booking management

- My bookings — three tabs: `upcoming` / `completed` / `cancelled` (the API's own filters, not upcoming/past)
- Booking detail
- Cancel — `bookings/{id}/cancel`
- Reschedule — `bookings/{id}/reschedule`, reusing the Phase 5 slot picker

**Watch:** **B7** — create sends `"YYYY-MM-DD HH:MM:SS"` local, reschedule sends **UTC ISO-8601**.
Confirm which the backend wants before shipping this, or we will book the wrong hour.

---

## Phase 7 — Profile & account

- Profile view / edit — `POST v1/profile/update` (**note: no `/portal` segment**); all four fields required
- The checkout "complete your profile" prompt when `citizen_id_number` is missing — a booking-flow
  dependency, not just a profile screen
- Language, country, logout

---

## Phase 8 — Static & support (API-backed only)

- Contact us — `POST v1/portal/contact-us` (**multipart**)
- Careers — `careers`, `careers/departments`, `careers/{id}/applications` (**multipart**, CV field is `file`)
- Blogs — `blog` (+ comments)

**Explicitly out of scope, no API exists** (all probed, all 404):

- **Reviews / testimonials** — the website's reviews page is static marketing copy
- **Notifications** — no endpoint, so no notifications list and no push target
- **Terms / privacy / about** — no CMS or paragraph endpoint

If any of these are wanted, they need backend work first (**B8**, **B9**).

---

## Phase 9 — Hardening & release

Localisation and RTL are built in from Phase 0, so this is verification, not retrofit.

- Full `ar-SA` / `en-US` sweep; every screen checked in both directions
- Responsiveness on small phone / large phone / tablet
- Accessibility: 44pt targets, labelled icon buttons, no colour-only state, text scaling
- `flutter analyze` clean, `dart format`, all unit tests green
- Release builds, iOS + Android, both flavors
- `README.md`: setup, flavors, base URLs, build/run, architecture

---

## Assets & tokens — what I can and can't source from the web

You said to pull assets from the web. Checked, and it's partly true:

| Asset | Status |
| :--- | :--- |
| **Colours** | **Exact.** Pulled from the site's CSS variables — `--color-primary #c21c22`, `--color-secondary #222`, `--color-error #ea5454`, `--color-grey-dark #777`, `--color-light-grey #f8f8f8`, `--color-card-border #2117220a`, `--color-doctor-background #fdf6f6`, `--color-primary-light #ffecedd9`, `--color-pink-light #ffeced`, plus the grey ramp. No eyeballing needed. |
| **Fonts** | Available — the Farabi family ships as `.woff2` under `/_next/static/media/`. The weights in use are light / medium / semi-bold / bold. Will need matching `.ttf`/`.otf` for Flutter, or conversion. |
| **Images** | Available — `https://cdn.farabiclinics.com/web/assets/images/...` serves fine (logo, social icons, payment art). Note `logo.png` is **3.5 MB** and must be resized before bundling. |
| **Icons** | **Not resolvable.** 122 icon paths are referenced in the bundle (`/icons/calendar.svg`, `/icons/branch-pin.svg`, …) but every URL I tried 404s — the CDN root, `/web/assets/icons/`, and the site origin. So the icon set is the one asset gap. |

**Icon options:** export them from the Figma `Components` page (`16:38`), or get the `public/icons`
folder from the web repo, or I extract whatever is inlined in the JS bundle. The Figma export is
probably the cleanest and you can do it from the file you already have open.

**Layout geometry** is the part that stays visual, since Dev Mode is paywalled — I'll match spacing
and sizing by eye against the Figma frames and the live website, which is what you've approved.

---

## Sequencing risk — worth one decision before I start

**Phase 1 is Auth, and Auth is the one phase I cannot verify at all without a test patient account
(B6).** I can write it, but I can't prove a single happy path: no login, no OTP, no session.

Two options:

- **(a) Get a test patient on the dev host first**, then run the phases exactly as numbered. Cleanest.
- **(b) Swap Phases 1 and 3** — build the shell and the public tab screens first (Home, Doctors,
  Branches, Specialities are all public and fully verified), which proves the architecture end to
  end against real data, then come back to auth when the account exists.

I'd pick **(b)** if the account is going to take more than a day, because it keeps verified progress
moving and de-risks the architecture earlier. **(a)** if you can get me credentials quickly. Your call —
tell me which and I'll start.

Still outstanding independent of all this: the **production base URL** (**B1**), and a decision on
**Qitaf** and **checkout links** before Phase 5.
