# Deployment Checklist - Training Progress Tracker

Use this checklist to track your deployment progress.

---

## Phase 1: IT Request (Send Email)

- [ ] Fill in bracketed sections in `IT_DEPARTMENT_REQUEST.md`
- [ ] Send email to IT department
- [ ] Wait for IT to complete Azure AD setup
- [ ] Receive Application (client) ID from IT
- [ ] Receive Directory (tenant) ID from IT

**Notes:**
```
Client ID received: ___________________________________
Tenant ID received: ___________________________________
Date received: _________________________________________
```

---

## Phase 2: SharePoint List Setup

### List 1: Training_Progress (Main Data)

- [ ] Go to SharePoint site → Site contents → New → List
- [ ] Name: `Training_Progress`
- [ ] Add column: **Batch** (Single line of text)
- [ ] Add column: **Staff_ID** (Single line of text, Required)
- [ ] Add column: **Rank** (Choice: FO, SFO, CAPT)
- [ ] Add column: **Name** (Single line of text, Required)
- [ ] Add column: **First_IOE_Date** (Date, no time)
- [ ] Add column: **Functional_Date** (Date, no time)
- [ ] Add column: **LRC_Date** (Date, no time)
- [ ] Add column: **Interview_Date** (Date, no time)
- [ ] Add column: **Sectors_Flown** (Number, 0 decimals)
- [ ] Add column: **Status** (Single line of text)
- [ ] Add column: **Remarks** (Multiple lines of text, plain text)
- [ ] Add column: **Last_Updated** (Date and time, with time)
- [ ] Add column: **Manual_Highlight** (Choice: blue, green, red)
- [ ] Enable version history (List settings → Versioning settings)

**SharePoint Site URL:**
```
___________________________________________________________
```

### List 2: AdminUsers (Optional - for Admin Panel)

- [ ] Create list named `AdminUsers`
- [ ] Add column: **Email** (Single line of text)
- [ ] Add column: **Password** (Single line of text) - Optional
- [ ] Add admin email addresses to the list

---

## Phase 3: Configure HTML File

- [ ] Open `index-sharepoint-v3-enhanced.html` in text editor
- [ ] Find line 867: `clientId: 'YOUR_CLIENT_ID_HERE',`
- [ ] Replace `YOUR_CLIENT_ID_HERE` with actual Client ID
- [ ] Find line 868: `authority: 'https://login.microsoftonline.com/YOUR_TENANT_ID_HERE',`
- [ ] Replace `YOUR_TENANT_ID_HERE` with actual Tenant ID
- [ ] Save the file

**Example:**
```javascript
// Before:
clientId: 'YOUR_CLIENT_ID_HERE',
authority: 'https://login.microsoftonline.com/YOUR_TENANT_ID_HERE',

// After:
clientId: 'a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6',
authority: 'https://login.microsoftonline.com/z9y8x7w6-v5u4-t3s2-r1q0-p9o8n7m6l5k4',
```

---

## Phase 4: Choose Deployment Method

### Option A: SharePoint Document Library (Recommended)

- [ ] Go to SharePoint site
- [ ] Navigate to Documents library (or create new library)
- [ ] Upload `index-sharepoint-v3-enhanced.html`
- [ ] Right-click file → Copy link
- [ ] Test by opening the link in browser
- [ ] Send redirect URI update email to IT (use template in IT_DEPARTMENT_REQUEST.md)

**Deployment URL:**
```
___________________________________________________________
```

**Pros:** Easy for users to access, integrates with Microsoft 365, good for Teams integration
**Cons:** Users need SharePoint site access

---

### Option B: Azure Static Web Apps (Production Grade)

