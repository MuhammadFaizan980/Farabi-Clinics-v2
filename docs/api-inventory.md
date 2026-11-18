# Farabi Booking App — API inventory (Step 0)

Captured 2026-11-18 by reverse-engineering the live v2 website. **The website source repo
`FarabiMedicine/farabi_web_app` is not reachable with this runtime's credentials**
(`remote: Repository not found`), so this was produced via the fallback procedure: download the
Next.js client chunks, recover the shared API client and every call site, then replay each request
against the live API and record the real response.

Every endpoint below is marked with how it was verified:

| Mark | Meaning |
| :--- | :--- |
| **VERIFIED** | Path, method, params and response all confirmed by a real recorded request against the live API. |
| **CONTRACT-VERIFIED** | Path, method and request body read verbatim from the website's own compiled call site, but the response could not be recorded because the endpoint needs a patient login this runtime does not have. |
| **UNVERIFIED — BLOCKED** | Could not be captured. Do not code against these. |

Nothing in this document is guessed. Where a shape was not captured, it says so.

---

## 1. Hosts and flavors

| Flavor | Base URL | Source |
| :--- | :--- | :--- |
| dev / test | `https://erpapi-test.doctorstation.com/api/` | Hardcoded fallback in the website's `configureApi()` call. **VERIFIED** — every endpoint below was recorded against this host. |
| prod | **UNVERIFIED — BLOCKED** | Injected at deploy time as `NEXT_PUBLIC_API_BASE_URL`; it is not present in any client chunk. See blocker **B1**. |

Recovered verbatim from the client bundle:

```js
configureApi({
  baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL ?? "https://erpapi-test.doctorstation.com/api/",
  fetchInit: { next: { revalidate: 3600 } },
  getContext: async () => ({
    lang:    cookie("NEXT_LOCALE"),            // "en" | "ar"
    country: cookie("country"),                // "SA" (DEFAULT_COUNTRY = "SA")
    token:   localStorage.getItem("_token"),   // TOKEN_STORAGE_KEY = "_token"
  }),
});
```

`EndPoints` should therefore expose:

```dart
static const String baseUrlDev  = 'https://erpapi-test.doctorstation.com/api/';
static const String baseUrlProd = '<BLOCKED — see B1>';
```

Asset CDN (for `cdnImg()`-equivalent image URL building): `https://cdn.farabiclinics.com/web/assets`.
Image fields in every payload are **relative paths or null**, and must be prefixed with this base.

---

## 2. Request context — headers

Recovered verbatim from the shared client's header builder:

```js
let headers = {
  device: "1",
  lang: lang || "en",                        // from locale
  "country-code": (country || "SA").toLowerCase(),
  "Content-Type": "application/json",
};
if (token) headers.Authorization = `Bearer ${token}`;
```

**VERIFIED** behaviours:

- `lang: ar` localises the `name` / `label` / `description` fields in place. Every localisable
  object *also* carries explicit `name_ar` and `name_en`, so the app can render either language
  without a refetch. Recorded: `GET v1/portal/regions` with `lang: ar` → `{"id":9,"name_ar":"الدمام","name_en":"Dammam","name":"الدمام"}`.
- `country-code` is a **real data scope**, not a hint. `GET v1/portal/branches` returns 9 branches
  with `country-code: sa` and **0** with `country-code: eg`. Case-insensitive (`SA` == `sa`).
  Getting this header wrong silently produces empty screens, so it must be set before the first
  request — this is why `AppDi.initDi()` has to restore the session/country *before* any screen can fire.
- `device: 1` is sent by the website on every call. It is **not enforced** — the same request
  succeeds without it. Send it anyway, to stay identical to the website.
- No locale is ever passed as a query param. Locale is header-only.

---

## 3. Response envelope

**VERIFIED** on every endpoint in this document. There is exactly one envelope.

### Success

```json
{ "status": "success", "data": <object|array>, "meta": <object|null> }
```

### Error

```json
{ "status": "error", "message": ["Human readable message"], "code": 401 }
```

### Validation error (422) — carries field errors in `data`

Real capture — `GET v1/portal/checkout-context?...&coupon_code=BOGUS123`:

```json
{
  "status": "error",
  "message": ["This coupon code is not valid."],
  "code": 422,
  "data": { "coupon_code": ["This coupon code is not valid."] }
}
```

Real capture — same endpoint with a doctor/branch mismatch:

```json
{
  "status": "error",
  "message": ["The selected doctor no longer works at this branch."],
  "code": 422,
  "data": { "doctor_id": ["The selected doctor no longer works at this branch."] }
}
```

Note `message` is **always an array of strings**, never a bare string, on this API. The website's
extractor also tolerates a string and an `errors` key; neither was observed in practice.

### Other statuses — all VERIFIED

| Status | Body | When |
| :--- | :--- | :--- |
| `401` | `{"status":"error","message":["User is not logged in."],"code":401}` | Missing/invalid bearer on a protected endpoint. |
| `404` | `{"status":"error","message":["Target record was not found."],"code":404}` | Unknown id, or endpoint does not exist. |
| `405` | `{"status":"error","message":["Method not allowed. Supported: POST"],"code":405}` | Wrong verb. |
| `422` | as above | Validation failure. |

### `ApiResponseModel` normalisation

`ApiClient` must collapse all of the above into one result so no VM ever branches on a status code:

| Field | Source |
| :--- | :--- |
| `success` | `status == "success"` |
| `data` | `body["data"]` on success |
| `messages` | `body["message"]` (already a `List<String>`) |
| `fieldErrors` | `body["data"]` **when `code == 422`** — a `Map<String, List<String>>` keyed by request field name |
| `statusCode` | HTTP status |

