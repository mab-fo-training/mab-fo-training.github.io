# SharePoint Setup Status

**Last Updated:** 2026-01-21

## Current Status: 🔄 Azure Function Backend In Progress

### ✅ Completed Steps

1. **Azure AD App Configuration**
   - App Name: Training Tracker SharePoint App
   - Client ID: `82a4ec5a-d90d-4957-8021-3093e60a4d70`
   - Tenant ID: `8fc3a567-1ee8-4994-809c-49f50cdb6d48`

2. **User Permissions** ✅
   - User: mohamadshazreen.sazali@malaysiaairlines.com
   - Permission: **Site Owner** on FLTOPS-TRAINING
   - Granted by IT: 2026-01-18

3. **Authentication Working** ✅
   - Scope: `https://mabitdept.sharepoint.com/.default`
   - Sign-in via MSAL popup works correctly

4. **SharePoint Site**
   - Site URL: `https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING`
   - List Name: `Training_Progress`

5. **API Permissions Granted** ✅ (2026-01-21)
   - `Sites.ReadWrite.All` (Delegated) - ✅ Granted
   - `Sites.Selected` (Application) - ✅ Granted
   - `User.Read` (Delegated) - Needs consent
   - `Sites.Selected` (SharePoint, Delegated) - ✅ Granted

---

## 🔄 Current Phase: Azure Function Backend

### Why Azure Function?
- Browser-based delegated auth works but requires user to be signed in
- Azure Function enables **app-only authentication** for backend operations
- Better for automated sync and service-level access

### Steps to Complete

#### Step 1: Client Secret ✅ (Can do yourself)
- Azure Portal → App Registrations → Your App → Certificates & secrets
- Create new client secret and save the value

#### Step 2: Grant App Site Permission 🔄 (IT Required)
**Email drafted and ready to send**

IT needs to run this PowerShell command:
```powershell
# Connect to SharePoint Admin Center
Connect-PnPOnline -Url "https://mabitdept-admin.sharepoint.com" -Interactive

# Grant app permission to the specific site
Grant-PnPAzureADAppSitePermission `
    -AppId "82a4ec5a-d90d-4957-8021-3093e60a4d70" `
    -DisplayName "Training Progress Tracker" `
    -Site "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING" `
    -Permissions Write
```

#### Step 3: Create Azure Function (Can do yourself)
- Azure Portal → Create Resource → Function App
- Runtime: Node.js 18 or Python 3.10
- Plan: Consumption (serverless)

#### Step 4: Deploy Function Code (Pending)
- Endpoints: GET/POST/PATCH/DELETE for trainees
- Will be created after IT completes Step 2

---

## Status Summary

| Component | Status |
|-----------|--------|
| Azure AD App | ✅ Configured |
| Sites.ReadWrite.All (Delegated) | ✅ Granted by IT (2026-01-21) |
| Sites.Selected (Application) | ✅ Granted - needs site permission |
| User Permission (Site Owner) | ✅ Granted |
| Authentication (Browser) | ✅ Working |
| Security Hardening | ✅ Implemented |
| Application Code | ✅ Ready |
| **Azure Function Backend** | 🔄 **In Progress** |
| IT Site Permission (PowerShell) | ⏳ **Pending IT Action** |

---

## Next Actions

1. **Send email to IT** requesting PowerShell command execution (email drafted below)
2. **Create client secret** in Azure AD app registration
3. **Wait for IT** to run the PowerShell command
4. **Create Azure Function** code once Step 2 is complete

---

## Email to IT (Ready to Send)

**Subject:** RE: Request: Grant Azure AD App Permission to SharePoint Site for Training Tracker Application

```
Dear IT Team,

Thank you for adding the Sites.ReadWrite.All delegated permission.
I have tested it and the browser-based authentication now works for user-level access.

However, I am now implementing a backend service (Azure Function) that needs
to access SharePoint independently without requiring a user to be signed in.

The app registration already has Sites.Selected (Application) permission granted.
To complete the setup, please run this PowerShell command:

Connect-PnPOnline -Url "https://mabitdept-admin.sharepoint.com" -Interactive

Grant-PnPAzureADAppSitePermission `
    -AppId "82a4ec5a-d90d-4957-8021-3093e60a4d70" `
    -DisplayName "Training Progress Tracker" `
    -Site "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING" `
    -Permissions Write

This follows Microsoft's least-privilege model - the app can only access
the FLTOPS-TRAINING site, not all SharePoint sites.

Best regards,
Capt. Mohamad Shazreen Sazali
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `index-sharepoint-v3-enhanced.html` | SharePoint version (ready to use) |
| `migrate-to-sharepoint.ps1` | Data migration script |
| `test-sharepoint.py` | Python connection test |
| `SETUP_STATUS.md` | This file - current progress |
| `CLAUDE.md` | Project documentation |
