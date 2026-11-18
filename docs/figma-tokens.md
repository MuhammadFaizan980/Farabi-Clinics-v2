# Figma measurements (source of truth for pixel perfection)

Read from the file's **Properties** panel through the signed-in Chrome session on 2026-11-18.
This supersedes the "measurements are unreadable" conclusion in `figma-access-findings.md`: the
panel renders Layout, Typography and Colors for a selected node (cmd+click selects the deepest node).

Frame: `Home Screen - Default Specialities` (`2656:39889`) is **414 x 1,686**, radius 40. The design
base in `responsive_extensions.dart` is therefore 414pt wide / 896pt tall.

## Colours

| Token | Value | Notes |
| :--- | :--- | :--- |
| Brand red | `#CC1C1C` | active nav label, icons; also the 20% / 12% / 4% tints |
| Ink (text primary) | `#1D1D24` | headings, body, chips |
| Text secondary | `#797777` | location lines |
| Card border | `#211722` @ 4% | 1px |
| Card fill | `#FFFFFF` | |

## Typography (Neue Regrade)

| Use | Weight | Size | Line height | Letter spacing |
| :--- | :--- | :--- | :--- | :--- |
| Section title ("Book by Service", "Virtual Clinic Services") | 600 | 17 | 24 | 0 |
| Doctor name | 600 | 17 | 26 | 0 |
| Doctor location | 500 | 15 | 26 | 0 |
| Chip / specialty tag | 500 | 14 | 100% | 0 |
| Service tile label ("Dental") | 500 | 14 | 16 | 2% |
| Virtual-service card title | 500 | 18 | 22 | 0 |
| Bottom-nav label (active) | 600 | 14 | 100% | 0 |

## Components

| Component | Size | Radius | Fill / border |
| :--- | :--- | :--- | :--- |
| "Book by Service" card | 373 x 164 | 16 | `#FFFFFF`, 1px `#211722` 4% |
| Virtual-service card | 180 x 134 | 20 | linear gradient `#CC1C1C` 20% to `#FFFFFF` 0%, 1px `#CC1C1C` 4% |

Screen horizontal inset on Home is 20 (card `Left` = 20, width 373 on a 414 frame).

Add to this file as each screen is measured; every value here was read from Figma, none estimated.

## Branches list (`Branches Listview`, `2656:45811`)

Frame 414 x 1,252, fill `#F8F8F8`. Header is the same red block as Doctors (414 x 139, bottom radius 16,
status bar included).

| Element | Measurement |
| :--- | :--- |
| Title "Branches" | 18 / 28, 600, white, centred, y 64 |
| Map-search icon | 24 x 24, x 358, y 66 |
| City tab label | 15 / 24, +2% tracking, 600 active / 500 inactive, white, y 109; inactive at 64% |
| City pin icon | 13 x 15, white outline |
| Active underline | 32 x 2, `#FDDA2C`, y 137 |
| Card | 382 x 251 at x 16, radius 16, 1px `#211722` 4%, first card y 147, gap 8 |
| Photo | 366 x 119, 8 inset, radius 12 on top |
| Rating pill | 49 x 23, radius 16, 12 / 13 bold `#1D1D24`, 6 from photo top and right |
| Name | 17 / 26, 700, `#1D1D24`, 8 below photo, 16 inset |
| Address | Onest 14 / 24, 400, `#797777`, with an 18px red pin |
| Distance | 13.5 / 100%, 600, uppercase, `#797777`, 14px red arrow |
| Closes-at pill | 179 x 34, radius 100, padding 6/8, gap 4, fill `#211722` 2%, 13.5 / 600 |
| Call button | 136 x 34, radius 100, padding 6/12/6/8, gap 4, fill `#CC1C1C`, 13.5 / 600 white |

Distance and closing time are not in the branches API (no coordinates for the device, no hours on the list
payload), so those two rows are not rendered from data.

## More tab (`More tab_ Profile Setting`, `2656-48127`)

Frame 414 x 1,300, fill `#F8F8F8`.

| Element | Measurement |
| :--- | :--- |
| Header | 414 x 108, bottom radius 16, `#CC1C1C`; title "Profile Setting" 18 / 28, 600, white, y 64 |
| Profile card | 382 x 158 at x 16, y 117, radius 16 |
| Avatar | 80 x 80 group at x 31, y 131; photo 66.98 round; ring is a red progress arc |
| Name | 17 / 22, 600, `#1D1D24`, x 36, y 222; verified badge 17px `#1AB6C3` |
| Patient ID | 15 / 20, 500, 18px pulse icon, x 56, y 244 |
| Card chevron | 22 x 22, x 348, y 178 |
| Card art | circle 346 x 346, black 4%, x 113, y -22 |
| Stats card | 382 x 74 at y 277, radius 14, 1px `#211722` 4%, shadow 0 4 8 `#F2F2F2` 80% |
| Stat number | 20 / 24, 600, `#1D1D24`; label 14 / 23, 500, `#797777`; icons 18px; dividers `#797777` 32% |
| Section heading | 15 / 16, 700, +2% tracking, `#000`, x 22 |
| Menu row | 382 x 70 at x 16, radius 14, 1px black 4%; 4 between rows |
| Row title / subtitle | 15 / 20 600 `#1D1D24`, x 62 / 14 / 18 500 `#797777`; icon `#989898`; chevron 18px |
| Logout row | 378 x 70 at x 18, radius 14, 1px `#AC150A` 12%; title 15 / 20 700 `#AC150A`; icon 20px |

Not measured (the panel did not expose a fill): the profile card's own gradient. The app uses white to
`#F2F2F2`.
