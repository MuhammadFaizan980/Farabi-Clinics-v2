# v2.farabiclinics.com (real mobile view) vs the V2 app: feature gap matrix

Captured 2026-11-20. Site side: the built-in browser at 375x812 with the **mobile preset** (Android UA, touch).
That preset serves the site's real app-style mobile UI (bottom nav: Home / Doctors / Offers / Branches / More).
An earlier pass used a narrow desktop layout; this document supersedes it.
App side: read from `lib/` on branch `dev` (working tree) and from the simulator.

Legend: ✅ matches · 🟡 partial / differs · ❌ missing · 🧱 stub (control exists, does nothing) ·
**S** static content (ships in the app; export from the site) · **API** must come from an endpoint.

Signed-in pages (More, bookings, profile, bell) were not reachable in the browser pane yet: see section 12.

## Status after the functionality pass (2026-11-20)

Tested on the iPhone 17 simulator unless noted. UI is not matched to Figma yet, that is the next pass.

| Area | State |
| :-- | :-- |
| Home: AR/EN toggle, search to Specialities, Virtual Clinic and Expert cards to Specialities, View all, region card opens Branches on that region, AI button | done, tested |
| Home banner | stays offers-API driven (the site's banner is a hardcoded placeholder), autoplay added |
| Specialities (region tabs, speciality picker, services with doctor rails) | done, tested |
| Doctors tab: grid toggle, live search, filter sheet (gender, location, rating) | done, tested. Fee slider not built (inert on the site) |
| Doctor profile: stats, overview, services, real working hours, branches with hours, Book | done, tested |
| Branch detail: services rail, doctors per service, empty state | done, tested. Call dials when the branch has a phone |
| Contact us: region, branch (by region), service (by branch), phone, source | done, tested |
| Careers: server-side department filter and search, job detail, apply form (all fields, DOB format, CV rule, consents) | done, tested up to validation. A real submission was not sent |
| Booking then Review & Pay: promo code, Qitaf, payment methods from the API, swipe to pay, free and Qitaf-covered rules | done. Cash booking tested end to end (BK-00134). Promo error tested. Qitaf and card gateways are written to the contract but not exercised live |
| Guest booking: sign-in returns to the booking | done (unit-tested, not walked through) |
| My Appointments: Upcoming / Completed / Canceled, inline cancel error, reschedule refresh | done, tested (cancel flow too). Fixed the site's empty-list bug on our side |
| Reschedule: AM/PM labels, past slots hidden | done |
| More: in-place language switch | done, tested |
| Sign in, sign up, forgot password: same fields and steps as the web sheets; country picker (flag, dial code, search) filled from the countries API, Saudi Arabia first; national number and country code posted as the site does; no confirm-password; ID type starts empty; forgot ends on "Check your messages" | done, tested on the simulator. Red wordmark header kept (the web's colour logo was not downloaded) |
| Language screen never applying the locale | fixed |

Not done on purpose or blocked:

- Reviews page extras (more testimonials, photos, video) and About page icons: static assets, UI pass.
- "Soon" rows in More (wallet, notifications, change password, rate us, biometric): stubs on the site.
- Register: the site has no confirm-password field; the app keeps it. The site's OTP step was not observed.
- Card, Tabby and Tamara payments open the gateway page and confirm afterwards, but could not be tried (no live gateway).
- Qitaf needs a live code from STC to try.

## 0. Server vs static: verified from the site's own code (2026-11-20)

The site's mobile bundle was scanned for every endpoint it calls and for hardcoded values.

**Endpoints the site calls** (the complete set): `auth/{login,register,otp/confirm,otp/resend,forgot-password,reset-password}`,
`profile`, `v1/profile/update`, `regions`, `services/main`, `services`, `branches`, `home/branches`, `doctors`,
`doctors/{id}/slots`, `offers`, `blog`, `blog/{id}/comments`, `careers`, `careers/departments`,
`careers/{id}/applications`, `contact-us`, `countries`, `checkout-context`, `checkout-links/{x}`, `payment-gateways`,
`bookings` (+ cancel, reschedule), `pending-bookings/{id}/confirm`, `qitaf`, `qitaf/otp`, `qitaf/redemptions`.
There is **no** banners, sliders, testimonials, notifications, wallet or fee-filter endpoint.

| Item | Verdict | Decision for the app |
| :-- | :-- | :-- |
| Home banner carousel | **Placeholder.** One local file (`/imgs/promo-banner-offers.png`) repeated 5 times; banner endpoints all 404 | Do not ship it. Keep the offers-API carousel, hidden when empty |
| Branch rating "4.8" | **Hardcoded literal** in three components; API `rating_average` is 0 | Show a rating only when the API has one |
| Home region counts 72 / 31 / 17 | **Hardcoded object** `{Riyadh:72, Medina:31, Dammam:17}` | Keep real counts from the doctors API |
| Home region card image | `region.image` from API, gradient when absent | Keep gradient fallback; bundled city photos stay only where Figma has them |
| Consultation-fee slider | UI only. The slider value is never sent to `doctors` (only `page`, `region_id`, `search`, `gender`, `ratings`) | Do not build |
| Gender / location / rating filters | Sent to the API (`gender`, `region_id`, `ratings`) | Build |
| Reviews and About copy | Static translation strings, no endpoint | Static in the app |
| Payment-method list | `payment-gateways` API; logos mapped per slug in the bundle | List from API, logo assets static |
| My Wallet, Notifications, Change Passwords, Rate us | `comingSoon` stubs | Optional "Soon" rows |
| Biometric Login | Disabled switch | Optional, disabled |
| Bell | No handler on the site | Leave as is |
| Doctor online dot | Always green (static) | Static dot |
| Doctor Overview fallback sentence, tags, stats, services, hours | API with a translated fallback | API |
| Specialities tile / doctor / service images | `image_url` / `image` from API, placeholder asset when null | API + placeholder |

## 1. Header and global

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 1.1 | FARABI wordmark top left | wordmark | ✅ |
| 1.2 | **AR/EN toggle** in the header; switches language in place, RTL mirrors the whole layout | only More > Language (full-screen picker) | ❌ add header toggle |
| 1.3 | Bell with orange unread dot | bell exists, `onBellTap` never set | 🧱 |
| 1.4 | Profile icon: signed out opens a **bottom-sheet sign-in**; signed in opens profile | pushes full-screen login / profile | 🟡 |
| 1.5 | Header on inner pages: red block, back arrow, centred title | Specialities, Booking only | 🟡 other screens still use the old AppBar |
| 1.6 | Bottom nav Home, Doctors, Offers, Branches, More | same | ✅ |
| 1.7 | Tapping **More** signed out opens the sign-in sheet (More needs login) | More tab shows a guest card | 🟡 |
| 1.8 | Empty / loading illustrations (clipboard mascot, pulse loader) | shimmer lists, generic empty view | 🟡 **S** assets |

## 2. Home

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 2.1 | Search field; focusing it opens **Specialities** (no query carried) | fake field switches to the Doctors tab | 🟡 wrong target |
| 2.2 | Banner carousel with dots; slides are one hardcoded placeholder image repeated (see section 0) | carousel of **offers API**, hidden when empty, no autoplay | ✅ keep API-driven; add autoplay only |
| 2.3 | Book by Service card: tiles from main services | same grid | ✅ API |
| 2.4 | Virtual Clinic cards (Video, Audio) tap to Specialities | display only | 🧱 |
| 2.5 | Available Doctors rail with **View all** to Doctors | rail, no View all | 🟡 |
| 2.6 | Get Expert Medical Consultation card; **Visit Consultation** goes to Specialities | link goes to Contact us | 🟡 wrong target |
| 2.7 | Location Base Appointment region cards; tap opens Branches **on that region** | tab switch, region not selected | 🟡 |
| 2.8 | Region counts "N Doctors Available" | per-region doctors total from API | ✅ (the site shows 72 / 31 / 17 against API 7 / 2 / 0; site numbers look like placeholders, app keeps real data) |
| 2.9 | CBAHI block | CBAHI logo | ✅ |
| 2.10 | Floating AI assistant button, opens Specialities | not built | ❌ |
| 2.11 | Doctor card tap opens profile | same | ✅ |

## 3. Specialities (site page `/specialities` and `/specialities/{id}?region=`)

The page I built from the desktop layout does **not** match the mobile one.

| # | Site (mobile) | App | Status |
| :-- | :-- | :-- | :-- |
| 3.1 | Red header "Choose Your Speciality" with **region tabs inside the header** (pin icon, underline) | MoreHeader + pill chips | 🟡 |
| 3.2 | "Choose Speciality" card: icon tiles per main service, selected tile gets a red border and check badge; nothing selected shows "Select a speciality to see available treatments." | pill chips with "All" | 🟡 |
| 3.3 | Selecting a tile loads that speciality's services (URL `/specialities/{id}?region=`) | same data | ✅ API |
| 3.4 | Service card: title, green dot "N Doctors Available", horizontal **doctor card rail** (photo panel, name, branch, tags); tap a doctor opens profile; no Book buttons in the list | vertical rows with Book / View Profile buttons | 🟡 rebuild |
| 3.5 | Service with 0 doctors shows just the title and "0 Doctors Available" | same | ✅ |
| 3.6 | Default region = Riyadh | first region | ✅ |

## 4. Doctors tab

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 4.1 | Header: title, **Open filters** button, **Toggle view** (list / 2-column grid) | filter FAB; grid icon is decorative | 🧱 grid toggle |
| 4.2 | Region selector pill | popup menu | ✅ |
| 4.3 | **Live** search | search on submit | 🟡 |
| 4.4 | Filter sheet: Doctor Gender (Male / Female / Any), Location (region checkboxes), Consultation Fee (range slider 100 to 2,500 SAR, **inert on the site**), Doctor Rating (5 to 1 star checkboxes), Apply Filter | sheet with gender only | ❌ location, rating (API `region_id`, `ratings`); fee slider deliberately not built |
| 4.5 | Doctor card: photo panel, name, branch | same, plus service chips row (Figma) | ✅ |
| 4.6 | List shows all doctors, no paging UI | "Continue" load-more footer | 🟡 |

## 5. Doctor profile `/doctors/{id}`

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 5.1 | Red header with back arrow and doctor name | old AppBar | ❌ restyle |
| 5.2 | Avatar card: photo, online dot, name, verified badge | text only | ❌ |
| 5.3 | Stats row: Patients, Experience, Satisfaction ("—" when empty) | patients and years only when present | 🟡 |
| 5.4 | Overview text | brief summary | ✅ API |
| 5.5 | Services Offered chips (`services?doctor_id`) | missing | ❌ API |
| 5.6 | Working Hours summary ("Monday to Friday, 02:00 PM to 08:00 PM") | missing | ❌ API (branch `working_hours` in doctor detail) |
| 5.7 | Branches & Working Hours: paged cards (prev / next), each opens branch detail, shows hours | branch chips, no hours, not tappable | ❌ API |
| 5.8 | Fixed **Book** bar at the bottom | Book now button in the page | 🟡 |

## 6. Booking `/doctors/{id}/book`

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 6.1 | Doctor card, treatments, branch, month tabs + day chips, AM/PM times, fixed Confirm | rebuilt and verified on the simulator | ✅ |
| 6.2 | Signed out + select slot leads to sign-in | pushes login; **flow is lost after login** (`resetTo(shell)`) | 🟡 |
| 6.3 | Review and payment (Cash, Tabby, Tamara, PayTabs) | review + chips; **online gateways not implemented** (shows an error) | 🟡 |
| 6.4 | Success screen, bookings list | old styling | 🟡 restyle |

## 7. Branches tab and branch detail

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 7.1 | Region tabs with pins in the red header; tapping a Home region opens `?region=` | region tabs, no deep link | 🟡 |
| 7.2 | Card: illustration fallback image, rating pill (**4.8 hard-coded**, API rating is 0), name, address | photo placeholder, rating hidden at 0, address, Call pill | 🟡 **S** illustration; do NOT copy the fake 4.8 |
| 7.3 | No Call / distance on the site list | Call pill (opens detail, does not dial), no distance | 🧱 |
| 7.4 | Detail header with back + branch name | old AppBar | ❌ restyle |
| 7.5 | Detail: image card (rating, name, address) | name, address only | ❌ |
| 7.6 | Detail: **Choose Speciality** rail of the branch's services | missing | ❌ API (`branches/{id}` returns `services`) |
| 7.7 | Detail: a section per service with doctor count and doctor rail, or the "No Doctor Available" empty state | missing | ❌ API |
| 7.8 | Call / Directions | disabled buttons that do nothing | 🧱 (site has neither) |

## 8. Offers

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 8.1 | Red header "Offers", empty illustration, "No offers right now" | old AppBar + generic empty view | 🟡 restyle + **S** illustration |
| 8.2 | Offer cards (shape unknown, no data on the test host) | name and description only | 🟡 |

## 9. Contact us

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 9.1 | Red header + back, "We're Here to Help." intro | old AppBar | ❌ restyle |
| 9.2 | Name\*, Email, **Region** (segmented), Branch\* (by region), Service\* (by branch), Phone\* with +966 picker, How did you hear\*, Apply | no Region; branch and service not dependent | ❌ |

## 10. Careers

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 10.1 | List: Current Job Openings header, department dropdown, **search**, cards with View Details | chips filter, cards not tappable | 🟡 |
| 10.2 | **Job detail** `/join-our-team/{slug}`: type pill, title, branch / experience / posted, **Apply Now**, **Download Job Description**, About the Role, Key Responsibilities, Requirements, What We Offer, Perks & Benefits, Job Overview, Share | missing | ❌ API (`careers/{slug}` returns these) |
| 10.3 | **Apply form** `/apply`: personal, professional (SCFHS licence, specialization), education, CV upload (PDF / DOCX, 5 MB), cover letter, references, two consents, Submit | missing | ❌ API (`careers/{id}/applications`), needs file picker |

## 11. Blogs, Reviews, About, policies

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 11.1 | Blogs: hero "Al-Farabi Medical Blog / Everyday Health", empty "No blogs found." | old cards, no hero | 🟡 |
| 11.2 | Reviews: testimonial carousel with photos, arrows, dots, plus video testimonials | 3 text cards | ❌ **S** photos / videos |
| 11.3 | About: logo, intro, grid of 11 specialty icons, vision, message, strategy | text only | ❌ **S** icons |
| 11.4 | Privacy, Terms | text pages, old styling | 🟡 restyle |

## 12. Signed-in pages (verified 2026-11-20 with a test account in the browser pane)

| # | Site | App | Status |
| :-- | :-- | :-- | :-- |
| 12.1 | **More** is titled "Profile Setting": profile card (avatar, name, Patient ID), stats (Upcoming / Booked / Total Visits), Your Activity: **Your Appointments**, My Wallet (**Soon**); Account Settings: **Language switch**, Notifications (Soon), Change Passwords (Soon), Privacy Policy, Terms and Conditions; Contact and Support: **Contact Us**, Rate us (Soon), Biometric Login, Logout | Figma-styled; rows for bookings, language, about, specialities, contact, blogs, careers, reviews, privacy, terms; logout. No wallet / notifications / change password / rate us / biometric rows | 🟡 the site has no About, Specialities, Blogs, Careers or Reviews in More (the app keeps them); missing the "Soon" rows |
| 12.2 | Language is an **in-place switch** in More (flips to `/ar`, RTL) | opens a full-screen picker and resets the stack | 🟡 |
| 12.3 | Tapping the profile card opens an **Edit Profile bottom sheet**: first name, last name, email, ID / IQAMA, phone (read-only) | full ProfileScreen with old styling | 🟡 restyle as sheet |
| 12.4 | **My Appointments**: red header with tabs Upcoming / Completed / Canceled (yellow underline), empty "No appointments found." (the site list stayed empty even for a booking created minutes earlier; the card design could not be observed) | AppBar, chips All / Created / Cancelled, cards with Reschedule / Cancel | 🟡 restyle, rename tabs |
| 12.5 | Bell: **does nothing on the site either** (signed in or not) | does nothing | ✅ parity |
| 12.6 | Slot then Confirm opens a separate **Review & Pay** page: doctor mini-card with price, Branch (edit pencil), Date & Time (edit pencil), **Promo code** (Apply), **Qitaf points** (phone + Send code), Payment Details (fee, total), Payment Methods as logo radios (Cash, Tabby, Tamara, PayTabs), **Swipe to Pay** slider | review and gateway chips live on the booking page, Confirm button, no promo, no Qitaf, no swipe | ❌ |
| 12.7 | **Success page**: confetti, large gradient check, "Thanks, your booking has been confirmed.", receipt-by-email note, summary card (doctor, service, Confirmed badge, branch, date and time), "See all details", Back to Home | plain check, reference number, two buttons | 🟡 restyle |
| 12.8 | Register has First / Last name, ID type, ID number, phone, password (**no confirm field**) | has confirm-password; OTP step in app (site's not observed) | 🟡 |

## 13. App-side defects found by the inventory (independent of the site)

1. Language screen may never apply `setLocale` in-session (`await resetTo(shell)` before returning the locale).
2. Booking after guest login loses the flow.
3. Reset-password success shows no message; logout has no confirm or API call.
4. Reschedule result is ignored, the bookings list stays stale.
5. A failed cancel replaces the whole list with the full-screen error view.
6. Reschedule shows raw 24-hour labels, Booking shows AM/PM.
7. Shared empty / error / shimmer widgets and the shell background use the old palette (dark-mode mix).
8. No `url_launcher` / file picker / notification packages: Call, Directions, CV upload, bell cannot work.
9. Specialities issues N+1 doctor requests per load.
