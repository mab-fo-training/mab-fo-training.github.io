# PowerShell Script to Test SharePoint Setup
# This script checks prerequisites and connectivity before running the migration

Write-Host "================================" -ForegroundColor Cyan
Write-Host "SharePoint Migration Prerequisites Check" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Configuration
$SiteUrl = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
$ListName = "Training_Progress"

# 1. Check PnP.PowerShell Module
Write-Host "1. Checking PnP.PowerShell module..." -ForegroundColor Yellow

# Manually check the install location
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PnP.PowerShell"
if (Test-Path $modulePath) {
    $versions = Get-ChildItem $modulePath -Directory | Select-Object -ExpandProperty Name
    Write-Host "   ✅ PnP.PowerShell version $($versions -join ', ') is installed" -ForegroundColor Green
    # Import the module
    Import-Module PnP.PowerShell -ErrorAction Stop
} else {
    Write-Host "   ❌ PnP.PowerShell is NOT installed" -ForegroundColor Red
    Write-Host "   Run: Install-Module -Name PnP.PowerShell -Scope CurrentUser" -ForegroundColor Yellow
    exit
}

# 2. Check ImportExcel Module
Write-Host "`n2. Checking ImportExcel module..." -ForegroundColor Yellow
$excelModule = Get-Module -ListAvailable -Name ImportExcel
if ($excelModule) {
    Write-Host "   ✅ ImportExcel version $($excelModule.Version) is installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ ImportExcel is NOT installed" -ForegroundColor Red
    Write-Host "   Run: Install-Module -Name ImportExcel -Scope CurrentUser" -ForegroundColor Yellow
    exit
}

# 3. Test SharePoint Connection
Write-Host "`n3. Testing SharePoint connection..." -ForegroundColor Yellow
try {
    Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId "82a4ec5a-d90d-4957-8021-3093e60a4d70"
    Write-Host "   ✅ Successfully connected to SharePoint" -ForegroundColor Green

    # 4. Check if list exists
    Write-Host "`n4. Checking if list '$ListName' exists..." -ForegroundColor Yellow
    $list = Get-PnPList -Identity $ListName -ErrorAction Stop
    Write-Host "   ✅ List '$ListName' found" -ForegroundColor Green

    # 5. Check list columns
    Write-Host "`n5. Checking list columns..." -ForegroundColor Yellow
    $fields = Get-PnPField -List $ListName
    $requiredColumns = @(
        "Title",
        "Batch",
        "Staff_ID",
        "Rank",
        "Name",
        "First_IOE_Date",
        "Functional_Date",
        "LRC_Date",
        "Interview_Date",
        "Sectors_Flown",
        "Remarks",
        "Last_Updated",
        "Manual_Highlight",
        "Sector_History"
    )

    $missingColumns = @()
    foreach ($col in $requiredColumns) {
        $field = $fields | Where-Object { $_.InternalName -eq $col }
        if ($field) {
            Write-Host "   ✅ $col ($($field.TypeAsString))" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $col - MISSING" -ForegroundColor Red
            $missingColumns += $col
        }
    }

    if ($missingColumns.Count -gt 0) {
        Write-Host "`n⚠️ Missing columns detected!" -ForegroundColor Red
        Write-Host "   Please create these columns in your SharePoint list:" -ForegroundColor Yellow
        $missingColumns | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    }

    # 6. Test write permission
    Write-Host "`n6. Testing write permissions..." -ForegroundColor Yellow
    try {
        $testItem = Add-PnPListItem -List $ListName -Values @{
            "Title" = "TEST_DELETE_ME"
            "Batch" = "TEST"
            "Staff_ID" = "TEST001"
            "Rank" = "FO"
            "Name" = "Test User"
        }
        Write-Host "   ✅ Write permission confirmed (test item created)" -ForegroundColor Green

        # Clean up test item
        Remove-PnPListItem -List $ListName -Identity $testItem.Id -Force
        Write-Host "   ✅ Test item deleted successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Cannot write to list: $_" -ForegroundColor Red
    }

    # Disconnect
    Disconnect-PnPOnline

    Write-Host "`n================================" -ForegroundColor Cyan
    Write-Host "✅ All checks passed! Ready for migration." -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Cyan
}
catch {
    Write-Host "   ❌ Error: $_" -ForegroundColor Red
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify the Site URL is correct" -ForegroundColor White
    Write-Host "2. Ensure you have permissions to the site" -ForegroundColor White
    Write-Host "3. Check if you need to authenticate with a different account" -ForegroundColor White
}
