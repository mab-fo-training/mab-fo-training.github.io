# IT Department Correspondence Log - Training Progress Tracker

## Project: SharePoint Training Progress Tracker Setup
**Application:** index-sharepoint-v3-enhanced.html
**Purpose:** Azure AD App Registration & SharePoint Site Permission Configuration

---

## 2026-01-01 - Initial Setup & PowerShell Troubleshooting

### Received from IT

**Azure AD App Registration Credentials:**
- **Application (Client) ID:** `bd7182f4-5e68-4147-b953-2138298e19fc`
- **Directory (Tenant) ID:** `8fc3a567-1ee8-4994-809c-49f50cdb6d48`
- **App Name:** Training Progress Tracker

**PowerShell Script Provided to IT:**
```powershell
Connect-PnPOnline -Url https://mabitdept.sharepoint.com -Interactive

Grant-PnPAzureADAppSitePermission `
  -AppId "bd7182f4-5e68-4147-b953-2138298e19fc" `
  -DisplayName "Training Progress Tracker" `
  -Site https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING `
  -Permissions Write
```

### Error Encountered by IT

**Screenshots received:** `thumbnail_image007.png`, `thumbnail_image008.png`

**Error messages:**
1. `Connect-PnPOnline: Specified method is not supported.`
2. `Please specify a valid client id for an Entra ID App Registration.` (warning)
3. `Grant-PnPAzureADAppSitePermission: There is currently no connection yet. Use Connect-PnPOnline to connect or provide a valid connection using -Connection.`

**Root cause:** The `-Interactive` parameter is not supported in their PnP PowerShell environment/version.

### Actions Taken

#### 1. Updated Application Configuration
**File:** `index-sharepoint-v3-enhanced.html`

**Changes made:**
- Line 867: Updated `clientId` from `YOUR_CLIENT_ID_HERE` to `bd7182f4-5e68-4147-b953-2138298e19fc`
- Line 868: Updated `authority` from `YOUR_TENANT_ID_HERE` to `8fc3a567-1ee8-4994-809c-49f50cdb6d48`
- Line 878: Corrected permission scope from `Sites.ReadWrite.All` to `Sites.Selected`

**Final configuration:**
```javascript
let msalConfig = {
    auth: {
        clientId: 'bd7182f4-5e68-4147-b953-2138298e19fc',
        authority: 'https://login.microsoftonline.com/8fc3a567-1ee8-4994-809c-49f50cdb6d48',
        redirectUri: window.location.origin
    },
    cache: {
        cacheLocation: 'localStorage',
        storeAuthStateInCookie: false
    }
};

const loginRequest = {
    scopes: ['User.Read', 'Sites.Selected']
};
```

#### 2. Sent Updated PowerShell Scripts to IT

Provided three alternative connection methods:

**Option 1 - Web Login (Recommended):**
```powershell
Connect-PnPOnline -Url https://mabitdept.sharepoint.com -UseWebLogin

Grant-PnPAzureADAppSitePermission `
  -AppId "bd7182f4-5e68-4147-b953-2138298e19fc" `
  -DisplayName "Training Progress Tracker" `
  -Site https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING `
  -Permissions Write
```

**Option 2 - Device Login:**
```powershell
Connect-PnPOnline -Url https://mabitdept.sharepoint.com -DeviceLogin

Grant-PnPAzureADAppSitePermission `
  -AppId "bd7182f4-5e68-4147-b953-2138298e19fc" `
  -DisplayName "Training Progress Tracker" `
  -Site https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING `
  -Permissions Write
```

**Option 3 - Credential Prompt:**
```powershell
$cred = Get-Credential
Connect-PnPOnline -Url https://mabitdept.sharepoint.com -Credentials $cred

Grant-PnPAzureADAppSitePermission `
  -AppId "bd7182f4-5e68-4147-b953-2138298e19fc" `
  -DisplayName "Training Progress Tracker" `
  -Site https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING `
  -Permissions Write
```

**Alternative: SharePoint Admin Center Method**
- Navigate to SharePoint Admin Center → More features → Apps → App Permissions
- Add App ID and grant Write permission to FLTOPS-TRAINING site

### Key Technical Notes

**Permission Model:**
- IT recommended using **`Sites.Selected`** (more secure than `Sites.ReadWrite.All`)
- `Sites.Selected` requires explicit site authorization via PowerShell `Grant-PnPAzureADAppSitePermission` command
- This is why the PowerShell script is critical - without it, the app cannot access the SharePoint site

