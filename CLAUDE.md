# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a **Training Progress Tracker** for managing flight training progress (First IOE, Functional Date, Command Check, LRC, Interview, sectors flown). The active version is a single-page HTML application targeting SharePoint/Microsoft 365.

### Active Version - SharePoint Enhanced (`index-sharepoint-v3-enhanced.html`)
- **~3,700 lines** - Full-featured production version
- SharePoint REST API for data storage
- MSAL.js for Microsoft 365 authentication (delegated)
- Dual interface: User Portal + Admin Panel
- Analytics dashboard, change history, PDF import, Excel export
- Dedicated SharePoint Communication Site as backend

### Legacy Version - Google Sheets Edition (`index.html` / `index-2.html`)
- Google Sheets API for data storage
- Google Identity Services for authentication
- Kept for reference; SharePoint version is the active development target

**Common Technologies:**
- Pure vanilla JavaScript (no build tooling)
- TailwindCSS via CDN
- XLSX.js for Excel exports
- Chart.js for visualizations

## Current Architecture

### Dedicated SharePoint Site
- **Site URL**: `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
- **Site Type**: Communication Site (lightweight, no M365 Group overhead)
- **Site Owner**: mohamadshazreen.sazali@malaysiaairlines.com
- **Purpose**: Data backend and (pending) app hosting
- **Access**: "Everyone except external users" added as Members with Edit permission

### Why a Dedicated Site
Previously the app targeted the shared `FLTOPS-TRAINING` SharePoint site. This was changed to a dedicated site to:
- Avoid permission conflicts with shared departmental content
- Give full control over site settings and permissions
- Isolate training tracker data
- Eliminate dependency on other teams for site management

### Azure Function Approach (Abandoned)
An Azure Function backend was explored for app-only authentication but abandoned due to:
- Required cross-department IT involvement (Function App creation, Contributor access)
- Certificate management overhead
- Unnecessary complexity when delegated auth works with a dedicated site

### Authentication & Authorization

**Authentication**: MSAL.js delegated auth (browser popup)
- Client ID: `82a4ec5a-d90d-4957-8021-3093e60a4d70`
- Tenant ID: `8fc3a567-1ee8-4994-809c-49f50cdb6d48`
- Scope: `https://mabitdept.sharepoint.com/.default`
- Token storage: `sessionStorage` (cleared on browser close)
- Redirect URI: `window.location.origin` (dynamic)

**Admin Authorization**: `AdminUsers` SharePoint list
- `checkAdminAuth()` queries the `AdminUsers` list for the signed-in user's email
- If the email is not found, admin access is denied
- AdminUsers list columns: `Title` (name), `Email` (Microsoft 365 email)

**User Portal Authorization**: UI-level enforcement
- Trainees can only update their own record via Staff ID lookup
- Not API-level — technically savvy users could call SharePoint REST directly
- Acceptable for this use case

### Data Flow
```
User Browser → MSAL sign-in popup → Access token
          → SharePoint REST API (Training_Progress list)
          → In-memory cadets[] array → Render UI
```

## SharePoint List Schema

### Training_Progress List
| Column Name | Type | Notes |
|---|---|---|
| `Title` | Single line of text | Built-in, stores trainee name |
| `Batch` | Single line of text | |
| `Staff_ID` | Single line of text | |
| `Rank` | Choice: `CADET`, `SO`, `FO`, `CAPTAIN` | |
| `Fleet` | Choice: `B738`, `B738M`, `A330`, `A350` | |
| `First_IOE_Date` | Date | |
| `Functional_Date` | Date | |
| `Command_Check_Date` | Date | CUC batches only |
| `LRC_Date` | Date | |
| `Interview_Date` | Date | |
| `Sectors_Flown` | Number | |
| `Status` | Single line of text | |
| `Remarks` | Multiple lines of text | |
| `Last_Updated` | Date and time | |
| `Manual_Highlight` | Choice: `blue`, `green`, `red` | |

**Important**: Name is stored in `Title` (SharePoint built-in field), NOT a custom `Name` column. The code saves to `Title` and reads from `item.Title`.

### AdminUsers List
| Column Name | Type |
|---|---|
| `Title` | Single line of text (admin name) |
| `Email` | Single line of text (Microsoft 365 email) |

### Status Logic
- **In Progress**: Initial state, missing functional date
- **Functional** (blue): Has First IOE + Functional Date
- **Completed** (green):
  - CPC batches: First IOE + Functional + LRC + Interview
  - CUC batches: First IOE + Functional + Command Check + LRC + Interview
- **Special** (red): Manual override via `Manual_Highlight`

