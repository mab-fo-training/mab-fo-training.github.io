# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **two versions** of a Training Progress Tracker for managing flight training progress (First IOE, Functional Date, LRC, Interview, sectors flown). Both are single-page HTML applications with no build process.

### Version 2.2 - Google Sheets Edition (`index.html`)
- **3,274 lines** - Production version with full feature set
- Google Sheets API for data storage
- Google Identity Services for authentication
- Dual interface: User Portal + Admin Panel
- Change history tracking and analytics dashboard

### Version 3.0 - SharePoint Edition (`index-sharepoint.html`)
- **1,299 lines** - Enterprise migration version
- SharePoint REST API for data storage
- MSAL.js for Microsoft 365 authentication
- Admin-focused interface (no user portal)
- Designed for Microsoft ecosystem integration

**Common Technologies:**
- Pure vanilla JavaScript (no build tooling)
- TailwindCSS via CDN
- XLSX.js for Excel exports
- Chart.js for visualizations

## Architecture Comparison

### Single-File Design (Both Versions)
Both applications are intentionally single-file HTML with embedded JavaScript. No build process required - deploy directly to web servers or document libraries.

### Google Sheets Version (v2.2) - `index.html`

**Data Flow:**
1. **Authentication**: Google Identity Services → JWT token parsing → user profile extraction
2. **Authorization**: Access token requested with `spreadsheets` scope
3. **Data Storage**: Google Sheets as database (range: `[SHEET_NAME]!A2:M`)
4. **State Management**: In-memory `cadets[]` array synchronized with Sheets on load/save
5. **Admin Access**: Separate `AdminUsers` sheet validates admin emails (column A) and optional password (cell B1)

**Google Sheets Schema:**
Columns A-M in the main sheet:
- A: Batch
- B: Staff_ID
- C: Rank (CAPT, FO, SO, CDT)
- D: Name
- E: First_IOE_Date (DD/MM/YY format, converted to YYYY-MM-DD)
- F: Functional_Date
- G: LRC_Date
- H: Interview_Date
- I: Sectors_Flown (number)
- J: Last_Updated (timestamp)
- K: Remarks
- L: Manual_Highlight (blue/green/red)
- M: Sector_History (JSON array tracking sector changes)

**Configuration** (hardcoded at lines 1137-1142):
```javascript
API_KEY: 'AIzaSyDkxsnzpdOCXqUJ9xbpWKeoVU9P4hYCrik'
CLIENT_ID: '657166589265-ocmfi5cgl3rktnakqcd0bjjd0284mv4f.apps.googleusercontent.com'
SPREADSHEET_ID: '1D31q-19IK0DSLVQaI8jwrxLVspyMIWIZ6thiO7vGoNg'
SHEET_NAME: '738 cpc'
```

**Dual View Architecture:**
1. **User Portal** (Cadet View): Self-service interface where trainees enter Staff ID, select rank (locks after first selection), and update their own dates/sectors
2. **Admin Panel**: Full CRUD access, analytics dashboard, batch filtering, change history

### SharePoint Version (v3.0) - `index-sharepoint.html`

**Data Flow:**
1. **Authentication**: MSAL.js handles Microsoft 365 sign-in → popup authentication
2. **Configuration**: SharePoint site URL and list name stored in `localStorage`
3. **Data Storage**: SharePoint List via REST API (`_api/web/lists/...`)
4. **API Communication**: OData v3 format (`odata=verbose`)
5. **State Management**: In-memory `cadets[]` synchronized with SharePoint

**SharePoint List Schema:**
List name: `Training_Progress` with exact columns:
- `Batch` (Single line of text)
- `Staff_ID` (Single line of text)
- `Rank` (Choice: FO, SFO, CAPT)
- `Name` (Single line of text)
- `First_IOE_Date` (Date)
- `Functional_Date` (Date)
- `LRC_Date` (Date)
- `Interview_Date` (Date)
- `Sectors_Flown` (Number)
- `Status` (Single line of text)
- `Remarks` (Multiple lines of text)
- `Last_Updated` (Date with time)
- `Manual_Highlight` (Choice: blue, green, red)

**Important**: SharePoint's default `Title` field is also used for trainee name.

### Status Logic (Common to Both Versions)
Trainee status is determined by date completion:
- **In Progress** (white background): Initial state, no functional date
- **Functional** (blue background): Has `First_IOE_Date` + `Functional_Date`, missing LRC/Interview
- **Completed** (green background): All 4 dates filled (IOE, Functional, LRC, Interview)
- **Special Case** (red background): Manual override via `Manual_Highlight` field