**Azure AD Configuration Required:**
- API Permission: `Sites.Selected` (SharePoint - Delegated)
- API Permission: `User.Read` (Microsoft Graph - Delegated)
- Admin consent must be granted
- Site-specific permission for `https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING`

### Current Status
- ⏳ **WAITING FOR IT RESPONSE** - Sent alternative PowerShell scripts
- ✅ Application configured with Client ID and Tenant ID
- ✅ Code updated to use `Sites.Selected` permission
- ⏳ Site-specific permission grant pending

### Next Steps (Pending IT Response)

**Once IT confirms successful PowerShell execution:**
1. Test authentication: Open `index-sharepoint-v3-enhanced.html` locally
2. Verify sign-in works with Microsoft 365 credentials
3. Configure SharePoint site URL and list name
4. Test data read/write operations
5. Update redirect URI in Azure AD with production deployment URL

**If PowerShell continues to fail:**
- Request IT use SharePoint Admin Center method instead
- Or request IT provide screenshot of exact error for further troubleshooting

---

## Configuration Summary

| Component | Value | Status |
|-----------|-------|--------|
| **App ID** | bd7182f4-5e68-4147-b953-2138298e19fc | ✅ Received |
| **Tenant ID** | 8fc3a567-1ee8-4994-809c-49f50cdb6d48 | ✅ Received |
| **HTML File Updated** | index-sharepoint-v3-enhanced.html | ✅ Complete |
| **Permission Type** | Sites.Selected | ✅ Configured in code |
| **Site Authorization** | FLTOPS-TRAINING | ⏳ Pending IT |
| **Admin Consent** | Azure AD | ⏳ Assume granted |
| **Testing** | Local/Production | ⏳ Pending site access |

---

## Important URLs

- **SharePoint Site:** https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING
- **SharePoint List:** Training_Progress (to be created/verified)
- **Azure Portal:** https://portal.azure.com
- **App Registration:** Azure AD → App registrations → Training Progress Tracker

---

## Contact Information

**IT Department:** [IT Contact Name]
**Project Owner:** [Your Name]
**Last Updated:** 2026-01-01

---

## 2026-01-01 - Testing Results (Later Same Day)

### Application Testing Performed

**Test Environment:**
- URL: `http://localhost:8000/index-sharepoint-v3-enhanced.html`
- User: Signed in with Microsoft 365 credentials

**Configuration Entered:**
- **Site URL:** `https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING`
- **List Name:** `Training_Progress`

### Test Results

✅ **Microsoft 365 Sign-In:** SUCCESS
- User successfully authenticated with Microsoft credentials
- Azure AD configuration confirmed working
- MSAL.js authentication flow completed

❌ **SharePoint Connection Test:** FAILED
- **Error:** `HTTP 401: Unauthorized`
- **Root Cause:** App does not have permission to access the specific SharePoint site

### Analysis

**What the 401 Error Confirms:**
1. Azure AD App Registration is correctly configured
2. User authentication is working properly
3. **Site-specific permission has NOT been granted yet** (this is the blocker)

**Why This Happened:**
- `Sites.Selected` permission requires explicit site authorization
- The PowerShell `Grant-PnPAzureADAppSitePermission` command must complete successfully
- Without this command, the app cannot access ANY SharePoint site, even if the user has access

### Code Fix Applied

**Issue Found:** SharePoint configuration fields were auto-capitalizing due to CSS
**Fix Applied:** Added CSS exemption for `#siteUrl` and `#listName` fields (line 31-33)

```css
/* Exempt SharePoint configuration fields from uppercase */
#siteUrl, #listName {
    text-transform: none !important;
}
```

### Current Status - Updated

- ✅ Application configured with App ID and Tenant ID
- ✅ Microsoft 365 authentication working
- ✅ SharePoint list `Training_Progress` created in site
- ❌ **BLOCKER:** Site-specific permission not granted (HTTP 401 error)
- ⏳ **WAITING:** IT to successfully complete PowerShell site authorization

### First Reply to IT

Informed IT of testing results:
- Sign-in works successfully
- Connection test fails with HTTP 401
- Confirms PowerShell command is required and has not completed successfully yet
- Awaiting IT to resolve PowerShell authentication issue or use alternative method

### Second Reply to IT (Comprehensive Update)

**Email Sent:** 2026-01-01

**Subject:** RE: Azure AD App Registration - Testing Complete, Site Permission Needed

**Content Summary:**
- Provided clear testing results (authentication working, SharePoint connection failing)
- Explained HTTP 401 error and root cause
- Included 3 alternative PowerShell connection methods:
  - Option A: `-UseWebLogin`
  - Option B: `-DeviceLogin`
  - Option C: Credential prompt with `Get-Credential`
