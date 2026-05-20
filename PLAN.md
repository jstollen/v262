# Summer '26 SE Release Tracker — Refined Build Plan

## Summary

Build a single-page HTML release tracker for Solution Engineers specializing in Agentforce Marketing. 34 qualifying features from the CSV (Release 262, not punted, with linked Solution Overviews). Styled with the MC CCO GTM brand kit. Hosted via GitHub Pages.

---

## Data Filtering Criteria (Applied)

From the 128 total features in the CSV:
- **Release 262 only** — exclude 264, 264.14, Cancelled, blank releases (8 excluded)
- **Not punted** — exclude features with col[6] punt flag or "Punted or Canceled" theme (21 excluded)
- **Has Solution Overview link** — col[22] must be non-empty (65 excluded)
- **Result: 34 qualifying features**

---

## Phase 1: Parse CSV → Structured JSON

### Step 1.1: Transform CSV rows into TRACKER_DATA

For each of the 34 qualifying features, create a JSON object:

```javascript
{
  id: "f001",                           // auto-generated
  theme: "1. Drive Adoption",           // col[0] — cleaned (remove owner names)
  themeNumber: 1,                       // extracted from theme prefix
  program: "Manage Consent...",         // col[2]
  feature: "Extend Customizable...",    // col[5]
  pmOwner: "Chad Jordan",              // col[7] — "Owner (PM)" column
  description: "...",                   // col[8]
  goals: "...",                         // col[9]
  engOwner: "...",                      // col[10]
  targetRelease: "262",                // col[12]
  actualRelease: "",                   // col[13]
  demoType: "BOTH!...",               // col[14]
  demoLink: "Preference Page...",     // col[19]
  vidyardLink: "",                    // col[21]
  soLink: "262 Solution Overview...", // col[22]
  customerValue: "...",               // col[24]
  persona: "...",                     // col[25]
  pmmLead: "...",                     // col[26]
  pft: "Channels",                    // derived — see PFT mapping below
  releaseStatus: "",                  // "Generally Available" or "" — cross-referenced from SO_DATA
  // SE Enrichment (Phase 3)
  talkTrack: "",
  helpArticleLink: "",
  slideLink: "",
  verticalVariants: {}
}
```

### Step 1.2: PFT Classification

Map each feature to a PFT category based on program/theme keywords:

| PFT | Mapping Rules (from program/feature/theme keywords) |
|-----|-----------------------------------------------------|
| **Marketing on Core** | Flow, Lists, Marketing Lists, Campaign, Guided Lead, Content Builder, AMPScript, Content Variables, BU/Business Units |
| **Channels** | Email, SMS, WhatsApp, Consent, Preference, Transactional, Conversational, Social Posting |
| **Intelligence** | UMI, Analytics, Intelligence, Dashboard, Attribution, ABM, Pipeline |
| **Personalization** | Personalization, SP, Salesforce Personalization |
| **Marketing Einstein** | Agent, Agentic, AI, Einstein, Answer Engine, Account Discovery |
| **Marketing Cloud Account Engagement** | MCAE, B2B, B2BMA, Convergence |

Features may map to multiple PFTs — use primary match. PFT filter dropdown only shows PFTs that have ≥1 qualifying feature.

### Step 1.3: Release Status Cross-Reference

Cross-reference each feature with the original tracker's SO_DATA to find `release_status`:
- Match by feature name similarity to SO name
- If matched and `release_status === "Generally Available"` → set to "Generally Available"
- Otherwise → empty (displayed as "—")

---

## Phase 2: Build the HTML Tracker

### Columns (matching original tracker pattern)

| # | Column Header | Source | Notes |
|---|---------------|--------|-------|
| 1 | **Feature** | col[5] | Clickable — expands detail panel |
| 2 | **Program** | col[2] | Theme grouping context |
| 3 | **PFT** | derived | PFT badge (color-coded) |
| 4 | **Status** | SO_DATA cross-ref | "Generally Available" badge or "—" |
| 5 | **Owner (PM)** | col[7] | First and last name of Product Owner |
| 6 | **Demo** | col[19] | Link icon if demo recording exists |

