# Migration Guide: Google Sheets → SharePoint

This guide walks you through migrating your Training Progress Tracker data from Google Sheets to SharePoint Lists.

## 📋 Pre-Migration Checklist

- [ ] Azure AD App Registration configured
- [ ] SharePoint site access confirmed
- [ ] Backup of Google Sheets data created
- [ ] Admin access to create SharePoint lists
- [ ] `index-sharepoint-v3-enhanced.html` file ready

---

## 🗂️ Step 1: Export Data from Google Sheets

### 1.1 Export Main Training Data

1. Open your Google Sheet (the one with training data)
2. **File** → **Download** → **Microsoft Excel (.xlsx)**
3. Save as: `training_data.xlsx`

### 1.2 Export Admin Users (if applicable)

1. Open the "AdminUsers" sheet tab
2. **File** → **Download** → **Microsoft Excel (.xlsx)**
3. Save as: `admin_users.xlsx`

**Your exported file should have these columns:**

| Column | Google Sheets Column | Notes |
|--------|---------------------|-------|
| A | Batch | Text |
| B | Staff_ID | Text |
| C | Rank | CAPT/FO/SO/CDT |
| D | Name | Text |
| E | First_IOE_Date | Date (DD/MM/YY or DD/MM/YYYY) |
| F | Functional_Date | Date |
| G | LRC_Date | Date |
| H | Interview_Date | Date |
| I | Sectors_Flown | Number |
| J | Last_Updated | Timestamp |
| K | Remarks | Text |
| L | Manual_Highlight | blue/green/red |
| M | Sector_History | JSON string (if exists) |

---

## 🏗️ Step 2: Create SharePoint Lists

### 2.1 Create Training_Progress List

1. Navigate to your SharePoint site
2. Click **New** → **List**
3. Choose **Blank list**
4. Name: `Training_Progress`
5. Description: "Trainee progress tracking for flight training programs"
6. Click **Create**

### 2.2 Add Columns to Training_Progress

Click **+ Add column** for each of these:

| # | Column Name | Type | Configuration |
|---|------------|------|---------------|
| 1 | **Batch** | Single line of text | Required: No |
| 2 | **Staff_ID** | Single line of text | Required: Yes, Enforce unique: Yes |
| 3 | **Rank** | Choice | Choices: `CAPT`, `FO`, `SFO`, `SO`, `CDT` |
| 4 | **Name** | Single line of text | Required: Yes |
| 5 | **First_IOE_Date** | Date and time | Include time: No |
| 6 | **Functional_Date** | Date and time | Include time: No |
| 7 | **LRC_Date** | Date and time | Include time: No |
| 8 | **Interview_Date** | Date and time | Include time: No |
| 9 | **Sectors_Flown** | Number | Min: 0, Decimals: 0, Default: 0 |
| 10 | **Status** | Single line of text | Required: No |
| 11 | **Remarks** | Multiple lines of text | Plain text, 6 lines |
| 12 | **Last_Updated** | Date and time | Include time: Yes |
| 13 | **Manual_Highlight** | Choice | Choices: `blue`, `green`, `red`, Allow blank: Yes |
| 14 | **Sector_History** | Multiple lines of text | Plain text, For JSON storage |

**Important:**
- Column names MUST match exactly (case-sensitive!)
- The default "Title" column will be auto-populated with Name value

### 2.3 Create AdminUsers List

1. Click **New** → **List**
2. Choose **Blank list**
3. Name: `AdminUsers`
4. Click **Create**

Add columns:

| Column Name | Type | Configuration |
|------------|------|---------------|
| **Email** | Single line of text | Required: Yes |
| **Password** | Single line of text | Required: No |

---

## 📥 Step 3: Import Data to SharePoint

### Method A: Quick Edit (Recommended for <100 records)

1. Open `training_data.xlsx` in Excel
2. Select all data rows (exclude header)
3. Copy (Ctrl+C)
4. Go to SharePoint `Training_Progress` list
5. Click **Quick edit** button (top menu)
6. Click on first empty row
7. Paste (Ctrl+V)
8. **Important:** Map columns correctly:
   - Paste into correct columns by position
   - Dates should auto-convert if format is recognized
9. Click **Exit quick edit**
10. Verify data loaded correctly

### Method B: PowerShell (For 100+ records)

**Prerequisites:**
```powershell
# Install PnP PowerShell
Install-Module -Name PnP.PowerShell -Scope CurrentUser

# Install ImportExcel module
Install-Module -Name ImportExcel -Scope CurrentUser
```

**Run Migration Script:**
```powershell
# Edit the migrate-to-sharepoint.ps1 file
# Update these lines:
$SiteUrl = "https://yourtenant.sharepoint.com/sites/yoursite"
$ListName = "Training_Progress"
$ExcelPath = "C:\Path\To\training_data.xlsx"

# Run the script
.\migrate-to-sharepoint.ps1
```

### Method C: Microsoft Flow/Power Automate

Create a Flow that:
1. Reads Excel file from OneDrive/SharePoint
2. For each row, creates SharePoint list item
3. Maps columns correctly

---

## 🔄 Step 4: Handle Special Fields

### 4.1 Sector_History JSON Conversion

The Sector_History field stores JSON. If your Google Sheets has this data:

**From Google Sheets (column M):**
```json
[{"date":"2024-01-15","count":50,"change":10,"user":"Admin"}]
```

**To SharePoint:**
- Copy the exact JSON string into `Sector_History` column
- Or leave blank `[]` and let users build it going forward

### 4.2 Date Format Conversion

**Google Sheets dates** (DD/MM/YY) need conversion:
- `15/01/24` → `2024-01-15`
- Excel should handle this automatically when pasting
- If not, use Excel formula: `=TEXT(A2,"YYYY-MM-DD")`

