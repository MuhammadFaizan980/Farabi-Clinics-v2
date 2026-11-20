# Website areas that use fixed data but should come from an API

Checked in the mobile view of v2.farabiclinics.com on 2026-11-20.

| # | Where on the site | What is fixed today | What it should use |
| :-- | :-- | :-- | :-- |
| 1 | Home, "Location Base Appointment" | Doctor counts are typed in the code: Riyadh 72, Medina 31, Dammam 17. The server has 7, 2 and 0. | A doctor count per region from the server |
| 2 | Home, "Location Base Appointment" | The city photos are not loaded. The code expects an image, but the regions API sends none. | An `image` field on each region |
| 3 | Home, banner slider | One local image repeated 5 times. | A banners API (or the offers API) |
| 4 | Branch list, branch page, home | Every branch shows a 4.8 rating, typed in the code. | The branch rating the API already sends (`rating_average`) |
| 5 | Doctor profile, "Working Hours" | The same sentence for every doctor: "Monday to Friday, 02:00 PM to 08:00 PM". | The working hours the API already sends for each branch (`working_hours`) |
| 6 | Doctor profile, green "online" dot | Always green. | An online status on the doctor |
| 7 | Doctors filter, "Consultation Fee" slider | Does nothing. The value is never sent anywhere. | A fee on the doctor and a fee filter on the doctors API |
| 8 | Reviews page | All testimonials, names and the video are fixed text in the translation files. | A reviews / testimonials API |
| 9 | About, Privacy, Terms | Fixed text. | An API for page content (if the text should be editable) |
| 10 | Home, "Virtual Clinic Services" (Video, Audio) | The cards only open the Specialities page. | A consultation API |
| 11 | Home, "Get Expert Medical Consultation" and the AI assistant button | Both only open the Specialities page. | A consultation / AI API |
| 12 | Header bell icon | Always shows an orange dot and does nothing. | A notifications API |
| 13 | Profile, My Wallet, Notifications, Change Passwords, Rate us | Marked "Soon" and not working. | Wallet, notifications, change-password and rating APIs |

Bad data, not static data: the countries service returns Pakistan with the code `3` instead of `PK`. The phone
pickers on sign in, sign up and forgot password work out the flag and dial code from that code, so Pakistan shows
with no flag and no dial code. The app leaves it out until the code is fixed.

Not a static-data problem, but a bug: **My Appointments is always empty.** The page asks the server for
`status=upcoming`, `completed` or `cancelled` (text). The server only accepts numbers (1 = created, 6 = cancelled)
and answers with an error, so the list shows "No appointments found" even when bookings exist.