The 422 overload of `data` is the one real trap here: on success `data` is the payload, on 422 it is
the field-error map. Key the switch off `code == 422`, not off the shape of `data`.

### Pagination metadata

`meta` is `null` on most endpoints and only populated where the backend actually pages. Real
capture — `GET v1/portal/blog`:

```json
"meta": { "per_page": 20, "total": 0, "curr_page": 1, "last_page": 1, "next_page_url": null }
```

Request param is `page` (1-based). See blocker **B2** — `meta` came back `null` for
`v1/portal/doctors` even with `page` and `region_id` set, so the doctors list's paging could not be
exercised on the test host.

---

## 4. Auth contract

**There is no refresh token.** This is the single most important finding for `ApiClient`: the
website issues one bearer token, stores it in `localStorage._token`, and never refreshes it. The
ticket's Step 1.4 asks for "single-flight refresh on 401, one replay, hard logout if refresh fails" —
**the first two of those have no backend to call.** The actual contract the website implements is:

1. On boot, read the stored token.
2. If present, call `GET v1/portal/profile` (`fetchMe()`).
3. If that succeeds → session restored with the returned patient.
4. If it fails → **delete the token** and treat the user as logged out.
5. Any later 401 → clean logout to login. No retry, no replay.

Recovered verbatim:

```js
const token = await storage.getItem(TOKEN_STORAGE_KEY);
const me = token ? await fetchMe() : null;
if (token && me) { setToken(token); setUser(me); }
else if (token) { await storage.removeItem(TOKEN_STORAGE_KEY); }
```

The app should implement exactly this: **validate-on-boot, hard-logout-on-401**, and the token in
`flutter_secure_storage` (not `shared_preferences`). Build the refresh interceptor only if the
backend team confirms a refresh endpoint exists — see blocker **B3**.

Auth is **phone + password**, with OTP confirmation on registration. There is no email login
anywhere in the bundle. This answers the ticket's open question 3.

Phone normalisation, recovered verbatim — the API receives the **national number with all
non-digits stripped**, and `country_code` as a separate `+`-prefixed field:

```js
function splitPhone(e164) {
  const p = parsePhoneNumber(e164);
  return {
    country_code: `+${p.countryCallingCode}`,          // "+966"
    mobile: p.formatNational().replace(/\D/g, ""),     // "512345678"
  };
}
```

Login sends **only** `mobile` (no `country_code`); register sends both.

### `POST v1/portal/auth/login` — public — **CONTRACT-VERIFIED**

```json
{ "mobile": "512345678", "password": "secret" }
```