Manual highlight takes precedence over automatic status detection.

## Configuration Requirements

### Google Sheets Version (v2.2)
**Google Cloud Console Setup:**
1. Create project in Google Cloud Console
2. Enable Google Sheets API
3. Create OAuth 2.0 Client ID (Web application)
4. Create API Key
5. Update `CONFIG` object (lines 1137-1142) with credentials
6. No additional user configuration needed - fully hardcoded

**Google Sheets Setup:**
1. Create main sheet with name matching `CONFIG.SHEET_NAME`
2. Add columns A-M (see schema above)
3. Create `AdminUsers` sheet:
   - Column A: Admin email addresses (one per row)
   - Cell B1: Optional password for admin access

**Optional Domain Restriction:**
Uncomment lines 1504-1512 to restrict access to specific email domains (e.g., `@malaysiaairlines.com`).

### SharePoint Version (v3.0)
**Azure AD App Registration:**
1. Create Azure AD App Registration
2. Replace `YOUR_CLIENT_ID_HERE` at line 516
3. Replace `YOUR_TENANT_ID_HERE` at line 517
4. Configure API permissions: `User.Read`, `Sites.ReadWrite.All`
5. Grant admin consent in Azure Portal
6. Set redirect URI to deployment URL

**SharePoint Setup:**
1. Create SharePoint list named `Training_Progress`
2. Add exact columns (see schema above - names are case-sensitive)

See SETUP_GUIDE.md for detailed SharePoint setup instructions.

## Key Functions by Version

### Google Sheets Version (`index.html`)

**Authentication & Authorization:**
- `gapiLoaded()` (line 1439): Initializes Google Sheets API client
- `gisLoaded()` (line 1450): Initializes OAuth token client
- `handleCredentialResponse()` (line 1491): Parses JWT, extracts user info, handles domain restriction
- `checkAdminAuth()`: Validates admin access against AdminUsers sheet

**Data Operations:**
- `loadFromSheets()` (line 1542): Fetches data from Google Sheets range A2:M
- `saveToSheets()`: Writes entire `cadets[]` array back to Sheets (batch update)
- `ddmmyyToDatePicker()` (line 1170): Converts DD/MM/YY format to YYYY-MM-DD for date inputs

**User Portal (Cadet View):**
- User enters Staff ID → finds their record → can update only their own dates/sectors
- Rank selection locks after first save (prevents changing after commitment)
- Sector history tracked in JSON array (column M)

**Admin Panel:**
- Full CRUD operations on all trainees
- `updateAdminAnalytics()` (line 1325): Generates distribution and top 10 charts
- Change history tracking
- Batch-based filtering and analytics

**State Management:**
- `cadets[]`: Main data array
- `changeHistory[]`: Tracks all modifications
- `batches[]`: Unique batch list for filters

### SharePoint Version (`index-sharepoint.html`)

**Authentication:**
- `initializeMSAL()` (line 547): Initializes MSAL client
- `signIn()` (line 566): Popup authentication flow
- `acquireTokenAndLoadData()` (line 592): Silent token refresh

**SharePoint Operations:**
- `loadDataFromSharePoint()` (line 668): Fetches items via REST API
- `saveTraineeToSharePoint()` (line 724): Creates/updates using MERGE method
- `deleteTraineeFromSharePoint()` (line 789): Deletes by item ID
- `getListItemEntityType()` (line 820): Gets metadata for proper API calls
- `testSharePointConnection()` (line 627): Validates connection before operations

**Data Management:**
- `filterCadets()` (line 872): Applies search, year, batch, rank filters
- `renderTable()` (line 885): Renders filtered/sorted data to DOM
- `getTraineeStatus()` (line 969): Determines status based on date completion

**Export:**
- `exportToExcel()` (line 1071): XLSX export with formatting
- Power BI export uses same function

## Common Development Tasks

### Testing Locally (Both Versions)
Must be served via HTTP server (not `file://` due to CORS):
```bash
# Python
python -m http.server 8000

# Node.js
npx http-server -p 8000
```

Then open:
- Google Sheets version: `http://localhost:8000/index.html`
- SharePoint version: `http://localhost:8000/index-sharepoint.html`

### Modifying Data Schema

**Google Sheets Version:**
1. Update `loadFromSheets()` (line 1542) - array index mapping
2. Update `saveToSheets()` - write mapping to match new columns
3. Add new column letter to range (currently A2:M)
4. Update form fields in both User Portal and Admin Panel
5. Test with actual Google Sheet to ensure column alignment