- Provided alternative non-PowerShell solution (SharePoint Admin Center)
- Clear "What IT Needs to Do Next" section
- Summary of completed vs remaining tasks

**Key Points Communicated:**
1. Azure AD authentication confirmed working
2. HTTP 401 proves site permission not granted
3. Multiple methods provided to complete setup
4. Clear expected outcome once permission granted

**Status:** ⏳ Awaiting IT response

**Last Updated:** 2026-01-01

---

## Current Status Summary (As of 2026-01-01)

### ✅ Completed
1. Azure AD App Registration created by IT
2. Client ID and Tenant ID received and configured
3. Application code updated with credentials
4. Permission scope corrected to `Sites.Selected`
5. CSS fix applied (configuration fields no longer auto-capitalize)
6. Microsoft 365 authentication tested - **WORKING**
7. SharePoint list `Training_Progress` created in site

### ❌ Blocking Issue
- **HTTP 401: Unauthorized** when connecting to SharePoint
- Site-specific permission not granted

### ⏳ Waiting On
- IT to successfully run `Grant-PnPAzureADAppSitePermission` command
  - OR use SharePoint Admin Center alternative method
- Expected resolution: Once permission granted, app will work immediately

### 📧 Communication Status
- **Last message sent to IT:** Comprehensive update with 3 PowerShell options + GUI alternative
- **Waiting for:** IT confirmation that site permission has been granted

---

## Reference Documentation

- `IT_DEPARTMENT_REQUEST.md` - Original request template sent to IT
- `SETUP_GUIDE.md` - Technical setup instructions
- `CLAUDE.md` - Complete project documentation
- `index-sharepoint-v3-enhanced.html` - Application file (configured)

---

## 2026-01-13 - SharePoint App Permissions Page Method (appinv.aspx)

### Context: New App Registration Created

**Updated Application Credentials:**
- **Application (Client) ID:** `82a4ec5a-d90d-4957-8021-3093e60a4d70`
- **Directory (Tenant) ID:** `8fc3a567-1ee8-4994-809c-49f50cdb6d48`
- **App Name:** Training Tracker SharePoint App

**Reason for Change:** Previous PowerShell methods failed, new app created with different configuration approach.

### Email Sent to IT - Simplified Method

**Subject:** RE: Training Tracker App Permission - Step 4 XML

**Method:** Using SharePoint's built-in App Permission page (`appinv.aspx`) instead of PowerShell

**Instructions Provided:**

1. Go to this URL (while signed in as site admin):
   ```
   https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING/_layouts/15/appinv.aspx
   ```

2. In the "App ID" field, enter:
   ```
   82a4ec5a-d90d-4957-8021-3093e60a4d70
   ```

3. Click the "Lookup" button
   - Expected result: "Training Tracker SharePoint App" should appear

4. In the "Permission Request XML" field, paste:
   ```xml
   <AppPermissionRequests AllowAppOnlyPolicy="true">
     <AppPermissionRequest Scope="http://sharepoint/content/sitecollection/web" Right="Write" />
   </AppPermissionRequests>
   ```

5. Click "Create" to grant access

6. Click "Trust It" on the confirmation dialog

### IT Response

**Question from IT:** "What to paste in step 4?"

**Reply Sent:** Provided the complete Permission Request XML (shown above)

### XML Permission Breakdown

**What the XML does:**
- `AllowAppOnlyPolicy="true"` - Enables app-only authentication (app works independently of user permissions)
- `Scope="http://sharepoint/content/sitecollection/web"` - Grants access to this specific site only
- `Right="Write"` - Grants read and write permissions (required for CRUD operations on Training_Progress list)

**Security Note:** This permission is site-scoped only. The app will NOT have access to other SharePoint sites.

### Current Status

- ✅ Updated app credentials configured in application code
- ✅ Simplified permission grant method provided (no PowerShell required)
- ✅ Complete XML provided to IT
- ⏳ **WAITING:** IT to complete the 6-step process via appinv.aspx
- 📋 **NEXT:** Test connection once IT confirms completion

### Advantages of This Method