Response (from the website's success handler): `{ "token": "...", "patient": { ... } }`.
On success the website stores `token` and sets the user to `patient`.

### `POST v1/portal/auth/register` — public — **CONTRACT-VERIFIED**

```json
{
  "first_name": "Ahmed",
  "last_name": "Hassan",
  "country_code": "+966",
  "mobile": "512345678",
  "password": "secret",
  "password_confirmation": "secret",
  "citizen_id_number": "1234567890",
  "citizen_id_type": 6
}
```

Response is read as `{ "otp": "..." }` — **the test API returns the OTP in the register response**
and the website pre-fills the OTP input with it. Treat this as a test-environment affordance: the
app must still accept a manually typed OTP, must never log the value, and must not depend on it
being present in production.

`citizen_id_type` is an enum, recovered verbatim with both labels (use these for the picker rather
than inventing them):

| value | en | ar |
| :--- | :--- | :--- |
| 1 | Passport ID | جواز سفر |
| 2 | Without ID | بدون هوية |
| 3 | Birth Certificate | شهادة ميلاد |
| 4 | Not Specific | غير محدد |
| 5 | Iqama | إقامة |
| 6 | Saudi Citizen ID | هوية مواطن سعودي |

### `POST v1/portal/auth/otp/confirm` — public — **CONTRACT-VERIFIED**

```json
{ "mobile": "512345678", "otp": "1234" }
```

Response `{ "token": "...", "patient": {...} }`. The website then immediately calls `fetchMe()` and
prefers that result, falling back to `patient` with `date_of_birth`, `gender` and `address` nulled.

### `POST v1/portal/auth/otp/resend` — public — **CONTRACT-VERIFIED**

```json
{ "mobile": "512345678" }
```

The website's resend button uses a **60-second** countdown — match that in the VM.

### `POST v1/portal/auth/forgot-password` — public — **CONTRACT-VERIFIED**

```json
{ "mobile": "512345678" }
```

### `POST v1/portal/auth/reset-password` — public — **UNVERIFIED — BLOCKED** (body)

The path and method are confirmed, but the website passes the form object through untouched and the
reset form itself is not present in any chunk reachable from a public route. Field names are
unknown. See blocker **B4**.

### Token-issuing endpoints to exclude from any auth interceptor

`v1/portal/auth/login`, `.../register`, `.../otp/confirm`, `.../otp/resend`,
`.../forgot-password`, `.../reset-password`.

---

## 5. Discovery endpoints

All **VERIFIED** and all **public** (no token).

### `GET v1/portal/regions`

No params. Used to scope essentially every other listing.

```json
{ "status": "success",
  "data": [ { "id": 9, "name_ar": "الدمام", "name_en": "Dammam", "name": "Dammam" } ],
  "meta": null }
```

Live values: Riyadh 5, Jeddah 6, Mecca 7, Medina 8, Dammam 9.

### `GET v1/portal/countries`

No params.

```json
{ "id": 2, "code": "EG", "name_ar": "مصر", "name_en": "Egypt", "name": "Egypt" }
```

Used by the registration country picker and to resolve `country_id` for careers.

### `GET v1/portal/services/main` — top-level specialities

Params (all optional, all **VERIFIED** as accepted): `region_id`, `doctor_id`, `branch_id`.

```json
{ "id": 5, "name": "Dental Services", "name_ar": "خدمات الأسنان", "name_en": "Dental Services",
  "image_url": null, "has_offer": false, "rating_average": 0, "rating_count": 0 }
```

### `GET v1/portal/services` — bookable services / sub-services

Params (all optional): `region_id`, `branch_id`, `doctor_id`, `service_id` (the last returns
sub-services of that parent). Same item shape as `services/main`.

This is the endpoint that answers *"what can I actually book with this doctor"* —
`GET v1/portal/services?doctor_id=3` → `[{id:19,name:"Creatinine"}, {id:29,name:"Mammography"}]`.

### `GET v1/portal/services/{id}` — service detail

```json
{ "id": 19, "name": "Creatinine", "name_ar": "الكرياتينين", "name_en": "Creatinine",
  "description": null, "desc_ar": null, "desc_en": null,
  "price": "45.00", "slot": 0, "pay_on_arrival": false, "code": "LABDEMO-CREAT",
  "image": null, "extra_images": [], "has_offer": false,
  "rating_average": 0, "rating_count": 0,
  "service_type": { "value": 2, "label": "Laboratory", "label_en": "Laboratory", "label_ar": "تحليل" },
  "specialties": [], "sub_services": [] }
```

`price` is a **decimal string**, not a number — parse it, don't assume `num`.

### `GET v1/portal/branches`

Params (all optional): `region_id`, `service_id`, `doctor_id`, `specialty_id`.

```json
{ "id": 10, "name": "Al-Badeya Branch (Main)", "name_ar": "فرع البديعة (الرئيسي)",
  "name_en": "Al-Badeya Branch (Main)", "address": null, "phone": null, "image": null,
  "rating_average": 0, "rating_count": 0, "latitude": null, "longitude": null,
  "region": { "id": 5, "name": "Riyadh" } }
```

`latitude` / `longitude` / `address` / `phone` are **null across every branch on the test host**.
The map-launch and call-branch actions in Milestone C must therefore degrade gracefully — hide or
disable the button when the field is null rather than launching an empty intent.

### `GET v1/portal/branches/{id}` — branch detail

Adds `email`, `extra_images[]`, `branch_type: [{value,label}]`, `specialties: [{id,name}]`,
`services: [{id,name}]` to the list shape.

### `GET v1/portal/home/branches` — branches grouped by region, for the home screen

```json
{ "id": 9, "name": "Dammam", "name_ar": "الدمام", "name_en": "Dammam",
  "branches_count": 0, "branches": [] }
```

Returns **regions** with nested branches, despite the path. The test host reports
`branches_count: 0` for all five regions with empty `branches` arrays, so the nested branch item
shape is **UNVERIFIED** here — treat it as the `branches` list item shape and guard for empty.

### `GET v1/portal/doctors`

Params, all optional, all recovered from the website's three distinct call sites:

| Param | Notes |
| :--- | :--- |
| `region_id` | |
| `branch_id` | |
| `service_id` | |
| `specialty_id` | **American spelling.** The response field is `specialties`, also American. Do not write `speciality_id`. |
| `search` | free-text |
| `gender` | |
| `ratings` | **comma-joined list**, e.g. `ratings=4,5` |
| `page` | 1-based; see blocker **B2** |

```json
{ "id": 28, "name": "Alaa Ali Abo Zahraa", "name_ar": "علاء ابو زهره",
  "name_en": "Alaa Ali Abo Zahraa", "image": null, "gender": "Male",
  "rating_average": 0, "rating_count": 0,
  "branches": [ { "id": 25, "name": "Al-Hakeem Medical Complex Clinics" } ],
  "specialties": [] }
```

The website's mapper normalises three real inconsistencies — the app's `DoctorMapper` must do the
same:

- `image` may be `null` → coerce to `""` (or keep nullable and handle at the widget).
- `qualification` is **either a string or an object with `.name`** → flatten to a string.
- the speciality list arrives as **`specialties` on the list endpoint** but the mapper also reads
  `specialities`; accept either key.

### `GET v1/portal/doctors/{id}` — doctor detail

```json
{ "id": 3, "name": "Dr. Ahmed Hassan", "name_ar": "د. أحمد حسن", "name_en": "Dr. Ahmed Hassan",
  "image": null, "gender": null, "qualification": null,
  "rating_average": 0, "rating_count": 0,
  "patients_count": 2, "satisfaction_percentage": null,
  "practice_started_on": null, "experience_years": null, "brief_summary": null,
  "branch": null,
  "branches": [
    { "id": 5, "name": "Al-Suwaidi Branch", "name_ar": "فرع السويدي", "name_en": "Al-Suwaidi Branch",
      "address": "test", "phone": null,
      "working_hours": [
        { "day_of_week": 0, "day": "sunday",
          "shifts": [ { "start_time": "09:00:00", "end_time": "17:00:00" } ] }
      ] } ],
  "specialties": [] }
```

`working_hours` is per-branch and nested **inside the doctor detail**, with `day_of_week` 0 = Sunday.
Branch opening hours for the *branch* detail screen are not on `branches/{id}` — only here.

### `GET v1/portal/offers`

Params: `page`. Returns `"data": []` on the test host — **the offer item shape is
UNVERIFIED — BLOCKED** (blocker **B5**). There is no `v1/portal/offers/{id}` (404), so offer
detail, if needed, has no endpoint.

### `GET v1/portal/blog`

Params: `page`. Returns `"data": []` with a populated `meta` (the pagination sample above). Blog
item shape is **UNVERIFIED — BLOCKED** (blocker **B5**). `v1/portal/blog/{id}` is a 404, so blog
detail has no endpoint either.

### `POST v1/portal/blog/{id}/comments` — **CONTRACT-VERIFIED** (path/method only)

Body is passed through untouched by the website and the comment form is not in a reachable chunk.
Body fields **UNVERIFIED**.

---

## 6. Booking flow — the core

This is the sequence the website actually performs. Every step here is **VERIFIED** against the live
API except the final `POST` and the gateway confirm, which need a login.

```
GET v1/portal/services?doctor_id=…            → choose a service
GET v1/portal/branches?doctor_id=…&service_id=… → choose a branch
GET v1/portal/doctors/{id}/slots?…            → choose a date + time
GET v1/portal/checkout-context?…              → price it, and re-check the slot
POST v1/portal/bookings                       → create (auth required)
```

The guided flow in the ticket (speciality → branch → doctor → slot → review → confirm) maps onto
these, but note the website's order is **doctor-first**: the booking screen is
`/doctors/{id}/book?service_id=…&branch_id=…`, and service/branch are narrowed *by* the doctor.

### `GET v1/portal/doctors/{doctorId}/slots` — public — **VERIFIED**

| Param | Required | Notes |
| :--- | :--- | :--- |
| `date` | yes | `YYYY-MM-DD` |
| `service_id` | yes | the website will not fire the query without it |

Real capture — `GET v1/portal/doctors/3/slots?date=2026-11-19&service_id=19`:

```json
{ "status": "success",
  "data": {
    "date": "2026-11-19",
    "doctors": [
      { "doctor_id": 3, "name_en": "Dr. Ahmed Hassan", "name_ar": "د. أحمد حسن",
        "is_off": false,
        "slots": [
          { "slot": 1, "start_time": "09:00", "end_time": "09:30", "status": 2,
            "is_bookable": true, "booking": null, "unavailable_reason": null,
            "shift_end_time": "17:00:00" },
          { "slot": 2, "start_time": "09:30", "end_time": "10:00", "status": 2,
            "is_bookable": true, "booking": null, "unavailable_reason": null,
            "shift_end_time": "17:00:00" }
        ] } ] },
  "meta": null }
```

Captured 16 slots, 09:00→17:00 in 30-minute steps. A day off returns
`{"doctor_id":28,"is_off":true,"slots":[]}` — **VERIFIED** separately.

Notes that matter for the app:

- The payload is a **single-doctor response wrapped in a `doctors` array**. The website reads
  `data.doctors[0].slots`. Read it the same way, but treat a missing/empty array as "no slots",
  not as an error.
- `start_time` / `end_time` here are `HH:MM`. Elsewhere in the booking payloads they are
  `HH:MM:SS`. The website converts with a helper that pads to `HH:MM:SS`.
- `is_bookable` is the field to drive slot enablement. `status` (observed only as `2`) and
  `booking` are not used by the website and their value space is **UNVERIFIED**.
- `is_off: true` is a distinct, meaningful state — **the website ignores it** and shows a generic
  empty list. The app should render a proper "doctor is off on this day" empty state instead; it is
  strictly better and costs nothing.
- Today's slots must be filtered to future times **client-side** — the API returns the full day.
  The website filters on `hour*60+minute > now`.

The website's date picker only offers **the current month through December of the current year**
(`length: 12 - now.getMonth()`), so it cannot book across a year boundary. Do not copy that bug;
the API accepts any `date`, verified with `2026-01-05`.

### `GET v1/portal/checkout-context` — public to call, but gates on nothing — **VERIFIED**

This single endpoint does the pricing **and** the live slot re-check. It is the recoverable-error
surface the ticket asks for.

| Param | Notes |
| :--- | :--- |
| `doctor_id` | |
| `service_id` | |
| `branch_id` | |
| `date` | `YYYY-MM-DD` |
| `time` | **`HH:MM:SS`** — the website pads the `HH:MM` from the slot list |
| `quantity` | defaults to 1 |
| `coupon_code` | optional; re-request with it to apply a coupon |

Real capture — `?doctor_id=3&service_id=19&branch_id=8&date=2026-11-19&time=10:00:00&quantity=1`:

```json
{ "status": "success",
  "data": {
    "doctor":  { "id": 3, "name": "Dr. Ahmed Hassan", "name_ar": "د. أحمد حسن",
                 "name_en": "Dr. Ahmed Hassan", "image": null, "gender": null },
    "service": { "id": 19, "name": "Creatinine", "name_ar": "الكرياتينين", "name_en": "Creatinine",
                 "description": null, "image": null, "duration_minutes": 30, "quantity": 1 },
    "branch":  { "id": 8, "name": "Al-Olaya Medical Center", "name_ar": "فرع العليا الطبي",
                 "name_en": "Al-Olaya Medical Center", "address": "test", "phone": null,
                 "latitude": null, "longitude": null },
    "appointment": { "date": "2026-11-19", "start_time": "10:00:00", "end_time": "10:30:00",
                     "duration_minutes": 30, "slot_available": true, "unavailable_reason": null },
    "pricing": { "currency_code": "SAR", "currency_symbol": "ر.س",
                 "unit_list_price": 45, "unit_discount": 0, "unit_price": 45,
                 "subtotal": 45, "discount": 0, "tax": 0, "total": 45 },
    "slot_available": true,
    "unavailable_reason": null,
    "cart_detail": { "image": null, "first_name": "Dr. Ahmed Hassan", "service_name": "Creatinine",
                     "branch_name": "Al-Olaya Medical Center", "date": "2026-11-19",
                     "from_time": "10:00", "to_time": "10:30", "slot": 30, "price": 45 },
    "checkout_total": [ { "title": "Service fee", "slug": "service_fee",
                          "value": { "value": 45, "formatted": "45.00 SAR" } } ],
    "total": { "value": 45, "formatted": "45.00 SAR" },
    "is_coupon": false,
    "coupon": null },
  "meta": null }
```

**`appointment.start_time` and `appointment.end_time` are the authoritative booking window.** The
website builds `booking_start_time` / `booking_end_time` from these, *not* from the slot the user
tapped. The app must do the same — never compute the end time by adding a duration locally.

#### The slot-taken race — **VERIFIED**

`slot_available: false` plus a non-null `unavailable_reason` is how a lost slot surfaces. Recorded
reasons:

| Request | `slot_available` | `unavailable_reason` |
| :--- | :--- | :--- |
| `date=2026-11-19&time=10:00:00` | `true` | `null` |
| `date=2026-11-19&time=23:00:00` (outside the shift) | `false` | `"outside_schedule"` |
| `date=2026-01-05&time=10:00:00` (in the past) | `false` | `"past_time"` |

`unavailable_reason` is a **machine enum, not display text** — it stays `"outside_schedule"` even
with `lang: ar` (**VERIFIED**). The website renders it raw into the UI, which is a bug. The app must
map each code to a `LocaleKeys` entry and fall back to a generic localised "slot no longer
available" for unrecognised codes. Known codes so far: `outside_schedule`, `past_time`. The full
enum is **UNVERIFIED** — handle unknown values by falling back, not by displaying them.

Re-request `checkout-context` immediately before enabling Confirm, and again on a failed submit, to
pick up a slot taken by someone else between selection and submit.

#### Coupons — **VERIFIED**

Apply by re-requesting `checkout-context` with `coupon_code`. Success updates `pricing.discount`,
`is_coupon`, `coupon` and adds a `discount` row to `checkout_total`. An invalid code returns the
422 shown in §3 with `data.coupon_code` — map that straight onto the coupon input.

### `POST v1/portal/bookings` — **requires auth** — **CONTRACT-VERIFIED**

401 without a token is **VERIFIED**: `{"status":"error","message":["User is not logged in."],"code":401}`.
This settles the ticket's open question 6: **guest booking is not possible.** The website opens the
login sheet when an unauthenticated user taps Confirm.

Body, recovered verbatim from the checkout page's purchase handler:

```json
{
  "branch_id": 8,
  "doctor_id": 3,
  "booking_start_time": "2026-11-19 10:00:00",
  "booking_end_time": "2026-11-19 10:30:00",
  "items": [ { "service_id": 19, "quantity": 1 } ],
  "payment_method": "cash",
  "coupon_code": "OPTIONAL",
  "qitaf_redemption_id": 123,
  "payment_flow": "mobile_sdk"
}
```

- `booking_start_time` / `booking_end_time` — `"{appointment.date} {appointment.start_time}"` and
  `"…end_time"`, i.e. **`YYYY-MM-DD HH:MM:SS` local**, taken verbatim from `checkout-context`.
- `items` — one entry per service, `quantity` from `checkout-context.service.quantity`.
- `coupon_code` / `qitaf_redemption_id` — **omitted entirely** when unused, not sent as null.
- `payment_flow: "mobile_sdk"` — sent only for the PayTabs native-SDK path. This already exists
  server-side for mobile, which is exactly what the Flutter app needs.

Response has **two shapes**, and the app must branch on which:

1. **Completed immediately** (cash / free / insurance):
   `{ "id": …, "doctor": {id,name}, "services": [{"service":{"name":…}}], "branch": {"name":…} }`
   → go straight to the confirmation screen; `id` is the booking reference.
2. **Gateway required**:
   `{ "pending_booking_id": …, "checkout_reference": "…", "amount": …, "currency": "…", "redirect_url": "…" }`
   → either open `redirect_url`, or hand `checkout_reference`/`amount`/`currency` to the native
   PayTabs SDK, then confirm with the next endpoint.

Both shapes are read from the website's own success handler. Neither could be **recorded** without a
patient login — see blocker **B6**.

### `POST v1/portal/pending-bookings/{pendingBookingId}/confirm` — auth — **CONTRACT-VERIFIED**

```json
{ "tran_ref": "…" }
```

`tran_ref` is omitted (body `{}`) when the gateway did not return one. Response is read as
`{ "status": { "key": "completed" }, "booking": { … } }`; the website polls this up to **5 times**
before giving up. Other `status.key` values are **UNVERIFIED**.

### `GET v1/portal/payment-gateways` — **requires auth** — **CONTRACT-VERIFIED**

401 without a token is **VERIFIED**. Item shape is read from the website's mapper:
`{ slug, name: { label }, logo, description }`. Note `name` is an **object with a `label`**, not a
string.

Payment enums, recovered verbatim:

```js
PAYMENT_TYPES = { PAY_TAB:"paytab", APPLE_PAY:"applepay", TAMARA:"tamara", COD:"paybranch",
                  FREE:"free", TABBY:"tabby", STC_PAY:"stcpay", WALLET:"wallet",
                  INSURANCE:"insurance" }

// UI type → the payment_method value actually sent to POST /bookings
BOOKING_PAYMENT_METHODS   = { paybranch:"cash", paytab:"paytabs", applepay:"paytabs" }

// gateway slug from the API → UI type
GATEWAY_SLUG_PAYMENT_TYPES = { paytabs:"paytab", cash:"paybranch", insurance:"insurance" }
```

So `payment_method` on `POST /bookings` is the mapped value — `"cash"`, `"paytabs"`,
`"insurance"` — falling back to the raw UI key for types with no mapping (`tamara`, `tabby`,
`stcpay`, `wallet`, `free`). When the total is 0 the website forces `free`; when a Qitaf redemption
covers the whole bill it forces `"cash"`.

**Payment is in scope on the website** — this answers the ticket's open question 4, but the gateway
list is auth-gated so which methods are actually live is **UNVERIFIED**. See blocker **B6**.

### Qitaf loyalty redemption — all **auth-required** — **CONTRACT-VERIFIED**

An STC Qitaf points flow the ticket does not mention at all.

| Method | Path | Body |
| :--- | :--- | :--- |
| GET | `v1/portal/qitaf` | — → `{ enabled, redemption }`; 401 **VERIFIED** without token |
| POST | `v1/portal/qitaf/otp` | `{ "mobile": "…" }` |
| POST | `v1/portal/qitaf/redemptions` | `{ "mobile": "…", "otp": "…", "amount": 50 }` |
| DELETE | `v1/portal/qitaf/redemptions/{id}` | `{}` |

`amount` must be a whole number between 1 and `floor(billTotal)`. Decide with the requester whether
this is in v1 scope — it is a meaningful chunk of the checkout screen.

### Checkout links (shared/pre-built checkouts) — **CONTRACT-VERIFIED**

| Method | Path | Notes |
| :--- | :--- | :--- |
| GET | `v1/portal/checkout-links/{token}` | → `{ booking: {…}, slot_available }`; the website throws if `booking` is absent |
| POST | `v1/portal/checkout-links/{id}/authenticate` | shared link-auth helper |

When a `checkout_token` is present the website skips `checkout-context` entirely and posts
`{ checkout_token, payment_method }` to `POST v1/portal/bookings` instead. Probably out of scope for
v1 — confirm.

---

## 7. Booking management & profile

### `GET v1/portal/bookings` — auth — **CONTRACT-VERIFIED**

401 without a token **VERIFIED**. Param `status`, one of (recovered verbatim):

```js
BOOKING_STATUS_FILTERS = { UPCOMING: "upcoming", COMPLETED: "completed", CANCELLED: "cancelled" }
```

The website expects a **bare array** (`Array.isArray(t) ? t : []`). Fields referenced by the
website's own booking UI — so these exist, though the full item shape is **UNVERIFIED** (blocker
**B6**):