**SharePoint Version:**
1. Add column in SharePoint list (exact case-sensitive name)
2. Update mapping in `loadDataFromSharePoint()` (line 697)
3. Update mapping in `saveTraineeToSharePoint()` (line 732)
4. Update modal form fields (lines 442-496)
5. Update table headers (lines 407-420)
6. Update render logic (lines 926-946)

### Adding Features to SharePoint Version (from Google Sheets)

**To add User Portal (self-service):**
1. Copy cadet view section from `index.html` (lines 429-550)
2. Implement Staff ID lookup against SharePoint
3. Add rank locking logic
4. Restrict updates to only user's own record
5. Add sector history column (JSON) to SharePoint list

**To add Admin Analytics:**
1. Copy admin analytics dashboard from `index.html` (lines 922-1015)
2. Copy `updateAdminAnalytics()` function (line 1325)
3. Ensure Chart.js charts render properly
4. Add batch filter integration

## Deployment Options

### Google Sheets Version (`index.html`)
1. **Web Server**: Any static hosting (GitHub Pages, Netlify, Vercel)
2. **Google Sites**: Embed as custom HTML
3. **Internal Network**: Company intranet server
4. **Google Drive**: Host as web page (with proper CORS)

**Important**: Update Google Cloud Console redirect URIs to match deployment URL.

### SharePoint Version (`index-sharepoint.html`)
1. **SharePoint Document Library**: Upload HTML file directly
2. **Azure Static Web Apps**: Deploy via Azure Portal
3. **Microsoft Teams**: Embed as website tab
4. **Local Server**: For development/testing only

**Important**: Update Azure AD redirect URI to match deployment URL.

## Important Notes

### Common to Both
- **No Build Process**: Intentional design - direct deployment
- **Text Transform**: All inputs auto-uppercase via CSS (lines 16-24)
- **Sticky Columns**: Actions column sticky on scroll
- **Date Format**: Internal format is YYYY-MM-DD (HTML5 date input standard)
- **State Management**: In-memory only, no IndexedDB/localStorage for data

### Google Sheets Specific
- **Batch Updates**: Entire sheet rewritten on save (not row-by-row)
- **Date Format Conversion**: DD/MM/YY from sheets converted to YYYY-MM-DD for pickers
- **Sector History**: JSON array stored as string in column M
- **Admin Security**: Email-based + optional password (plaintext in cell B1)
- **API Quotas**: Google Sheets API has rate limits (100 requests per 100 seconds per user)

### SharePoint Specific
- **Column Name Precision**: Case-sensitive, must match exactly
- **OData Version**: Uses OData v3 (`odata=verbose`) format
- **MERGE vs POST**: Updates use `X-HTTP-Method: MERGE` header (line 766)
- **5000 Item Limit**: Default query limit (add pagination if needed)
- **Token Expiration**: MSAL handles silent refresh automatically

## Files

- `index.html`: Google Sheets version (3,274 lines) - **PRODUCTION**
- `index-sharepoint.html`: SharePoint version (1,299 lines) - **ENTERPRISE MIGRATION**
- `SETUP_GUIDE.md`: SharePoint/Azure AD setup instructions
- `QUICK_REFERENCE.md`: End-user quick reference (SharePoint version)
- `CLAUDE.md`: This file
- `files.zip`: Archive (contents not examined)

## Feature Comparison

| Feature | Google Sheets (v2.2) | SharePoint (v3.0) |
|---------|---------------------|-------------------|
| **User Self-Service Portal** | ✅ Yes | ❌ No |
| **Admin Panel** | ✅ Yes | ✅ Yes (basic) |
| **Analytics Dashboard** | ✅ Yes (charts) | ❌ No |
| **Change History Tracking** | ✅ Yes | ❌ No |
| **Sector History Tracking** | ✅ Yes (JSON) | ❌ No |
| **Admin Authentication** | Email list + password | Azure AD only |
| **Data Storage** | Google Sheets | SharePoint Lists |
| **Offline Support** | ❌ No | ❌ No |
| **Real-time Sync** | ❌ Manual refresh | ❌ Manual refresh |
| **Power BI Export** | ❌ No | ✅ Yes |
| **Setup Complexity** | Low | High (Azure AD) |
| **Enterprise Integration** | Google Workspace | Microsoft 365 |

## Migration Notes

If migrating from Google Sheets to SharePoint:
1. Export data from Google Sheets to Excel
2. Import Excel to SharePoint list (use Import Spreadsheet feature)
3. Verify all column names match exactly
4. User portal and analytics features will need to be manually ported
5. Consider keeping Google Sheets version if self-service is critical
