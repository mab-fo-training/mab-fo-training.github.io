# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a **Training Progress Tracker** for managing flight training progress (First IOE, Functional Date, Command Check, LRC, Interview, sectors flown). The active version is a single-page HTML application targeting SharePoint/Microsoft 365.

### Active Version - SharePoint Enhanced (`index-sharepoint-v3-enhanced.html`)
- **~4,000 lines** - Full-featured production version
- SharePoint REST API for data storage
- MSAL.js for Microsoft 365 authentication (delegated)
- Dual interface: User Portal + Admin Panel
- Analytics dashboard, change history, PDF import, Excel export
- Toast notifications (non-blocking) and loading spinner overlay
- User Portal progress timeline (visual milestone stepper)
- Sector history persistence via SharePoint column (JSON)
- Dedicated SharePoint Communication Site as backend

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
- **Purpose**: Data backend
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
| `Sector_History` | Multiple lines of text | JSON array of sector change records |

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
- **Redirect URI**: `https://mab-fo-training.github.io` registered as SPA type

## Key Functions

### Authentication
- `initializeMSAL()`: Initializes MSAL client, checks for existing sessions
- `signIn()`: Popup authentication flow
- `acquireTokenAndShowApp()`: Silent token refresh
- `checkAdminAuth()`: Queries AdminUsers list to verify admin access

### SharePoint Operations
- `loadDataFromSharePoint()`: GET items from Training_Progress list (top 5000)
- `saveTraineeToSharePoint()`: POST (create) or POST+MERGE (update) items
- `deleteTraineeFromSharePoint()`: POST+DELETE by item ID
- `getListItemEntityType()`: Gets OData metadata for proper API calls
- `testSharePointConnection()`: Validates site/list accessibility
- `ensureSectorHistoryColumn()`: Checks/creates Sector_History column on first load

### Data Management
- `filterCadets()`: Applies search, year, batch, rank, fleet, status, training type filters
- `renderTable()`: Renders filtered/sorted data to DOM
- `getTraineeStatus()`: Determines status based on date completion and batch type
- `isCUCBatch()`: Returns true if batch name contains "CUC"
- `getYearFromBatch()`: Extracts year from batch names (`24/05`, `CUC-2024-01`, `2024-01`)

### UX Functions
- `showToast(message, type, duration)`: Non-blocking toast notifications (success/warning/error/info)
- `showLoading(message)` / `hideLoading()`: Full-screen loading spinner overlay
- `renderProgressTimeline(cadet)`: Visual milestone stepper in User Portal

### Error Handling
- Save errors return the full SharePoint response body for debugging
- Console logging with `[OK]`, `[ERROR]`, `[DENIED]` prefixes
- Toast notifications for all user-facing messages (no `alert()` calls)

## Files

| File | Description | Status |
|---|---|---|
| `index-sharepoint-v3-enhanced.html` | SharePoint version, full-featured | **ACTIVE** |
| `docs/index.html` | Copy of above for GitHub Pages deployment | **DEPLOYED** |
| `CLAUDE.md` | This file | |
| `SETUP_GUIDE.md` | SharePoint/Azure AD setup instructions | |
| `QUICK_REFERENCE.md` | End-user quick reference | |
| `POWER_AUTOMATE_GUIDE.md` | Step-by-step Power Automate flow instructions | |

**Removed files** (no longer in repo):
- `index.html`, `index-2.html` — Legacy Google Sheets versions, removed due to exposed API key

## Deployment Status

### Current State: Live on GitHub Pages
- **Live URL**: `https://mab-fo-training.github.io/`
- **Hosting repo**: `mab-fo-training/mab-fo-training.github.io` (public, GitHub Pages)
- **Source repo**: `mr-shzrn/microsoft-training-tracker` (private, source of truth)
- **Redirect URI**: `https://mab-fo-training.github.io` registered in Azure AD (SPA)
- **GitHub Pages config**: Deploy from main branch, / (root), `docs/index.html`

### Deployment Workflow
When updating the app:
1. Edit `index-sharepoint-v3-enhanced.html` in the source repo
2. Copy to `docs/index.html`
3. Commit and push both remotes: `git push origin main && git push pages main`

