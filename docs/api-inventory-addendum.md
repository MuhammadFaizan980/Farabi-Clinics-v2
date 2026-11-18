# API inventory — addendum: the authenticated half, now verified

Captured 2026-11-18 using the test patient account supplied on the ticket. This **supersedes every
`CONTRACT-VERIFIED` marking on the 12 auth-gated endpoints** in `api-inventory.md`, and corrects two
things that document got wrong.

Blockers closed: **B6** (no test account), **B4** (reset-password body). **B7** turned out to be a
non-issue — see below. **B3** (no token refresh) stands.

---

## 1. Auth — all paths verified end to end

### `POST v1/portal/auth/login`

```json
{ "mobile": "0564772491", "password": "<redacted>" }
```

**`mobile` keeps its leading zero.** The national format is the full `05XXXXXXXX`, not the
9-digit form. Response `200`:

```json
{ "status": "success",
  "data": {
    "token": "<52-char opaque string>",
    "patient": {
      "id": 17, "patient_id": "PAT-DD81212C",
      "first_name": "Faizan", "last_name": "Awan",
      "email": null, "mobile": "0564772491", "country_code": "+966",
      "citizen_id_type": 5, "citizen_id_number": "2563356050",
      "is_phone_verified": true, "is_email_verified": false } },
  "meta": null }
```

The token is a 52-character opaque string — not a JWT, so **there is nothing to decode client-side**
and no embedded expiry. That reinforces the validate-on-boot contract: the only way to know a token
is still good is to call `profile`.

### `POST v1/portal/auth/register` → `201`

Verified by registering a throwaway account. `email` is **not required** and may be omitted.

```json
{ "status": "success",
  "data": { "message": "OTP sent successfully.", "otp": "712633" }, "meta": null }
```

**The dev API returns the OTP in the response body** — 6 digits. Confirmed on `register`,
`otp/resend` and `forgot-password`. Useful for automated testing; the app must never log it and must
never depend on it being present in production.

### `POST v1/portal/auth/otp/confirm` → `200`

`{ "mobile": "...", "otp": "712633" }` → same `{ token, patient }` shape as login.

### `POST v1/portal/auth/otp/resend` → `200`

`{ "mobile": "..." }` → `{ "message": "OTP sent successfully.", "otp": "294712" }`

### `POST v1/portal/auth/forgot-password` → `200`

`{ "mobile": "..." }` → `{ "message": "OTP sent successfully.", "otp": "570903" }`

### `POST v1/portal/auth/reset-password` → `200` — **B4 CLOSED**

The body that works:

```json
{ "mobile": "05XXXXXXXX", "otp": "570903",
  "password": "<new>", "password_confirmation": "<new>" }
```

→ `{ "message": "Password reset successfully." }`. Omitting `password_confirmation` fails.

### `GET v1/portal/profile` → `200`

Adds `date_of_birth`, `gender`, `address` to the `patient` shape above (all `null` on the test
account). `patient_id` is the human-facing reference.

---

## 2. Booking list — the website is sending the wrong type

**`status` must be an INTEGER, not a string.** This is the most consequential finding here.

```
GET v1/portal/bookings?status=upcoming
→ 422 { "data": { "status": [
     "The status field must be an integer.", "The selected status is invalid." ] } }
```

The website's own constant is `BOOKING_STATUS_FILTERS = { UPCOMING:"upcoming", COMPLETED:"completed",
CANCELLED:"cancelled" }` and it passes those straight through — so **every "My bookings" request on
the live website 422s**, and because its handler is `Array.isArray(t) ? t : []`, the failure is
swallowed and the screen silently renders empty. Do not copy this.

Valid values are **integers 1–6**. `0` and `7+` return
`422 "The selected status is invalid."`. Verified by state transition:

| `status` | Label | How established |
| :--- | :--- | :--- |
| `1` | **Created** | A newly created booking appears here |
| `2` | — | Accepted by the API, no booking observed in this state |
| `3` | — | Accepted, not observed |
| `4` | — | Accepted, not observed |
| `5` | — | Accepted, not observed |
| `6` | **Cancelled** | A cancelled booking moves here |

Omitting `status` entirely returns **all** bookings — the simplest way to drive a single list.

For the three tabs the ticket asks for, `1` and `6` are confirmed; the mapping for 2–5 needs the
backend team to name them, or needs bookings that have progressed further. **Do not guess them.**

---

## 3. `POST v1/portal/bookings` → `201` — both response shapes captured

### Shape A — completed immediately (cash / free / insurance)

```json
{ "id": 128, "booking_number": "BK-00128",
  "status": { "value": 1, "label": "Created", "label_en": "Created", "label_ar": "تم الإنشاء" },
  "booking_start_time": "2026-11-19T07:00:00.000000Z",
  "booking_end_time": "2026-11-19T07:30:00.000000Z",
  "booking_date": "2026-11-18T21:00:00.000000Z",
  "rejection_reason": null, "can_cancel": true, "can_reschedule": true,
  "services": [ { "id": 172, "service": { "id": 19, "name": "Creatinine" },
                  "quantity": 1, "price": "45.00", "discount": "0.00" } ],
  "branch": { "id": 8, "name": "Al-Olaya Medical Center" },
  "doctor": { "id": 3, "name": "Dr. Ahmed Hassan", "gender": null },
  "invoices": [ { "id": 140, "invoice_number": "INV-00140", "total": "45.00",
                  "patient_paid_amount": "45.00", "amount_due": 45,
                  "payment_status": { "value": 1, "label": "Unpaid" } } ],
  "payment": { "id": 107, "method": { "value": 1, "label": "Cash" },
               "status": { "value": 1, "label": "Pending" },
               "amount": "45.00", "redirect_url": null } }
