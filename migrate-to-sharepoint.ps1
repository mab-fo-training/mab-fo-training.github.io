# PowerShell Script to Migrate Data from Excel to SharePoint List
# Requires: PnP PowerShell Module
# Install: Install-Module -Name PnP.PowerShell -Scope CurrentUser

# Configuration
$SiteUrl = "https://yourtenant.sharepoint.com/sites/yoursite"
$ListName = "Training_Progress"
$ExcelPath = "C:\Path\To\training_data.xlsx"

# Connect to SharePoint using your Azure AD app
Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId "82a4ec5a-d90d-4957-8021-3093e60a4d70"

# Read Excel file
$excel = Import-Excel -Path $ExcelPath

# Counter
$count = 0
$errors = 0

# Import each row
foreach ($row in $excel) {
    try {
        # Prepare item values
        $itemValues = @{
            "Title" = $row.Name
            "Batch" = $row.Batch
            "Staff_ID" = $row.'Staff ID'
            "Rank" = $row.Rank
            "Name" = $row.Name
            "First_IOE_Date" = if ($row.'First IOE Date') { [DateTime]::Parse($row.'First IOE Date') } else { $null }
            "Functional_Date" = if ($row.'Functional Date') { [DateTime]::Parse($row.'Functional Date') } else { $null }
            "LRC_Date" = if ($row.'LRC Date') { [DateTime]::Parse($row.'LRC Date') } else { $null }
            "Interview_Date" = if ($row.'Interview Date') { [DateTime]::Parse($row.'Interview Date') } else { $null }
            "Sectors_Flown" = if ($row.'Sectors Flown') { [int]$row.'Sectors Flown' } else { 0 }
            "Remarks" = $row.Remarks
            "Last_Updated" = Get-Date
            "Manual_Highlight" = $row.'Manual Highlight'
            "Sector_History" = "[]" # Start with empty JSON array
        }

        # Add item to SharePoint list
        Add-PnPListItem -List $ListName -Values $itemValues
        $count++
        Write-Host "✅ Imported: $($row.Name) ($count)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error importing $($row.Name): $_" -ForegroundColor Red
        $errors++
    }
}

# Disconnect
Disconnect-PnPOnline

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Migration Complete!" -ForegroundColor Green
Write-Host "Imported: $count trainees" -ForegroundColor Green
Write-Host "Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "================================" -ForegroundColor Cyan