- [ ] Go to [Azure Portal](https://portal.azure.com)
- [ ] Create new Static Web App
- [ ] Upload `index-sharepoint-v3-enhanced.html`
- [ ] Get deployment URL from Azure
- [ ] Send redirect URI update email to IT
- [ ] (Optional) Set up custom domain

**Deployment URL:**
```
___________________________________________________________
```

**Pros:** Professional, scalable, custom domain support
**Cons:** Requires Azure subscription, more complex setup

---

### Option C: Local Testing (Development Only)

- [ ] Open terminal/command prompt
- [ ] Navigate to project folder: `cd "C:\Users\shazreen\Desktop\Microsoft Training Tracker"`
- [ ] Run: `python -m http.server 8000`
- [ ] Open browser: `http://localhost:8000/index-sharepoint-v3-enhanced.html`
- [ ] Test authentication and SharePoint connection

**Note:** Redirect URI for local testing: `http://localhost:8000`

**Pros:** Quick testing, no deployment needed
**Cons:** Not accessible to other users, only for development

---

### Option D: Microsoft Teams Tab

- [ ] Complete Option A first (SharePoint upload)
- [ ] In Teams channel, click **+** to add tab
- [ ] Select **Website**
- [ ] Paste SharePoint file URL
- [ ] Name tab: "Training Tracker"
- [ ] Click Save

**Pros:** Integrates directly in Teams, easy user access
**Cons:** Requires SharePoint upload first

---

## Phase 5: First-Time Configuration

- [ ] Open deployed application
- [ ] Click **🔐 Sign in with Microsoft**
- [ ] Sign in with Microsoft 365 account
- [ ] Accept permissions (first time only)
- [ ] Verify user name appears in top right
- [ ] Enter SharePoint Site URL in configuration
- [ ] Enter List Name: `Training_Progress`
- [ ] Click **💾 Save Configuration**
- [ ] Click **🔌 Test Connection**
- [ ] Verify "✅ Connected" message appears
- [ ] Click **🔄 Refresh from SharePoint**
- [ ] Verify data loads (empty if new list)

---

## Phase 6: Test Core Features

### User Portal (Cadet View)

- [ ] Click **👤 Cadet View** button
- [ ] Enter a test Staff ID
- [ ] Select rank (FO, SFO, CAPT)
- [ ] Fill in dates and sectors
- [ ] Click **💾 Save to SharePoint**
- [ ] Verify data appears in SharePoint list
- [ ] Check analytics section appears
- [ ] Verify charts render correctly

### Admin Panel

- [ ] Click **🔐 Admin** button
- [ ] Sign in with admin credentials
- [ ] Click **➕ Add Trainee**
- [ ] Fill in trainee information
- [ ] Click **💾 Save to SharePoint**
- [ ] Verify trainee appears in table
- [ ] Test edit function (✏️ button)
- [ ] Test delete function (🗑️ button)
- [ ] Test filters (Year, Batch, Rank, Status)
- [ ] Test search functionality
- [ ] Click **🔄 Clear All** button
- [ ] Toggle **👁️ Hide Completed** button

### Export Features

- [ ] Click **📊 Export to Excel**
- [ ] Verify Excel file downloads
- [ ] Open in Excel/Google Sheets
- [ ] Check frozen header works
- [ ] Verify color coding (green/blue/red/white)
- [ ] Check batch grouping appears
- [ ] Test **📈 Export for Power BI**

### Analytics Dashboard (Admin)

- [ ] Scroll to analytics section
- [ ] Verify status distribution chart appears
- [ ] Check top 10 performers chart renders
- [ ] Test batch filter on analytics
- [ ] Verify change history tracking works

---

## Phase 7: User Access & Training

- [ ] Share deployment URL with team members
- [ ] Provide SharePoint site access to users
- [ ] Send user guide (`QUICK_REFERENCE.md`) to team
- [ ] Conduct brief training session (optional)
- [ ] Test with 2-3 users to verify multi-user access
- [ ] Set up admin access for designated admins

---

## Phase 8: Data Migration (If Applicable)

### From Google Sheets:

- [ ] Open existing Google Sheet
- [ ] File → Download → Microsoft Excel (.xlsx)
- [ ] In SharePoint list, click **Integrate** → **Excel**
- [ ] Click **Import from Excel**
- [ ] Select downloaded file
- [ ] Map columns correctly
- [ ] Click Import
- [ ] In app, click **🔄 Refresh from SharePoint**
- [ ] Verify all data loaded correctly
- [ ] Spot-check 5-10 records for accuracy

### From CSV/Other Sources:

- [ ] Format data with matching column names
- [ ] Save as Excel (.xlsx)
- [ ] Follow SharePoint Excel import steps above

---

## Phase 9: Post-Deployment

- [ ] Bookmark deployment URL
- [ ] Add to favorites/shortcuts
- [ ] Set up weekly data backup (Excel export)
- [ ] Monitor SharePoint list version history
- [ ] Collect user feedback
- [ ] Address any issues or questions
- [ ] Document any customizations made

---

## Troubleshooting Reference

| Issue | Solution |
|-------|----------|
| **"Authentication failed"** | Check Client ID and Tenant ID in HTML file (line 867-868) |
| **"Redirect URI mismatch"** | Confirm IT updated redirect URI to match deployment URL |
| **"Permission denied"** | Verify IT granted admin consent for API permissions |
| **"Cannot connect to SharePoint"** | Check SharePoint site URL is complete and correct |
| **"List not found"** | Verify list name is exactly `Training_Progress` (case-sensitive) |
| **"Token expired"** | Sign out and sign in again |
| **Columns missing in export** | Check all SharePoint columns exist with exact names |
| **Charts not rendering** | Ensure Chart.js CDN is loading (check browser console) |

---

## Quick Contact Info

**IT Support:** [Fill in your IT contact]
**Project Owner:** [Your name and contact]
**Documentation Location:** `C:\Users\shazreen\Desktop\Microsoft Training Tracker\`

---

## Completion Status

**Setup Started:** _______________
**IT Credentials Received:** _______________
**SharePoint Lists Created:** _______________
**App Configured:** _______________
**Deployed to:** _______________
**First Successful Sign-In:** _______________
**First Data Entry:** _______________
**User Training Completed:** _______________
**Production Launch:** _______________

---

## Notes & Issues Log

```
Date: __________ | Issue: ________________________________ | Resolution: ________________________________
Date: __________ | Issue: ________________________________ | Resolution: ________________________________
Date: __________ | Issue: ________________________________ | Resolution: ________________________________
Date: __________ | Issue: ________________________________ | Resolution: ________________________________
Date: __________ | Issue: ________________________________ | Resolution: ________________________________
```

---

**✅ Deployment Complete!**

Once all items are checked off, your Training Progress Tracker is fully operational and ready for your team to use.