### Filters

| Filter | Type | Behavior |
|--------|------|----------|
| **PFT** | Dropdown | Only shows PFTs that have ≥1 feature. Dynamic population from data. |
| **Theme** | Dropdown | All 6 themes with qualifying features |
| **Status** | Dropdown | "All", "Generally Available", "Pending" |
| **Search** | Text input | Searches feature name, program, PM owner, description |

### Views (3 tabs)

1. **Features** (default) — Flat table of all 34 features with sort capability
2. **By Theme** — Accordion grouped by theme, sub-grouped by program
3. **By PFT** — Accordion grouped by PFT with feature cards

### Feature Detail (Expanded)

When a feature row is clicked, expand an inline detail panel showing:

| Section | Content |
|---------|---------|
| Description | Project description/scope |
| Goals/Metrics | Project goals |
| PM Details | PM Owner, Eng Owner, PMM Lead |
| Release Info | Target, Actual, Demo Type |
| Resources | Demo Recording link, SO Deck link, Vidyard link |
| Customer Value | Incremental value description |
| 🎤 Talk-Track | SE demo talk-track (Phase 3 — placeholder for now) |
| Industry Variants | Vertical-specific talk-track tabs (Phase 3) |

### Industry Variant UX Design

**Global Industry Filter** in the filter bar:
- Dropdown: "All Industries", "High-Tech", "Regulated Industries", "CBS", "Retail & Manufacturing", "Public Sector"
- When an industry is selected, ALL feature talk-tracks auto-filter to show the selected industry's variant (if one exists for that feature)
- Features without a specific variant for the selected industry show the default/core talk-track
- Visual indicator on each feature card showing which industries have variants available (small badge/tag)

**Per-feature fallback** (in the detail panel):
- If the global filter is "All Industries", show tabs within each feature's talk-track section
- Tab labels: "Core" | "High-Tech" | "Regulated" | "CBS" | "Retail/Mfg" | "Public Sector"
- Only show tabs for industries where a variant exists for that specific feature
- Default to "Core" tab

---

## Phase 3: Apply MC CCO GTM Brand Kit

Brand kit colors from `brand-config.json`:

| Element | Color | Token |
|---------|-------|-------|
| Header background | `#032D60` | --color-primary |
| Links, buttons | `#0176D3` | --color-accent |
| Stats highlights | `#1B96FF` | --color-sf-cloud |
| Background | `#FFFFFF` | --color-background |
| Surface/cards | `#F3F3F3` | --color-surface |
| Body text | `#181818` | --color-foreground |
| Muted text | `#706E6B` | --color-muted |
| Borders | `#DDDBDA` | --color-border |
| GA badge | `#2E844A` | --color-success |
| Warning/Watch | `#FE9339` | --color-warning |
| Error/At Risk | `#EA001E` | --color-error |

Typography: Inter (Google Fonts) with system fallback.
Tailwind CSS via CDN with `@theme` directive mapping brand tokens.

---

## Phase 4: Output & Deployment

### Files to generate:
- `index.html` — Complete single-page tracker
- `README.md` — Brief description

### GitHub Pages deployment instructions (user executes on internal network):
1. Create repo on `git.soma.salesforce.com`
2. Push `index.html` + `README.md`
3. Enable GitHub Pages on master branch
4. Access at `https://git.soma.salesforce.com/pages/USERNAME/se-release-tracker/`

---

## Execution Steps

| Step | Action |
|------|--------|
| 1 | Parse CSV → generate 34-feature JSON with PFT classification and release status |
| 2 | Build complete `index.html`: header, filters (PFT, Theme, Status, Search, Industry), 3 views, detail panels |
| 3 | Apply MC CCO GTM brand kit styling (Tailwind + brand tokens) |
| 4 | Add industry variant tab UI in feature detail panels (placeholder content for Phase 3 enrichment) |
| 5 | Create HTML artifact for preview |
| 6 | Provide GitHub Pages deployment package + instructions |
