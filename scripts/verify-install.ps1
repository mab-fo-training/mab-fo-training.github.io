Write-Host 'Checking installed modules...' -ForegroundColor Cyan
$pnp = Get-Module -ListAvailable -Name PnP.PowerShell
$excel = Get-Module -ListAvailable -Name ImportExcel

if ($pnp) {
    Write-Host "PnP.PowerShell v$($pnp.Version) - Installed" -ForegroundColor Green
} else {
    Write-Host 'PnP.PowerShell - NOT installed' -ForegroundColor Red
}

if ($excel) {
    Write-Host "ImportExcel v$($excel.Version) - Installed" -ForegroundColor Green
} else {
    Write-Host 'ImportExcel - NOT installed' -ForegroundColor Red
}
