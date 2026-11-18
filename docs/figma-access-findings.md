# Figma access — what the browser route gets us, and what it can't

Captured 2026-11-18 by driving the signed-in Chrome `personal` profile via AppleScript
(`View → Developer → Allow JavaScript from Apple Events` enabled by the requester).

## Status: connected

Reading the live Figma DOM works. Confirmed session, correct file, JS execution, and full
read access to the layers tree and its node ids.

## Correction: `node-id=25-12` was the right link all along

I previously patched the ticket to say `25-12` was the wrong target. **That was wrong, and I've
reverted it.** The page node ids, read from the pages panel's `data-page-row-id` attributes:

| Page | Node id |
| :--- | :--- |
| ⚙️ Medical maintenance Flow | `0:1` |
| 🎠 Web Playground | `25:10` |
| 🎲 Mobile App Playground & Archived | `93:5984` |
| 💼 HR - Final Approved Design | `25:9` |
| **🦷 Clinic - Final Approved Design** | **`25:12`** |
| ⚙️ ERP Dashboard Design | `31:4` |
| Style Guide & User Flows & Moodboard | `16:37` |
| Components | `16:38` |

So `node-id=25-12` **is** the `Clinic - Final Approved Design` page. The requester's point was
still correct — it isn't the HR system (that's `25:9`) — the file is just named after the HR
project while the booking-app design lives inside it.

## The screens that matter

At least 38 top-level frames on page `25:12`. The panel is virtualised, so treat this as a floor,
not a complete census. The **mobile app** frames — these are the booking app, and the reason this
page is the right source:

| Node id | Frame |
| :--- | :--- |
| `2656:39888` | Farabi Appointment App - Home Screen Design |
| `2656:52341` | Farabi Appointment App - Speciality Flow |
| `2656:41903` | Farabi Appointment App - Doctors Flow |
| `2656:33007` | Farabi Appointment App - Doctors Flow *(second frame, same name)* |
| `2656:45727` | Farabi Appointment App - Branches Flow |
| `2656:48126` | Farabi Appointment App - More Tab Flow |
| `2656:50571` | Frabi Appointment App - Doctors AI Matching Feature *(sic)* |
| `2574:695` | Farabi Appointment App - Speciality Flow *(earlier revision)* |
| `2475:410` | Frabi Appointment App - Doctors AI Matching Feature *(earlier revision)* |
| `2351:340` | Home Screen - Default Specialities |

Note there are **duplicate and superseded frames** (two "Doctors Flow", two "Speciality Flow", two
"AI Matching"). Which is canonical needs confirming before anything is built from them.

Website-design frames on the same page, for reference — these line up with the API inventory and
are useful for cross-checking behaviour, but are not the app:

`✅ _ Doctors_ Page` `4919:9692` · `✅ _ Branches_ Page` `4708:11821` · `✅ _ Specialties_ Page`
`4708:12395` and `4941:13637` · `✅ _ Book Appointment_ Page` `4855:3166` · `✅ _ Careers_ Page`
`4892:2124` · `✅ _ Job Details JD_ Page` `4892:2750` · `✅ _ Job Application Form_ Page`
`4913:4703` · `✅ _ Review/Social Proff_ Page` `4913:5290` · `✅ _ Service Review Rating_ Page`
`4973:17249` · `✅ _ 404_ Page` `4965:16712` · `✅ v1 _ Full Homepage_ (Clinical Clean)` `3324:34977`
· `✅ v1_ Flash Offer Modal` `3326:36623` · `Home Screen - v1.1` `5565:4832` · `Doctors Flow Screen
- v1.1` `5569:5574` · `Branch Flow Screen - v1.1` `5588:9123` · `Mix Screens for the Update - v1.1`
`5668:9840` · `🗂️ Archive_ Not Approved Design` `4352:23370`

There is also a `Style Guide & User Flows & Moodboard` page (`16:37`) and a `Components` page
(`16:38`) — those are where design tokens and the component library should come from, and are
probably more valuable for Step 1.8 than the screen frames.

## The blocker: exact dimensions and props are not available through the browser

This is the part that matters. Two independent walls, both verified:

**1. The account has view-only access to this file.** From Figma's own API, read with the session:

```json
{ "link_access": "view", "viewer_export_restricted": false, "editor_type": "design" }
```

With view-only access Figma **does not render the Design panel**, so there is no W / H / X / Y,
no corner radius, no padding, no typography fields. I selected a frame (Figma confirmed
"1 item selected") and the panel simply isn't in the DOM.

**2. Dev Mode is paywalled.** Switching to Dev Mode renders the inspect panel with the property
*names* present and every *value* blank — `display:`, `height:`, `padding:`, `justify-content:`,
`align-items:`, `gap:`, `flex:` with nothing after the colons. The containers Figma renders are
named, verbatim:

```
dev-mode-paywall-left-panel
dev-mode-paywall-right-panel
```

A scan of the whole document for anything matching `property: <number>px` returns **zero matches**.
So the numbers genuinely are not on the page — this isn't a selector problem I can work around.

**3. No internal export endpoint.** `viewer_export_restricted: false` says export is permitted, so
an SVG export would have carried exact geometry. But every internal export path I tried returns
404 (`/api/files/{key}/images`, `/api/images/{key}`, `/api/file_images/…`, `/api/figma_file_images/…`,
`/api/export`, `/api/files/{key}/export`), as does every node-tree path
(`/api/files/{key}/nodes`, `/pages`, `/canvases`, `/versions`, `/comments`). The only internal
endpoint that responds is `/api/files/{key}`, which returns file metadata and no geometry.

## What this means

The browser route delivers **structure and visuals** — node ids, names, hierarchy, and screenshots.
It cannot deliver **measurements**. Since the ticket's standing rule is that every component's
dimensions and props must be read from Figma before it is built, and never eyeballed, the browser
alone is not sufficient to satisfy that rule.

### The fix, in order of preference

1. **A Figma personal access token** (`Settings → Security → Personal access tokens`, scope
   *File content: read-only*). The REST API is **not** subject to the Dev Mode paywall and works
   on a free plan with view access, so this single step removes both walls at once.
   `GET /v1/files/iIPbNtYsBvTboLoa10yGhm?ids=2656:39888&geometry=paths` returns
   `absoluteBoundingBox`, `fontSize`, `fontWeight`, `letterSpacing`, `lineHeightPx`, `itemSpacing`,
   `paddingLeft/Right/Top/Bottom`, `cornerRadius`, `fills`, `strokes` — exact values, per node.
2. **Edit (or Dev Mode) access on the file** for the signed-in account, which would light up the
   Design panel in the browser and make the AppleScript route sufficient on its own.
3. **A design hand-off export** — the file's own `Style Guide` page exported to PDF/SVG, plus an
   asset export. Workable but manual and it goes stale.

Option 1 is one minute of work and is the only one that produces values precise enough to be
quoted in a PR.
