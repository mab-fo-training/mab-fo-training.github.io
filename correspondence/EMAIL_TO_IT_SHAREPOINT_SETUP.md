Subject: Follow-up: HTML File Still Rendering as Preview Despite DenyAddAndCustomizePages Disabled

Hi Team,

Thank you for running the PowerShell command earlier. I can confirm the site-level setting is correct — `DenyAddAndCustomizePages` shows as `Disabled` on our site. However, the HTML file is still opening in preview mode instead of rendering as a web application.

Since the site-level setting is already correct, I believe a tenant-level policy may be overriding it. Could you please check the following:

```powershell
# Check if there's a tenant-level restriction on custom scripts
Get-SPOTenant | Select-Object NoScriptSite, CustomScriptSafeDomainList
```

If `NoScriptSite` is `True`, that would explain why the site-level setting isn't taking effect. To resolve, you could either:

**Option A** — Allow custom scripts for our specific site (preferred, least impact):
```powershell
# If available, whitelist just our site
Set-SPOSite -Identity "https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker" -AllowSelfServiceUpgrade $true
```

**Option B** — Adjust the tenant-level setting:
```powershell
Set-SPOTenant -NoScriptSite $false
```
Note: This would affect all sites, so Option A is preferred if possible.

**What we're trying to achieve**: The file `tracker.html` uploaded to the site's document library at https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker should execute as a web page (load CSS, JavaScript, etc.) when opened in the browser, rather than showing a static HTML preview.

**Alternative approach**: If enabling custom scripts is not feasible due to security policy, would it be possible to get an Azure subscription provisioned (or access to an existing one) so I can host the app on Azure Static Web Apps (free tier)? This would give us a standalone URL (e.g., `https://ioe-training-tracker.azurestaticapps.net`) without requiring any changes to SharePoint's script execution settings. The SharePoint site would still be used purely as the data backend.

Please let me know which option works best or if you have any questions.

Thank you,
Shazreen