### 4.3 Manual_Highlight

Values should be lowercase:
- `blue` (Functional)
- `green` (Completed)
- `red` (Special case)
- Empty/blank (Auto-detect)

---

## 🔐 Step 5: Import Admin Users

1. Open `admin_users.xlsx`
2. Go to SharePoint `AdminUsers` list
3. **Quick edit**
4. Copy/paste admin emails
5. Add password in first row if using password auth (optional)

**Example:**

| Title | Email | Password |
|-------|-------|----------|
| Admin 1 | admin@company.com | YourPassword123 |
| Admin 2 | manager@company.com | |

---

## ⚙️ Step 6: Configure Enhanced Version

1. Open `index-sharepoint-v3-enhanced.html`
2. Update Azure AD credentials (if not done):
   ```javascript
   clientId: 'YOUR_CLIENT_ID_HERE'  // Line ~660
   authority: 'https://login.microsoftonline.com/YOUR_TENANT_ID_HERE'  // Line ~661
   ```
3. Deploy to web server or test locally

---

## ✅ Step 7: Verify Migration

### 7.1 Test Connection

1. Open the enhanced version in browser
2. Enter SharePoint Site URL
3. Enter List Name: `Training_Progress`
4. Click **💾 Save Configuration**
5. Click **🔐 Sign in with Microsoft**
6. Click **🔌 Test Connection**
7. Should show: ✅ Connected

### 7.2 Test Data Load

1. Switch to **Admin Panel** tab
2. Enter admin password or rely on email auth
3. Click **Verify Access**
4. Click **🔄 Refresh from SharePoint**
5. Verify trainee count matches your Google Sheets data
6. Check that all columns loaded correctly

### 7.3 Test User Portal

1. Switch to **User Portal** tab
2. Enter a Staff ID from your data
3. Click **Load Info**
4. Verify all fields populated correctly
5. Test updating a date
6. Click **💾 Save All Updates**
7. Refresh and verify changes persisted

### 7.4 Test Admin Features

1. Go to **Admin Panel**
2. Test filters (Year, Batch, Rank, Status)
3. Click **📊 Analytics** → Verify charts render
4. Click **📝 History** → Check change log
5. Try editing a trainee
6. Try adding a new trainee
7. Export to Excel and verify format

---

## 🐛 Troubleshooting

### Issue: Dates not importing correctly

**Solution:**
- Ensure dates in Excel are in `YYYY-MM-DD` format
- Use Excel formula: `=TEXT(A2,"YYYY-MM-DD")` to convert
- Or manually format column as Date before copying

### Issue: Staff_ID duplicates

**Solution:**
- SharePoint can enforce unique Staff_IDs
- Check for duplicates in source data first
- Remove duplicates before import

### Issue: Rank values not matching

**Solution:**
- Ensure Rank column in SharePoint has exact choices: CAPT, FO, SFO, SO, CDT
- Excel data must match exactly (case-sensitive)
- Clean data: `=UPPER(TRIM(B2))`

### Issue: Sector_History JSON errors

**Solution:**
- Ensure valid JSON format: `[]` or `[{...}]`
- Test JSON validity: https://jsonlint.com/
- Start with empty array `[]` if unsure

### Issue: Connection fails

**Solution:**
- Verify SharePoint URL is complete and correct
- Ensure list name is exactly `Training_Progress` (case-sensitive)
- Check Azure AD permissions granted
- Test accessing list directly in SharePoint first

### Issue: Admin authentication fails

**Solution:**
- Verify `AdminUsers` list exists
- Check email in list matches signed-in Microsoft account
- Ensure Email column has correct email addresses
- Try password auth if email auth fails

---

## 📊 Post-Migration Checklist

After migration, verify:

- [ ] All trainees imported (count matches)
- [ ] All columns populated correctly
- [ ] Dates in correct format
- [ ] Rank values valid
- [ ] Sectors_Flown are numbers
- [ ] Manual_Highlight colors working
- [ ] User Portal loads records by Staff ID
- [ ] Admin Panel shows full table
- [ ] Analytics charts render with data
- [ ] Filters work correctly
- [ ] Export to Excel works
- [ ] Change history tracking works
- [ ] Admin authentication works
- [ ] Can add new trainees
- [ ] Can edit existing trainees
- [ ] Can delete trainees

---

## 🔄 Ongoing Sync (Optional)

If you want to keep Google Sheets and SharePoint in sync temporarily:

### Option 1: Manual Sync
- Export from Google Sheets weekly
- Import to SharePoint using Quick Edit
- Merge any conflicts manually

### Option 2: Power Automate Flow
Create a Flow that:
1. Triggers on Google Sheets change (via webhook)
2. Updates corresponding SharePoint item
3. Or runs on schedule (daily/weekly)

### Option 3: Dual Entry (Transition Period)
- Update both systems during migration period (1-2 months)
- Gradually phase out Google Sheets
- Train users on SharePoint version

---

## 🎯 Best Practices

1. **Backup First**: Always backup Google Sheets before migration
2. **Test Environment**: Test migration on a small subset first
3. **Verify Data**: Check random samples after import
4. **User Training**: Train users on new SharePoint version
5. **Gradual Rollout**: Start with User Portal, then Admin Panel
6. **Monitor**: Watch for issues in first week
7. **Feedback Loop**: Gather user feedback and adjust

---

## 📞 Support

If you encounter issues:

1. Check SharePoint column names match exactly
2. Verify Azure AD App Registration permissions
3. Test SharePoint list access directly
4. Review browser console (F12) for errors
5. Check CLAUDE.md for architecture details

---

**Migration Complete!** 🎉

Your Training Progress Tracker is now running on the Microsoft 365 ecosystem with full feature parity to the Google Sheets version!