1. **No PowerShell required** - Works through browser UI
2. **No module dependencies** - No PnP PowerShell installation needed
3. **Site admin sufficient** - Site collection admin can grant (doesn't require Global Admin)
4. **Immediate feedback** - Success/failure visible in the browser
5. **Standard Microsoft interface** - Built-in SharePoint functionality

### What Happens After IT Completes This

**Expected Outcome:**
- App will be listed in Site Settings → Site App Permissions
- App will have Write permission to the FLTOPS-TRAINING site
- Application will be able to authenticate and access the Training_Progress list

**Testing Steps (Once IT Confirms):**
1. Open `index-sharepoint-v3-enhanced.html` in browser
2. Sign in with Microsoft 365 credentials
3. Enter site URL and list name in configuration
4. Click "Test Connection"
5. Expected result: ✅ Connection successful

**If connection test passes:**
- Proceed with data migration from Google Sheets
- Begin user acceptance testing
- Plan production deployment

**Last Updated:** 2026-01-13
**Status:** ⏳ Awaiting IT confirmation of app permission grant

---

## 2026-01-14 - App Permission Granted, User Permission Needed

### IT Confirmation Received

**Status:** ✅ IT successfully granted app permission via appinv.aspx

### Connection Testing Results

**Test Performed:** Device code authentication to SharePoint site

**Results:**
- ✅ **SharePoint Connection:** Success
- ❌ **List Access:** 403 Forbidden
- ❌ **Read Operations:** Blocked
- ❌ **Write Operations:** Blocked

**Error Message:** `The remote server returned an error: (403) Forbidden.`

### Root Cause Analysis

**Issue Identified:** User account permission level too restrictive

**Current Situation:**
- **App Permission:** ✅ Write permission granted (appinv.aspx method worked)
- **User Permission:** ❌ "Limited Control" (read-only)

**Why This Matters:**
- The HTML application uses **delegated authentication** (user signs in with their account)
- When the app runs, it operates with the signed-in user's permissions
- Even though the app has Write permission, it's constrained by the user's permissions
- "Limited Control" blocks all read/write operations on the Training_Progress list

### Email Sent to IT - User Permission Upgrade Request

**Subject:** Training Tracker - Need Edit Permission on FLTOPS-TRAINING Site

**Request:** Upgrade user account permissions from "Limited Control" to "Edit" or "Contribute"

**User Account:** mohamadshazreen.sazali@malaysiaairlines.com
**Site:** https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING

**Key Question to IT:** Are you able to upgrade user permissions on this site, or do we need to contact the site owner/administrator?

**Instructions Provided (if IT can do it):**
1. Go to: https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING
2. Click Settings (gear icon) → Site permissions
3. Find: mohamadshazreen.sazali@malaysiaairlines.com
4. Change permission from "Limited Control" to "Edit"

**If IT cannot do this:** Asked them to provide contact info for site owner or site collection admin

### Permission Levels Explained

| Level | Read | Write | Use Case |
|-------|------|-------|----------|
| **Limited Control** | ❌ Blocked | ❌ Blocked | Minimal access |
| **Contribute** | ✅ Yes | ✅ Yes | Standard user |
| **Edit** | ✅ Yes | ✅ Yes + manage lists | Recommended |

**Requested:** Edit (preferred) or Contribute (minimum)

### Current Status

- ✅ App permission granted successfully
- ✅ Connection test completed (confirms app permission works)
- ✅ Issue identified (user permission level)
- 📧 Email sent to IT requesting user permission upgrade
- ⏳ **WAITING:** IT to upgrade user account to Edit/Contribute

### Next Steps (After IT Upgrades User Permission)

1. **Retest Connection:**
   ```powershell
   .\test-sharepoint-devicecode.ps1
   ```
   Expected result: All checks pass ✅

2. **Run Migration:**
   ```powershell
   .\migrate-to-sharepoint.ps1
   ```
   Import data from Google Sheets to SharePoint

3. **Test Application:**
   ```bash
   python -m http.server 8000
   # Open: http://localhost:8000/index-sharepoint-v3-enhanced.html
   ```

4. **User Acceptance Testing:**
   - Test CRUD operations
   - Verify data integrity
   - Test all filters and sorting
   - Test Excel export

5. **Production Deployment:**
   - Upload to SharePoint document library or web hosting
   - Update redirect URI in Azure AD
   - Distribute URL to users

### Technical Summary

**What's Working:**
- ✅ Azure AD app registration configured
- ✅ App authentication flow
- ✅ App-level Write permission to site
- ✅ SharePoint connection via PnP PowerShell

**What's Blocking:**
- ❌ User account "Limited Control" permission

**Solution:**
- User account needs "Edit" or "Contribute" permission level on FLTOPS-TRAINING site

**Last Updated:** 2026-01-14
**Status:** ⏳ Awaiting IT to upgrade user permissions to Edit/Contribute