`id`, `doctor: {id, name, image, gender}`, `services: [{ service: {id, name}, service_name,
unit_price }]`, `branch: {name}`, `booking_date`, `booking_start_time`, `booking_end_time`,
`subtotal`, `tax`, `discount`, `total`, `currency: {currency_symbol}`, `items: [...]`.

`booking_start_time` is a `"YYYY-MM-DD HH:MM:SS"` string — the website splits on a space and slices
`HH:MM`.

The ticket asks for upcoming/past tabs; the API's three filters are upcoming / completed /
cancelled, so build three.

### `POST v1/portal/bookings/{id}/cancel` — auth — **CONTRACT-VERIFIED**

Body `{}`.

### `POST v1/portal/bookings/{id}/reschedule` — auth — **CONTRACT-VERIFIED**

```json
{ "booking_start_time": "2026-11-19T07:00:00.000Z", "booking_end_time": "2026-11-19T07:30:00.000Z" }
```

**This is a different time format from booking creation.** Create sends
`"YYYY-MM-DD HH:MM:SS"` local; reschedule sends a **UTC ISO-8601 string** (the website calls
`Date.toISOString()`). That inconsistency is in the website's shipped code, so presumably the
backend accepts both here, but it is the kind of thing that silently books the wrong hour. Confirm
with the backend team which format `reschedule` really wants before shipping Milestone E — tracked
as blocker **B7**.

