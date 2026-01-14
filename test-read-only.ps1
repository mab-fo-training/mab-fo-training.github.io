# Test what we can access with current limited permissions

$SiteUrl = "https://mabitdept.sharepoint.com/sites/FLTOPS-TRAINING"
$ListName = "Training_Progress"
$ClientId = "82a4ec5a-d90d-4957-8021-3093e60a4d70"
$TenantId = "8fc3a567-1ee8-4994-809c-49f50cdb6d48"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Testing Read Permissions" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

try {
    Write-Host "Connecting with Device Login..." -ForegroundColor Yellow
    Connect-PnPOnline -Url $SiteUrl -DeviceLogin -Tenant $TenantId -ClientId $ClientId

    Write-Host "`n✅ Connected successfully`n" -ForegroundColor Green

    # Test 1: Can we get the list?
    Write-Host "Test 1: Getting list info..." -ForegroundColor Yellow
    try {
        $list = Get-PnPList -Identity $ListName
        Write-Host "   ✅ Can read list: $($list.Title)" -ForegroundColor Green
        Write-Host "   Item count: $($list.ItemCount)" -ForegroundColor Gray
    }
    catch {
        Write-Host "   ❌ Cannot read list: $_" -ForegroundColor Red
    }

    # Test 2: Can we read items?
    Write-Host "`nTest 2: Reading list items..." -ForegroundColor Yellow
    try {
        $items = Get-PnPListItem -List $ListName -PageSize 5
        Write-Host "   ✅ Can read items: Found $($items.Count) items" -ForegroundColor Green
        if ($items.Count -gt 0) {
            Write-Host "   Sample item: $($items[0]['Title'])" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "   ❌ Cannot read items: $_" -ForegroundColor Red
    }

    # Test 3: Can we write?
    Write-Host "`nTest 3: Testing write permission..." -ForegroundColor Yellow
    try {
        $testItem = Add-PnPListItem -List $ListName -Values @{
            "Title" = "TEST_DELETE_ME"
            "Batch" = "TEST"
            "Staff_ID" = "TEST001"
        }
        Write-Host "   ✅ Can write! Test item created (ID: $($testItem.Id))" -ForegroundColor Green

        # Clean up
        Remove-PnPListItem -List $ListName -Identity $testItem.Id -Force
        Write-Host "   ✅ Test item deleted" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Cannot write: $_" -ForegroundColor Red
        Write-Host "   This is expected with 'Limited Control' permissions" -ForegroundColor Yellow
    }

    Disconnect-PnPOnline

    Write-Host "`n================================" -ForegroundColor Cyan
    Write-Host "Recommendation:" -ForegroundColor Yellow
    Write-Host "Request 'Edit' or 'Contribute' permissions on the site," -ForegroundColor White
    Write-Host "OR switch to Application permissions in Azure AD." -ForegroundColor White
    Write-Host "================================" -ForegroundColor Cyan
}
catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
}
