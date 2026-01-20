# Continue From Here

**Last Updated:** 2026-01-20

---

## Current Status: Evaluating Deployment Architecture

### Latest Update (2026-01-20)

**Explored Azure AD Application Permissions vs Delegated Permissions**

Researched using app-only authentication (Application permissions) instead of user-delegated permissions to eliminate the need for trainees to have SharePoint site access.

**Key Findings:**
- App-only auth requires **certificate authentication** (not just client secret) for SharePoint REST API
- Cannot be done from client-side JavaScript (security risk to expose credentials)
- Requires a **backend server** (Azure Function) to proxy API calls
- `Sites.Selected` permission allows granular access to only specific sites/lists

**Architecture Options Evaluated:**

| Option | Architecture | Cost | Complexity |
|--------|-------------|------|------------|
| **A: Delegated (current)** | Browser → SharePoint | $0 | Low |
| **B: Azure Function Backend** | Browser → Azure Function → SharePoint | $0-2/mo | Medium |
| **C: Dedicated Site** | Browser → SharePoint (isolated site) | $0 | Low |

**Azure Functions Free Tier (Consumption Plan):**
- 1 million executions/month FREE
- 400,000 GB-seconds/month FREE
- Estimated app usage: ~30,000 executions/month (3% of free tier)
- Only cost: Storage account (~$0.50-2/month)

**Decision Pending:** Choose between Option B (Azure Function) or Option C (Dedicated Site)

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

1. ~~**Add SharePoint columns**~~ ✓ DONE (2026-01-20)
   - Fleet (Choice: B738, B738M, A330, A350)
   - Command_Check_Date (Date)

2. **Choose Deployment Architecture** ⚠️ DECISION NEEDED

   **Issue:** Trainees need SharePoint site access to use the app with current delegated permissions.

   **Option B: Azure Function Backend (Recommended if IT prefers no site access)**
   ```
   Browser App → Azure Function (certificate auth) → SharePoint
   ```
   - Uses `Sites.Selected` permission (access only to Training_Progress list)
   - Trainees don't need any SharePoint site access
   - Cost: ~$0-2/month (free tier covers usage)
   - Requires: Certificate setup, Azure Function deployment
   - **To implement:** Claude can build the Azure Function backend

   **Option C: Dedicated SharePoint Site (Simpler)**
   - Create `FLTOPS-TRACKER` site with only the Training_Progress list
   - Give trainees Read access to site + Contribute to list
   - No code changes needed
   - Cost: $0

   **References:**
   - [Microsoft: App-Only Access via Entra ID](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/security-apponly-azuread)
   - [Microsoft: Sites.Selected Permissions](https://techcommunity.microsoft.com/blog/spblog/develop-applications-that-use-sites-selected-permissions-for-spo-sites-/3790476)
   - [Azure Functions Pricing](https://azure.microsoft.com/en-us/pricing/details/functions/)

3. **Deploy to SharePoint**
   - Upload `progress-tracker.html` to Document Library
   - Copy the URL
   - If Option B: Deploy Azure Function first, update app to call function
   - If Option C: Update app's hardcoded site URL to new site

4. **Update Azure AD Redirect URI**
   - Add production URL to App Registration → Authentication

5. **Data Migration**
   - Export Google Sheets to Excel
   - Use Bulk Import (Fleet defaults to B738)

6. **User Rollout**
   - Distribute admin password
   - Send user communication
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
