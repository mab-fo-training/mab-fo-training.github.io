# Continue From Here

**Last Updated:** 2026-01-22

---

## Current Status: Waiting for IT to Create Azure Function App

### Latest Update (2026-01-22)

**IT Completed PowerShell Command for Sites.Selected Permission**

IT successfully ran the `Grant-PnPAzureADAppSitePermission` PowerShell command, granting the app write access to the FLTOPS-TRAINING site using `Sites.Selected` permission.

**Completed Today:**
1. ✅ IT ran PowerShell command for site-level permission
2. ✅ Client secret created in Azure AD
3. ✅ Researched Azure Function costs (storage account: $0.01-$0.50/month)
4. ✅ Drafted email to IT requesting Azure Function App creation

**Architecture Decision: Option B (Azure Function Backend)**

```
Browser App → Azure Function (app-only auth) → SharePoint
```

**Cost Breakdown:**
| Component | Monthly Cost |
|-----------|--------------|
| Azure Functions (Consumption) | $0 (free tier: 1M executions) |
| Storage Account | $0.01 - $0.50 |
| **Total** | **Under $1/month** |

**Security Benefits:**
- Trainees do NOT need SharePoint site access
- App authenticates directly using app-only credentials
- SharePoint remains completely isolated from end users
- Principle of least privilege via `Sites.Selected`

---

### What's Done

**Infrastructure**
- Azure AD App configured (Client ID: `82a4ec5a-d90d-4957-8021-3093e60a4d70`)
- User granted **Site Owner** on FLTOPS-TRAINING
- Authentication working (MSAL sign-in successful)
- IT granted `Sites.ReadWrite.All` delegated permission
- Connection test successful

**App File**
- Main file: `progress-tracker.html` (renamed from index-sharepoint-v3-enhanced.html)
- Test at: http://localhost:8000/progress-tracker.html

**Security Hardening**
- Content Security Policy (CSP) with PDF.js worker support
- Hardcoded site URL (locked to FLTOPS-TRAINING)
- URL validation on all API calls
- sessionStorage for tokens (clears on browser close)
- 30-minute session timeout
- HTML escaping for XSS prevention

**Features Implemented**
| Feature | Status |
|---------|--------|
| PDF Import (TJI parser) | Done |
| Bulk Excel Import with preview | Done |
| Command Check Date (CUC batches) | Done |
| Year Filter | Done |
| Training Type Filter (CPC/CUC) | Done |
| Fleet Tracking (B738, B738M, A330, A350) | Done |
| Fleet Filter | Done |
| New Batch Creation inline | Done |
| Rank options (CAPT, FO, SO, CDT) | Done |
| Color Legend | Done |
| Test Highlights Button | Done |
| Column Sorting | Done |
| Date format DD/MM/YY | Done |

**Analytics Dashboard**
| Chart | Description |
|-------|-------------|
| Status Distribution | Doughnut chart (In Progress vs Completed) |
| Progress by Batch | Stacked bar chart per batch |
| Fleet Completion Rate | Bar chart showing % completed per fleet |
| Average Time to Completion | 4 metric cards (IOE→Func, Func→LRC, LRC→Interview, Total) |
| Monthly Completion Trend | Line chart (last 12 months) |

**Statistics Cards**
- Total, In Progress, Completed (3 cards)

**UI Updates (2026-01-20)**
- All emojis replaced with professional text/SVG icons
- Aviation-themed header with airplane icon
- Admin panel simplified (password only, no setup instructions)
- Subtitle: "Flight Operations Training Management System"

**CUC Batch Logic**
- CUC completion: First IOE + Functional + Command Check + LRC (no Interview)
- CPC completion: First IOE + Functional + LRC + Interview
- Command Check Date column positioned before LRC

**Data Migration**
- Fleet defaults to B738 when not specified (bulk import, PDF import, SharePoint load)
- Ready to import Google Sheets data

---

### SharePoint List Schema Required

