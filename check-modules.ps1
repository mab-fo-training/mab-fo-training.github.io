# Quick check for required PowerShell modules

Write-Host "Checking PowerShell modules...`n" -ForegroundColor Cyan

# Check PnP.PowerShell
$pnp = Get-Module -ListAvailable -Name PnP.PowerShell
if ($pnp) {
    Write-Host "✅ PnP.PowerShell v$($pnp.Version) - Installed" -ForegroundColor Green
} else {
    Write-Host "❌ PnP.PowerShell - NOT installed" -ForegroundColor Red
    Write-Host "   Install with: Install-Module -Name PnP.PowerShell -Scope CurrentUser" -ForegroundColor Yellow
}

# Check ImportExcel
$excel = Get-Module -ListAvailable -Name ImportExcel
if ($excel) {
    Write-Host "✅ ImportExcel v$($excel.Version) - Installed" -ForegroundColor Green
} else {
    Write-Host "❌ ImportExcel - NOT installed" -ForegroundColor Red
    Write-Host "   Install with: Install-Module -Name ImportExcel -Scope CurrentUser" -ForegroundColor Yellow
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
