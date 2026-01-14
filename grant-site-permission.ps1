# Grant your app access to the specific SharePoint site
# This is required when using Sites.Selected permission

$SiteUrl = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
$AppId = "82a4ec5a-d90d-4957-8021-3093e60a4d70"
$TenantId = "8fc3a567-1ee8-4994-809c-49f50cdb6d48"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Granting App Access to Site" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

Write-Host "Site: $SiteUrl" -ForegroundColor Gray
Write-Host "App ID: $AppId`n" -ForegroundColor Gray

# Connect to SharePoint as admin (you'll sign in interactively)
Write-Host "Connecting to SharePoint (you need admin rights on this site)..." -ForegroundColor Yellow
# Note: We connect as YOU (not as the app) to grant the app permissions
Connect-PnPOnline -Url $SiteUrl -Interactive

Write-Host "`nGranting 'Write' permission to the app for this site..." -ForegroundColor Yellow

# Grant the app write access to this specific site
Grant-PnPAzureADAppSitePermission `
    -AppId $AppId `
    -DisplayName "Training Tracker App" `
    -Site $SiteUrl `
    -Permissions Write

Write-Host "`n✅ Successfully granted app access!" -ForegroundColor Green
Write-Host "Your app can now access this SharePoint site." -ForegroundColor Green

# Show current permissions
Write-Host "`nCurrent app permissions on this site:" -ForegroundColor Yellow
Get-PnPAzureADAppSitePermission | Where-Object { $_.AppId -eq $AppId } | Format-Table DisplayName, AppId, PermissionKind -AutoSize

Disconnect-PnPOnline

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Done! You can now run the migration script." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