### Remotes
- **origin** (HTTPS): `https://github.com/mr-shzrn/microsoft-training-tracker.git`
- **pages** (SSH): `git@github.com:mab-fo-training/mab-fo-training.github.io.git`

### Previous Hosting Attempts (Abandoned)
- **SharePoint document library**: Blocked by tenant-level NoScriptSite policy
- **Azure Static Web Apps**: No Azure subscription available from IT

## Development Notes

### Common Issues Encountered
- **HTTP 400 on save**: Caused by sending fields that don't exist in SharePoint list (e.g., `Name`, unknown columns). Only send columns that exist. The `Sector_History` field is conditionally included only after confirming the column exists via `sectorHistoryColumnEnsured` flag.
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
- HTML escaping: `escapeHtml()` function prevents XSS (string replacement, not DOM-based)
- Session timeout: 30-minute inactivity timeout
- Token storage: `sessionStorage` (cleared on browser close)
- Admin auth: Email checked against AdminUsers SharePoint list
- Config panel: Hidden in production UI
- Legacy Google API keys removed; Google Cloud API keys deleted

## Power Automate Integration

### Trainer Submission Form
- **Form**: IOE PROGRESS TRACKING FORM (`https://forms.office.com/r/aBkYkEMw1f`)
- **Flow name**: "IOE Progress"
- Trainers submit progression updates via the form; Power Automate sends email notifications and updates SharePoint

**Form fields:**
1. NAME OF TRAINEE (text)
2. STAFF NUMBER (text)
3. FLEET (choice: A350, A333, B737) — ignored, already in SharePoint
4. TOTAL SECTORS (number)
5. DATE (date, M/d/yyyy)
6. Progression Stage (choice — see mapping below)
7. REFERRED TO SIP (text)
8. Referral Reason(s) (text)

### Current Flow Structure
```
Form Submitted → Get response details → Get items (SharePoint lookup by Staff_ID)
    → Switch on Progression Stage
        ├── REFERRED TO SIP           → 3 emails (submitter, APCT, Capt Shazreen)
        ├── Command Check COMPLETED   → 2 emails + Update Command_Check_Date
        ├── Cleared Functional        → 2 emails + Update Functional_Date
        ├── Line Release Check COMPLETED → 2 emails + Update LRC_Date
        └── Default                   → 2 emails (notification only)
```

### Progression Stage → SharePoint Field Mapping

| Progression Stage | SharePoint Update |
|---|---|
| Cleared Functional | `Functional_Date` = DATE, `Sectors_Flown` = TOTAL SECTORS |
| Line Release Check COMPLETED | `LRC_Date` = DATE, `Sectors_Flown` = TOTAL SECTORS |
| Command Check COMPLETED | `Command_Check_Date` = DATE, `Sectors_Flown` = TOTAL SECTORS |
| REFERRED TO SIP | Email notifications only (manual highlight set via admin) |
| Default (others) | Email notifications only |

**All SharePoint updates also set:**
- `Last_Updated` = `utcNow()`

**Notes:**
- Fleet from form is ignored — the SharePoint list already has this data
- "REFERRED TO SIP" sends 3 emails (submitter ack, APCT alert, referral to Capt Arian/Shazreen)
- See `POWER_AUTOMATE_GUIDE.md` for detailed setup instructions

### Form Field IDs (for flow expressions)
| Field | ID |
|---|---|
| Progression Stage | `rc44f6063a49342649d954a8858d2819f` |
| NAME OF TRAINEE (used in subjects) | `r13aa5d088a6d46748fbbd853740d279c` |
| Name part 1 (used in APCT emails) | `rbb051b394b394902b4d2c72cdb2197f5` |
| Name part 2 (used in APCT emails) | `r5c5addf1886e4ba7a3858837f05544ec` |
| Referral Reason(s) | `r02e9c5a816524d259d5703b5e1e05f36` |

## Pending Fixes / Improvements

### Functional
1. **Admin password field is misleading** — In SharePoint mode, the password field is ignored. Auth checks the signed-in user's email against the `AdminUsers` list. Remove the password field or repurpose it.

### Security (minor)
2. **CSP allows `unsafe-inline` and `unsafe-eval`** — Weakens Content Security Policy, though `unsafe-eval` is required by Tailwind CDN.

### Accessibility
3. **No ARIA labels or keyboard navigation** — Table rows, modals, and buttons lack screen reader support.
