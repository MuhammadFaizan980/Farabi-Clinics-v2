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