Reschedule reuses the same slot picker, keyed on the booking's existing
`doctor.id` and `services[0].service.id`.

### `GET v1/portal/profile` — auth — **CONTRACT-VERIFIED**

401 without a token **VERIFIED**. This is `fetchMe()`; the website treats a response without `.id`
as "not logged in". Known fields: `id`, `first_name`, `last_name`, `email`,
`citizen_id_number`, `mobile`, `country_code`, `date_of_birth`, `gender`, `address`.

### `POST v1/profile/update` — auth — **CONTRACT-VERIFIED**

**Note the path has no `/portal` segment** — it is `v1/profile/update`, unlike every other endpoint
here. Verified by reading the call site; easy to "correct" by mistake.

```json
{ "first_name": "Ahmed", "last_name": "Hassan", "email": "a@b.com", "citizen_id_number": "1234567890" }
```

All four are required by the website's own save-button guard. Response is the updated profile.
Phone is **not** editable.

The checkout flow shows a "complete your profile" prompt when a logged-in patient has no
`citizen_id_number` — so this is a dependency of the booking flow, not just a profile screen.

---

## 8. Static & support

### `POST v1/portal/contact-us` — public — **CONTRACT-VERIFIED**

**`multipart/form-data`**, not JSON:

| field | notes |
| :--- | :--- |
| `name` | required |
| `email` | optional |
| `phone_number` | required |
| `service_id` | required |
| `branch_id` | required |
| `about_us` | required; one of `instagram`, `snapchat`, `tiktok`, `twitter`, `youtube`, `facebook`, `news`, `friend`, `other` |

