# SharePoint Connection Test - Device Code Authentication
# This works without complex app registration settings

Write-Host "================================" -ForegroundColor Cyan
Write-Host "SharePoint Connection Test (Device Code)" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Configuration
$SiteUrl = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
$ListName = "Training_Progress"

Write-Host "1. Testing SharePoint connection..." -ForegroundColor Yellow
Write-Host "   You will receive a code - copy it and authenticate in browser`n" -ForegroundColor Gray

try {
    # Use device code authentication (works without special app config)
    Connect-PnPOnline -Url $SiteUrl -DeviceLogin -Tenant "8fc3a567-1ee8-4994-809c-49f50cdb6d48" -ClientId "82a4ec5a-d90d-4957-8021-3093e60a4d70"
    Write-Host "`n   ✅ Successfully connected to SharePoint`n" -ForegroundColor Green

    # Check if list exists
    Write-Host "2. Checking if list '$ListName' exists..." -ForegroundColor Yellow
    $list = Get-PnPList -Identity $ListName -ErrorAction Stop
    Write-Host "   ✅ List '$ListName' found`n" -ForegroundColor Green

    # Check list columns
    Write-Host "3. Checking list columns..." -ForegroundColor Yellow
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

    # Test write permission
    Write-Host "`n4. Testing write permissions..." -ForegroundColor Yellow
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
    Write-Host "3. Make sure you authenticated in the browser" -ForegroundColor White
}