```

**`booking_number` (`BK-00128`) is the real booking reference** — use it on the confirmation screen,
not the numeric `id`. The website uses `id`; `booking_number` is what a patient can quote.

`can_cancel` / `can_reschedule` are server-driven — drive the buttons off these, never off a local
status comparison.

The list item shape is **identical** to this, so one model and one mapper serve create, list, detail,
cancel and reschedule.

### Shape B — gateway required (paytabs / tabby / tamara)

```json
{ "pending_booking_id": 64,
  "status": { "value": 1, "key": "pending", "label": "Pending" },
  "method": { "value": 6, "label": "PayTabs" },
  "amount": "45.00", "currency": "SAR",
  "payment_flow": "redirect",
  "checkout_reference": "PGB-64",
  "redirect_url": "https://secure.paytabs.sa/payment/page/500EB14C…",
  "expires_at": "2026-11-18T10:08:04.000000Z" }
```

Note there is **no `id`** on this shape — only `pending_booking_id`. Branch on which key is present.
`expires_at` is ~30 minutes out, so the payment screen needs a timeout path. `payment_flow` comes
back as `"redirect"`; sending `payment_flow: "mobile_sdk"` is what selects the native SDK path.

---

## 4. Datetime semantics — **B7 was a false alarm, and I had it wrong**

My earlier note warned that create sends local while reschedule sends UTC, and that this risked
"booking the wrong hour". **That was wrong.** Tested both against the same booking:

| Sent | Stored | Riyadh local |
| :--- | :--- | :--- |
| `"2026-11-19 10:00:00"` (naked) | `2026-11-19T07:00:00Z` | 10:00 ✓ |
| `"2026-11-19 14:00:00"` (naked) | `2026-11-19T11:00:00Z` | 14:00 ✓ |
| `"2026-11-19T08:00:00.000Z"` (UTC) | `2026-11-19T08:00:00Z` | 11:00 ✓ |

So the API treats a **naked datetime as Asia/Riyadh local (+03)** and a **`Z`-suffixed string as
already UTC**, converting correctly in both cases. The website's two code paths use different
formats but both produce the right instant, because `toISOString()` on a local `Date` yields the
correct UTC. No bug.

**What the app must do:** every response timestamp comes back as **UTC with a `Z`**, so parse as UTC
and convert to local for display. When sending, pick one convention and hold it — simplest is the
naked `"YYYY-MM-DD HH:MM:SS"` local form taken straight from `checkout-context.appointment`. The
thing to never do is interpolate a local wall-clock into a `Z`-suffixed string.

---

## 5. `POST v1/portal/bookings/{id}/cancel` → `200`

Body `{}`. Returns the full booking with `status.value: 6` (`Cancelled`) and both `can_cancel` and
`can_reschedule` flipped to `false`.

## 6. `POST v1/portal/bookings/{id}/reschedule` → `200`

Body `{ "booking_start_time": …, "booking_end_time": … }`. Returns the full updated booking. Works
with either datetime convention per §4.

---

## 7. `GET v1/portal/payment-gateways` → `200` — 4 live on test

```json
[ { "slug": "cash",    "name": { "value": 1, "label": "Cash",    "label_ar": "نقدي" },   "logo": "http://erpapi-test.doctorstation.com/payment-logos/cash.svg",   "description": null },
  { "slug": "tabby",   "name": { "value": 3, "label": "Tabby",   "label_ar": "تابي" },   "logo": "…/tabby.svg",   "description": null },
  { "slug": "tamara",  "name": { "value": 4, "label": "Tamara",  "label_ar": "تمارا" },  "logo": "…/tamara.svg",  "description": null },
  { "slug": "paytabs", "name": { "value": 6, "label": "PayTabs", "label_ar": "باي تابس" }, "logo": "…/paytabs.svg", "description": null } ]
```

Two things to handle:

- **`name` is an object**, not a string — `{ value, label, label_en, label_ar }`. It carries its own
  localisation, so gateway labels do **not** go through `LocaleKeys`; read `label` (which already
  follows the `lang` header).
- **The logo URLs are `http://`, not `https://`.** iOS App Transport Security will block them
  outright and Android will warn. Either rewrite the scheme client-side or bundle the four logos as
  assets. Worth reporting upstream.

No Apple Pay, STC Pay or insurance gateway is live on test, so those branches of
`PAYMENT_TYPES` cannot be exercised yet.

## 8. `GET v1/portal/qitaf` → `200`

```json
{ "enabled": true, "redemption": null }
```

**Qitaf is switched on** on the test host, so it is a live part of checkout rather than dormant
code. Still needs a product decision on v1 scope.

---

## What I did to the test data

Full transparency, since this wrote to your test environment:

- Created booking **BK-00128** (doctor 3 / Creatinine / Al-Olaya, 19 Nov), rescheduled it twice
  while testing the datetime formats, then **cancelled it**. It now sits in `status=6`.
- Created pending gateway booking **PGB-64**. No payment was made; it expires on its own.
- Registered one throwaway patient, **0552207570** (`PAT-8D9B47D8`), to verify register → OTP →
  confirm, then used it to discover the reset-password body. Its password was changed during that
  test. Delete it whenever you like — it exists only as a test artefact.
- **Your account `0564772491` had nothing changed** — no password reset, no profile edit.