`GET` on this path returns `405 {"message":["Method not allowed. Supported: POST"]}` — **VERIFIED**.

### `GET v1/portal/careers` — public — **VERIFIED**

Params: `page`, `country_id`. Returns job postings with
`id`, `slug`, `title`, `department`, `employment_type: {label}`, `branch: {name}`,
`experience_min_years`, `experience_max_years`, `summary`, `published_at`, `created_at`.

### `GET v1/portal/careers/departments` — public — **VERIFIED**

Param: `country_id`.

```json
{ "department_ar": "الإدارة", "department_en": "Administration Department",
  "department": "Administration Department" }
```

### `POST v1/portal/careers/{jobId}/applications` — public — **CONTRACT-VERIFIED**

**`multipart/form-data`**, field names recovered verbatim:

`job_id`, `job_title`, `name`, `email`, `mobile_number`, `date_of_birth` (`DD / MM / YYYY`),
`current_position`, `years_of_experience`, `license_number`, `speciality`, `highest_degree`,
`institution`, `graduation_year`, `cover_letter`, `reference_name`, `reference_relationship`,
`reference_contact`, `file` (the CV — **the file field is `file`**, not `cv`).

### Reviews / testimonials — **no API exists**

The `/reviews` page is **static marketing content baked into the website** (fixed patient names and
quotes in the server-rendered HTML). Probed and 404: `v1/portal/reviews`, `v1/portal/ratings`,
`v1/portal/testimonials`, `v1/portal/doctors/{id}/reviews`, `v1/portal/branches/{id}/reviews`.

