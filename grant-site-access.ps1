# Grant Sites.Selected permission to specific SharePoint site
# Run this ONCE after configuring your Azure AD app

$SiteUrl = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
$AppId = "82a4ec5a-d90d-4957-8021-3093e60a4d70"  # Your app's client ID
$TenantId = "8fc3a567-1ee8-4994-809c-49f50cdb6d48"  # MAG tenant

Write-Host "Granting app access to SharePoint site..." -ForegroundColor Yellow
Write-Host "Site: $SiteUrl" -ForegroundColor Gray
Write-Host "App ID: $AppId`n" -ForegroundColor Gray

# Connect using Microsoft Graph
Connect-MgGraph -TenantId $TenantId -Scopes "Sites.FullControl.All"

# Get the site ID
$site = Get-MgSite -SiteId "$($SiteUrl -replace 'https://', ''):/"

Write-Host "Found site: $($site.DisplayName)" -ForegroundColor Green

# Grant the app write permission to this specific site
$params = @{
    roles = @("write")  # Options: read, write, owner
    grantedToIdentities = @(
        @{
            application = @{
                id = $AppId
                displayName = "Training Tracker App"
            }
        }
    )
}

New-MgSitePermission -SiteId $site.Id -BodyParameter $params

Write-Host "`n✅ Successfully granted app access to the site!" -ForegroundColor Green
Write-Host "Your PowerShell scripts can now connect using this app." -ForegroundColor Green

Disconnect-MgGraph
