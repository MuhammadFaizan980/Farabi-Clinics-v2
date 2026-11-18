# v2.farabiclinics.com vs the app — feature gap

Captured 2026-11-18. Site side: read the live pages (`/en/...`) and probed routes (HTTP 200 vs 404).
App side: read from `lib/` (shell tabs, routes, More menu). The site is desktop-first, so mobile
behaviour here is inferred from its content, not from a mobile layout I could see.

## What the site has

| Site page | Route | Content |
| :--- | :--- | :--- |
| Home | `/en` | hero, quick **Book Appointment** widget (region tabs, Service, Branch, Doctor), stats (30+ specialties, 200+ doctors, 20+ branches), Before & After results, Top Rated Doctors, Our Branches (per region with counts), CTA |
| Doctors | `/en/doctors` | region filter, doctor cards with **Book** and **View Profile**, careers CTA |
| Branches | `/en/branches` | region filter, branch list, **View Details** |
| Specialities | `/en/specialities` | region tabs, specialty list, services with "N doctors available" |
| Offers | `/en/offers` | offers list |
| About Us | `/en/about` | text: history (1990, 22+ branches), specialties, vision, mission, strategy |
| News and Articles | `/en/blogs` | blog list |
| Reviews | `/en/reviews` | patient testimonials (static copy) |
| Careers | nav item (route not confirmed; `/en/careers` 404s) | jobs |
| Contact us | `/en/contact-us` | form: name, email, region, branch, service, phone, how did you hear |
| Privacy policy | `/en/privacy-policy` | static page |
| Terms and conditions | `/en/terms-and-conditions` | static page |
| Profile / Bookings / Checkout | `/en/profile`, `/en/bookings`, `/en/checkout` | account area and booking checkout |

Regions on the site: Dammam, Jeddah, Mecca, Medina, Riyadh.

## What the app has today

Bottom tabs: Home, Doctors, Branches, **Specialities**, More.
More menu: Profile, My bookings, Language, Contact us, Blogs.
Other routes: auth (language, login, register, OTP, forgot/reset), doctor / branch / service detail,
booking + success, bookings + reschedule, careers.

## Gaps

| # | Gap | Site | App | Backed by an API? |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Offers** | page + nav item | none (no screen, no tab) | `GET v1/portal/offers` exists, returns `[]` on test host |
| 2 | **About Us** | page | none | no (static text) |
| 3 | **Reviews** | page | none | no (static marketing copy) |
| 4 | **Privacy policy / Terms** | pages | none | no (static text) |
| 5 | **Home content** | quick booking widget, stats, Before & After, Top Rated Doctors, branches per region | placeholder (greeting, speciality strip, region list) | doctors, regions, `home/branches` yes; Before & After unknown |
| 6 | **Quick booking** (Service, then Branch, then Doctor) | on Home | booking only starts from a doctor / service | uses existing booking endpoints |
| 7 | **Region switcher** (5 regions) | on Doctors, Branches, Specialities, Home | not confirmed per screen | `v1/portal/regions` |
| 8 | **Careers** reachable | nav item | route exists, not in the More menu | yes |

## Figma vs both

- Figma bottom nav is **Home / Doctors / Offers / Branches / More**. The app has Specialities where
  Figma has Offers, and the site puts Specialities in its main nav. Decision needed.
- Figma-only features with no site page or confirmed API: **Virtual Clinic Services** (video / audio
  consultation), **Doctors AI Matching**, the floating AI button, "Get Expert Medical Consultation".
- Several Figma frames are duplicates or older revisions; the canonical ones need confirming.