`rating_average` / `rating_count` **are** real fields on doctors, branches and services — so star
ratings are available, but there is no review *list* or review *submission* endpoint. Per the
ticket's "only those the website actually exposes via API", a reviews screen is **out of scope**
unless the backend team confirms an endpoint. Blocker **B8**.

### About / terms / privacy / notifications — **UNVERIFIED — BLOCKED**

The website has a `LEGAL_PAGE_PARAGRAPHS = { privacy_policy: 10, terms_and_conditions: 25 }`
constant, implying a paragraph/CMS endpoint, but no such endpoint is referenced from any client
chunk and `/en/terms` and `/en/privacy` are both 404 on the site. Probed and 404:
`v1/portal/paragraphs`, `v1/portal/paragraphs/10`, `v1/portal/paragraph/10`, `v1/portal/pages`,
`v1/portal/pages/10`, `v1/portal/about`, `v1/portal/about-us`, `v1/portal/content/10`,
`v1/portal/cms/10`, `v1/portal/settings`.

`v1/portal/notifications` is also **404** — there is **no notifications endpoint**, so the
notifications list in Milestone E has no data source. Blocker **B9**.

---

## 9. Full endpoint ↔ `EndPoints` map

Base: `https://erpapi-test.doctorstation.com/api/`. Paths below are appended verbatim.

| `EndPoints` constant | Method | Path | Auth | Status |
| :--- | :--- | :--- | :--- | :--- |
| `login` | POST | `v1/portal/auth/login` | — | CONTRACT |
| `register` | POST | `v1/portal/auth/register` | — | CONTRACT |
| `otpConfirm` | POST | `v1/portal/auth/otp/confirm` | — | CONTRACT |
| `otpResend` | POST | `v1/portal/auth/otp/resend` | — | CONTRACT |
| `forgotPassword` | POST | `v1/portal/auth/forgot-password` | — | CONTRACT |
| `resetPassword` | POST | `v1/portal/auth/reset-password` | — | BLOCKED (body) |
| `profile` | GET | `v1/portal/profile` | ✓ | CONTRACT |
| `profileUpdate` | POST | `v1/profile/update` | ✓ | CONTRACT |
| `countries` | GET | `v1/portal/countries` | — | VERIFIED |
| `regions` | GET | `v1/portal/regions` | — | VERIFIED |
| `mainServices` | GET | `v1/portal/services/main` | — | VERIFIED |
| `services` | GET | `v1/portal/services` | — | VERIFIED |
| `serviceDetail` | GET | `v1/portal/services/{id}` | — | VERIFIED |
| `branches` | GET | `v1/portal/branches` | — | VERIFIED |
| `branchDetail` | GET | `v1/portal/branches/{id}` | — | VERIFIED |
| `homeBranches` | GET | `v1/portal/home/branches` | — | VERIFIED |
| `doctors` | GET | `v1/portal/doctors` | — | VERIFIED |
| `doctorDetail` | GET | `v1/portal/doctors/{id}` | — | VERIFIED |
| `doctorSlots` | GET | `v1/portal/doctors/{id}/slots` | — | VERIFIED |
| `checkoutContext` | GET | `v1/portal/checkout-context` | — | VERIFIED |
| `createBooking` | POST | `v1/portal/bookings` | ✓ | CONTRACT |
| `bookings` | GET | `v1/portal/bookings` | ✓ | CONTRACT |
| `cancelBooking` | POST | `v1/portal/bookings/{id}/cancel` | ✓ | CONTRACT |
| `rescheduleBooking` | POST | `v1/portal/bookings/{id}/reschedule` | ✓ | CONTRACT |
| `confirmPendingBooking` | POST | `v1/portal/pending-bookings/{id}/confirm` | ✓ | CONTRACT |
| `paymentGateways` | GET | `v1/portal/payment-gateways` | ✓ | CONTRACT |
| `qitaf` | GET | `v1/portal/qitaf` | ✓ | CONTRACT |
| `qitafOtp` | POST | `v1/portal/qitaf/otp` | ✓ | CONTRACT |
| `qitafRedemptions` | POST | `v1/portal/qitaf/redemptions` | ✓ | CONTRACT |
| `qitafRedemptionDelete` | DELETE | `v1/portal/qitaf/redemptions/{id}` | ✓ | CONTRACT |
| `checkoutLink` | GET | `v1/portal/checkout-links/{token}` | — | CONTRACT |
| `checkoutLinkAuth` | POST | `v1/portal/checkout-links/{id}/authenticate` | — | CONTRACT |
| `offers` | GET | `v1/portal/offers` | — | VERIFIED (empty) |
| `blog` | GET | `v1/portal/blog` | — | VERIFIED (empty) |
| `blogComments` | POST | `v1/portal/blog/{id}/comments` | ? | BLOCKED (body) |
| `contactUs` | POST | `v1/portal/contact-us` | — | CONTRACT (multipart) |
| `careers` | GET | `v1/portal/careers` | — | VERIFIED |
| `careerDepartments` | GET | `v1/portal/careers/departments` | — | VERIFIED |
| `careerApply` | POST | `v1/portal/careers/{id}/applications` | — | CONTRACT (multipart) |