`Command_Check_Date` is only required for CUC batches. The `isCUCBatch()` function checks if the batch name contains "CUC". CUC batches require all 5 dates (First IOE, Functional, Command Check, LRC, Interview) to be marked as completed.

Manual highlight takes precedence over automatic status detection.

## Configuration

### Security Constants (hardcoded in HTML)
```javascript
const ALLOWED_SITE_URL = 'https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker';
const ALLOWED_LIST_NAME = 'Training_Progress';
```
- Site URL is validated before every API call via `validateSharePointUrl()`
- Config panel is hidden in production (`class="hidden"`)

### Azure AD App Registration
- **Client ID**: `82a4ec5a-d90d-4957-8021-3093e60a4d70`
- **Tenant ID**: `8fc3a567-1ee8-4994-809c-49f50cdb6d48`
- **Delegated permissions granted**: `User.Read`, `Sites.ReadWrite.All`, `Sites.Selected`
- **Site-level permission**: Write access granted via PowerShell `Grant-PnPAzureADAppSitePermission`
- **Redirect URI**: Needs to be updated to match final hosting URL

## Key Functions

### Authentication
- `initializeMSAL()`: Initializes MSAL client, checks for existing sessions
- `signIn()`: Popup authentication flow
- `acquireTokenAndLoadData()`: Silent token refresh
- `checkAdminAuth()`: Queries AdminUsers list to verify admin access

### SharePoint Operations
- `loadDataFromSharePoint()`: GET items from Training_Progress list (top 5000)
- `saveTraineeToSharePoint()`: POST (create) or POST+MERGE (update) items
- `deleteTraineeFromSharePoint()`: POST+DELETE by item ID
- `getListItemEntityType()`: Gets OData metadata for proper API calls
- `testSharePointConnection()`: Validates site/list accessibility

### Data Management
- `filterCadets()`: Applies search, year, batch, rank, fleet, status, training type filters
- `renderTable()`: Renders filtered/sorted data to DOM
- `getTraineeStatus()`: Determines status based on date completion and batch type
- `isCUCBatch()`: Returns true if batch name contains "CUC"

### Error Handling
- Save errors now return the full SharePoint response body for debugging
- Console logging with `[OK]`, `[ERROR]`, `[DENIED]` prefixes

## Files

| File | Description | Status |
|---|---|---|
| `index-sharepoint-v3-enhanced.html` | SharePoint version, full-featured | **ACTIVE - upload this** |
| `progress-tracker.html` | Copy of enhanced version (kept in sync) | Mirror |
| `tracker.html` | Renamed copy for clean URL | For deployment |
| `index.html` | Google Sheets version (v2.2) | Legacy |
| `index-2.html` | Google Sheets version (updated) | Legacy |
| `index-sharepoint.html` | Original SharePoint template | Archived |
| `CLAUDE.md` | This file | |
| `SETUP_GUIDE.md` | SharePoint/Azure AD setup instructions | |
| `QUICK_REFERENCE.md` | End-user quick reference | |
| `EMAIL_TO_IT_SHAREPOINT_SETUP.md` | Latest IT email draft | |

## Deployment Status

### Current State: Live on GitHub Pages
- **Live URL**: `https://mab-fo-training.github.io/`
- **Hosting repo**: `mab-fo-training/mab-fo-training.github.io` (public, GitHub Pages)
- **Source repo**: `mr-shzrn/microsoft-training-tracker` (private, source of truth)
- **Redirect URI**: `https://mab-fo-training.github.io` registered in Azure AD (SPA)
- **GitHub Pages config**: Deploy from main branch, / (root), `index.html` at root

### Deployment Workflow
When updating the app:
1. Edit `index-sharepoint-v3-enhanced.html` in the source repo
2. Upload the updated file as `index.html` to the `mab-fo-training.github.io` repo
3. GitHub Pages auto-deploys within 1-2 minutes

### Previous Hosting Attempts (Abandoned)
- **SharePoint document library**: Blocked by tenant-level NoScriptSite policy (IT confirmed `NoScriptSite` blank = default blocked). Modern SharePoint does not render HTML files from document libraries.
- **Azure Static Web Apps**: No Azure subscription available from IT.

## Development Notes

### Common Issues Encountered
- **HTTP 400 on save**: Caused by sending fields that don't exist in SharePoint list (e.g., `Fleet`, `Sector_History`, `Name`). Only send columns that exist.
- **Name field empty**: SharePoint uses `Title` as the built-in name field. Custom `Name` column conflicts with SharePoint internals. Always use `Title` for trainee name.
- **HTML preview instead of rendering**: SharePoint tenant-level NoScriptSite policy blocks HTML execution even when site-level DenyAddAndCustomizePages is disabled.
- **Rank mismatches**: SharePoint Choice columns must exactly match the values in the code. Current values: `CADET`, `SO`, `FO`, `CAPTAIN`.