The `Training_Progress` list needs these columns:
| Column Name | Type | Notes |
|-------------|------|-------|
| Batch | Single line of text | |
| Staff_ID | Single line of text | |
| Rank | Choice | FO, SFO, CAPT, SO, CDT |
| Name | Single line of text | |
| Fleet | Choice | B738, B738M, A330, A350 |
| First_IOE_Date | Date | |
| Functional_Date | Date | |
| Command_Check_Date | Date | For CUC batches only |
| LRC_Date | Date | |
| Interview_Date | Date | |
| Sectors_Flown | Number | |
| Remarks | Multiple lines of text | |
| Last_Updated | Date and Time | |
| Manual_Highlight | Choice | blue, green, red |
| Sector_History | Multiple lines of text | JSON array |

---

### Next Steps (Resume Here)

1. ~~**Add SharePoint columns**~~ ✅ Done (2026-01-20)
   - Fleet (Choice: B738, B738M, A330, A350)
   - Command_Check_Date (Date)

2. ~~**Choose Deployment Architecture**~~ ✅ Decision Made: Azure Function Backend

3. ~~**IT: Grant Sites.Selected permission**~~ ✅ Done (2026-01-22)
   - IT ran PowerShell `Grant-PnPAzureADAppSitePermission` command

4. ~~**Create client secret**~~ ✅ Done (2026-01-22)

5. **Send email to IT requesting Azure Function App** ⏳ CURRENT
   - Email drafted: `EMAIL_TO_IT_AZURE_FUNCTION.md`
   - Requested config: Node.js 18, Southeast Asia, Consumption plan
   - Request Contributor access for deployment

6. **Wait for IT to create Function App** ⏳ Pending
   - IT will create Function App
   - IT will add you as Contributor

7. **Deploy Azure Function Code** 🔜 Next
   - Claude will generate complete backend code
   - Endpoints: GET/POST/PATCH/DELETE for `/api/trainees`
   - Deploy via Azure Portal or VS Code

8. **Update Frontend App**
   - Modify `progress-tracker.html` to call Azure Function instead of SharePoint directly
   - Remove MSAL (no user sign-in needed)

9. **Deploy to SharePoint**
   - Upload updated `progress-tracker.html` to Document Library
   - Update Azure AD Redirect URI

10. **Data Migration & User Rollout**
    - Export Google Sheets to Excel
    - Use Bulk Import (Fleet defaults to B738)
    - Distribute admin password
    - Share app URL

---

## Key Details

| Item | Value |
|------|-------|
| App ID | `82a4ec5a-d90d-4957-8021-3093e60a4d70` |
| Tenant ID | `8fc3a567-1ee8-4994-809c-49f50cdb6d48` |
| Site URL | `https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING` |
| List Name | `Training_Progress` |
| User | mohamadshazreen.sazali@malaysiaairlines.com |

---

## Files

| File | Purpose |
|------|---------|
| `progress-tracker.html` | Main app file (production ready) |
| `index-sharepoint-v3-enhanced.html` | Backup/original |
| `SETUP_STATUS.md` | Full status details |
| `CONTINUE_HERE.md` | This file |
| `EMAIL_TO_IT_SECURITY_MITIGATIONS.md` | Security mitigations doc |
| `EMAIL_TO_IT_AZURE_FUNCTION.md` | **NEW** - Request for Azure Function App |

---

## Quick Resume Commands

```bash
# Start local server
python -m http.server 8000

# Test app
# Open: http://localhost:8000/progress-tracker.html
```

## Testing Notes

1. **Test Mode**: Toggle to use local storage instead of SharePoint
2. **Sample Data**: Load sample data (includes CUC batches, fleet assignments)
3. **PDF Import**: Upload TJI PDF to extract trainee data
4. **Bulk Import**: Upload Excel file (Fleet defaults to B738 if missing)
5. **CUC Features**: CUC batches show Command Check Date, complete at LRC
6. **Fleet Filter**: Filter by aircraft type
7. **Analytics**: View charts in Analytics section