**37 of the 39 endpoints have a fully known request contract** (14 VERIFIED end-to-end, 2 VERIFIED
but returning empty collections, 21 CONTRACT-VERIFIED). Only 2 are blocked on an unknown request
body: `resetPassword` and `blogComments`. Of the 21 CONTRACT-VERIFIED, the 12 auth-gated ones still
need their *response* shapes recorded against a test patient account — blocker **B6**.

---

## 10. Blockers

These must be resolved before the milestones they gate. None of them block Step 1.

| # | Blocker | Gates | Needed from |
| :--- | :--- | :--- | :--- |
| **B1** | **Production API base URL is unknown.** Only the test host is in the bundle; prod comes from a deploy-time env var. `EndPoints.baseUrlProd` cannot be filled in. | prod flavor, release builds (DoD 3) | DevOps / web team |
| **B2** | **Doctors-list pagination unexercised.** `meta` is `null` on `v1/portal/doctors` even with `page` and `region_id`, so `meta.total` — which the website's infinite scroll depends on — never populates and page 2 is never fetched. Either the test host has too little data to page, or the endpoint does not page. | Milestone C pagination | Backend team, or a seeded test dataset |
| **B3** | **No token refresh exists.** No refresh endpoint in the bundle; the website hard-logs-out on 401. The ticket's single-flight-refresh requirement has nothing to call. | Milestone B | Backend team — confirm "no refresh" or supply the endpoint |
| **B4** | `POST v1/portal/auth/reset-password` body fields unknown. | Milestone B (forgot-password) | Backend team |
| **B5** | **Offers and blog return empty arrays**, so item shapes are unknown; no detail endpoint exists for either (`offers/{id}` and `blog/{id}` are 404). | Milestone C offers, Milestone F blogs | Seeded test data |
| **B6** | **No patient test credentials.** Blocks recording real responses for: create-booking (both shapes), bookings list, profile, payment-gateways, qitaf, pending-booking confirm — i.e. the entire authenticated half of the app, including the booking submit. | Milestones B, D, E | A test patient account on the test host |
| **B7** | **Booking time format inconsistency.** Create sends `"YYYY-MM-DD HH:MM:SS"` local; reschedule sends UTC ISO-8601. Risk of booking the wrong hour. | Milestone E | Backend team |
| **B8** | **No reviews API.** The website's reviews page is static content. | Milestone F reviews | Product decision |
| **B9** | **No notifications API** (`v1/portal/notifications` → 404), and no CMS/paragraph endpoint for about / terms / privacy. | Milestone E notifications, Milestone F static pages | Backend team / product decision |

### Secondary observations

Website behaviours **not** to copy into the app:

1. `unavailable_reason` is rendered as raw display text (`"outside_schedule"` reaches the user).
   Map these codes to `LocaleKeys`.
2. A hardcoded placeholder email (`wkasem@farabi.com`) is sent as the PayTabs customer email.
3. The date picker cannot cross a year boundary (`12 - now.getMonth()` months).
4. `is_off` on the slots response is ignored; the day-off case shows a generic empty list.
5. `GET v1/portal/doctors?service_id=5` returns `[]` while
   `GET v1/portal/doctors/3/slots?service_id=5` happily returns 16 slots — the doctor↔service link
   is not consistent between the two endpoints on the test host. Drive the service picker from
   `GET v1/portal/services?doctor_id=…` (what the website does), never the reverse.

---

## 11. How this was captured

Reproducible from an empty directory:

1. Fetched `/en` plus 32 route candidates from `https://v2.farabiclinics.com`; collected every
   `/_next/static/chunks/*.js` reference → 38 unique chunks downloaded.
2. Grepped the chunks for `NEXT_PUBLIC_*` and absolute URLs → found the `configureApi()` call and
   the test base URL.
3. Extracted the shared `@farabi/shared/api` module verbatim → the header builder, URL builder,
   the six request helpers (`get`, `getRaw`, `apiGetJson`, `apiPost`, `apiPostJson`,
   `apiDeleteJson`), the error-message extractor, and `fetchMe()`.
4. Regex-extracted every `v<n>/...` path literal and matched each to its calling helper → 39
   endpoints with their methods.
5. Dumped each call site to recover query params, request bodies and response field access.
6. Replayed every public endpoint against the live test API with the website's exact headers, and
   recorded the responses; drove the booking chain end-to-end (services → branches → slots →
   checkout-context) to a real priced, available slot; and deliberately provoked 401, 404, 405, 422
   and the two `slot_available: false` cases.

Recorded artefacts live under `discovery/` in the task workspace: `chunks/` (38 JS chunks),
`samples/` (73 captured JSON responses), and the `crawl.py` / `paths.py` / `probe.py` scripts.
Note these were captured from the **test** host; re-run against prod once **B1** is answered.

The one thing this method cannot reach is the website's **server-component** calls, which never
appear in the client bundle. Everything in §8 marked BLOCKED is in that category, so an endpoint
may exist and simply not be referenced client-side. Repo access (ticket open question 2) would
settle those immediately.