### Testing Locally
```bash
python -m http.server 8000
# Open http://localhost:8000/index-sharepoint-v3-enhanced.html
```

### Modifying Data Schema
1. Add column in SharePoint list (exact case-sensitive name)
2. Update mapping in `loadDataFromSharePoint()` — reads from `item.ColumnName`
3. Update mapping in `saveTraineeToSharePoint()` — writes `ColumnName: value`
4. Update modal form fields in HTML
5. Update table headers and render logic

### Security Measures
- URL validation: All API calls checked against `ALLOWED_SITE_URL`
- HTML escaping: `escapeHtml()` function prevents XSS
- Session timeout: 30-minute inactivity timeout
- Token storage: `sessionStorage` (cleared on browser close)
- Admin auth: Email checked against AdminUsers SharePoint list
- Config panel: Hidden in production UI

## Power Automate Integration

### Trainer Submission Form
A Microsoft Forms form (`https://forms.office.com/r/aBkYkEMw1f`) is used by trainers to submit trainee progression updates. An existing Power Automate flow sends email notifications on submission.

**Form fields:**
1. NAME OF TRAINEE (text)
2. STAFF NUMBER (text)
3. FLEET (choice: A350, A333, B737) — ignored, already in SharePoint
4. TOTAL SECTORS (number)
5. DATE (date, M/d/yyyy)
6. Progression Stage (choice — see mapping below)

### Power Automate → SharePoint List Update

The flow should be extended to update the `Training_Progress` list automatically after the email action.

**Flow steps:**
1. **Get items** — filter `Training_Progress` by `Staff_ID eq '[Staff Number]'`
2. **Condition** — check if trainee exists
3. **If yes** — Switch on Progression Stage to update the correct field
4. **If no** — send notification (trainee should already exist in list)

**Progression Stage → SharePoint field mapping:**

| Progression Stage | Action |
|---|---|
| Cleared Functional | `Functional_Date` = form DATE |
| Line Release Check COMPLETED | `LRC_Date` = form DATE |
| Command Check COMPLETED | `Command_Check_Date` = form DATE |
| Cleared for Line Release Check | `Remarks` = append "Cleared for LRC - [DATE]" |
| Cleared for Command Check | `Remarks` = append "Cleared for Command Check - [DATE]" |
| REFERRED TO SIP | `Manual_Highlight` = "red", `Remarks` = append "Referred to SIP - [DATE]" |

**All submissions also update:**
- `Sectors_Flown` = form TOTAL SECTORS
- `Last_Updated` = `utcNow()`

**Notes:**
- Fleet from form (A350/A333/B737) is ignored — the SharePoint list already has this data
- Only completed stages update date columns; "Cleared for" stages go to Remarks
- "REFERRED TO SIP" sets the manual highlight to red (flags the trainee in the tracker UI)

## Pending Fixes / Improvements

### Functional
1. **Admin password field is misleading** — In SharePoint mode, the password field is ignored. Auth checks the signed-in user's email against the `AdminUsers` list. Remove the password field or repurpose it.
2. **`sectorHistory` never persisted to SharePoint** — Tracked in-memory only; resets to `[]` on every SharePoint reload. Needs a SharePoint column (e.g., Multiple lines of text storing JSON) to persist.
3. **`getYearFromBatch()` only handles `YY/...` format** — Regex `^(\d{2})` won't match batch names like `CUC-2024-01` or `2024-01`. Year filter won't show these batches.

### UX
4. **`alert()` used for all notifications** — Blocks the UI. Replace with toast/inline notifications.
5. **No loading indicators** — No spinner or progress feedback while loading data from SharePoint.
6. **Power BI button is just Excel export** — `exportPowerBIBtn` calls `exportToExcel()`. Misleading label with no actual Power BI integration.

### Performance
7. **`escapeHtml()` creates a DOM element per call** — Uses `document.createElement('div')` each time. For large tables (5000 rows), a string-replace approach would be faster.

### Security (minor)
8. **CSP allows `unsafe-inline` and `unsafe-eval`** — Weakens Content Security Policy, though `unsafe-eval` is required by Tailwind CDN.

### Accessibility
9. **No ARIA labels or keyboard navigation** — Table rows, modals, and buttons lack screen reader support.
