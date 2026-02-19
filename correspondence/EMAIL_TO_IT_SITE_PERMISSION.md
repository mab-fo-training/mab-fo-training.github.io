# Email to IT

**Subject:** Request: Grant App Permission to FLTOPS-TRAINING SharePoint Site

---

Hi Team,

I need help granting our Training Tracker app access to the FLTOPS-TRAINING SharePoint site.

## Reason

We are migrating Flight Operations training records from Google Sheets to SharePoint. The app uses `Sites.Selected` permission (as recommended) which requires the app to be explicitly granted access to the specific site.

## Action Required

Please run this PowerShell script as SharePoint Administrator:

```powershell
Connect-MgGraph -Scopes "Sites.FullControl.All"

$site = Get-MgSite -SiteId "mabitdept.sharepoint.com:/sites/FLTOPS-TRAINING"

$params = @{
    roles = @("write")
    grantedToIdentities = @(
        @{
            application = @{
                id = "82a4ec5a-d90d-4957-8021-3093e60a4d70"
                displayName = "Training Tracker SharePoint App"
            }
        }
    )
}

New-MgSitePermission -SiteId $site.Id -BodyParameter $params
```

## Details

| Item | Value |
|------|-------|
| App Name | Training Tracker SharePoint App |
| App ID | `82a4ec5a-d90d-4957-8021-3093e60a4d70` |
| Site | `https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING` |
| Permission Needed | Write |

Please let me know once completed.

Thank you.

Shazreen
