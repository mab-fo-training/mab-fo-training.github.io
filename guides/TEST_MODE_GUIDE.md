# Test Mode Guide - Training Progress Tracker

## 📋 Overview

Test Mode allows you to run the Training Progress Tracker **without any Azure AD or SharePoint setup**. Perfect for:
- 🧪 Testing all features locally
- 👥 Demonstrating the app to stakeholders
- 🎓 Training users before production deployment
- 💻 Developing new features offline
- 🚀 Quick prototyping and validation

**No cloud setup required!** All data is stored in your browser's localStorage.

---

## 🎯 Quick Start (3 Steps)

### Step 1: Start a Local Server

**Option A - Python (Recommended):**
```bash
cd "C:\Users\TestBed\Desktop\Microsoft Training Tracker"
python -m http.server 8000
```

**Option B - Node.js:**
```bash
cd "C:\Users\TestBed\Desktop\Microsoft Training Tracker"
npx http-server -p 8000
```

### Step 2: Open in Browser
Navigate to:
```
http://localhost:8000/index-sharepoint-v3-enhanced.html
```

### Step 3: Enable Test Mode
1. Find the toggle switch at the top right of the configuration panel
2. Click to switch from **"🌐 SharePoint"** to **"🧪 Test Mode"**
3. The panel turns orange - you're ready!

---

## 🔑 Authentication

### Test Mode Sign In

1. Click the **"🧪 Test Sign In"** button (orange button in header)
2. A prompt will appear asking for your name
3. Enter any name (e.g., "John Smith") or press OK for default "Test User"
4. You're now signed in!

**No password, no Microsoft account, no Azure AD needed!**

---

## 📊 Loading Data

### Option 1: Auto-Load Sample Data (Recommended)
When you first access Admin Panel, sample data loads automatically:
- 20 realistic trainees
- Various training stages (In Progress, Functional, Completed)
- Multiple batches (2023-12, 2024-01, 2024-02, 2024-03)
- Different ranks (FO, SFO, CAPT, SO, CDT)

### Option 2: Manual Load Sample Data
1. In the orange Test Mode panel, click **"📊 Load Sample Data"**
2. Generates 20 fresh trainees with random progress
3. Overwrites existing data

### Option 3: Build Your Own
Start with empty data and manually add trainees using the Admin Panel.

---

## 👤 Using the User Portal

The User Portal lets trainees update their own information.

### Access User Portal:
1. Click **"👤 User Portal"** tab at the top
2. You'll see the Staff ID entry screen

### Load Your Record:
1. Enter a Staff ID (try: `STF10000` to `STF10019` for sample data)
2. Click **"🔍 Load Info"** button
3. Your information appears

### Update Information:
1. **Rank** - Select from dropdown (FO, SFO, CAPT, SO, CDT)
   - *Locks after first save to prevent changes*
2. **First IOE Date** - Click date picker
3. **Functional Date** - Click date picker
4. **LRC Date** - Click date picker
5. **Interview Date** - Click date picker
6. **Sectors Flown** - Enter number
7. **Remarks** - Add notes

### Save Changes:
1. Click **"💾 Save All Updates"** button
2. Confirmation message appears
3. Changes saved to localStorage
4. Sector history tracked automatically

---

## 🔐 Using the Admin Panel

The Admin Panel provides full management access.

### Access Admin Panel:
1. Click **"🔐 Admin Panel"** tab at the top
2. Enter admin password: **`admin`** (or any non-empty text in test mode)
3. Click **"✅ Verify Access"** button
4. Admin dashboard appears

### Load Data:
Click **"🔄 Refresh from SharePoint"** (actually loads from localStorage in test mode)

### View Trainee Table:
- All trainees displayed in a sortable table
- Color-coded rows:
  - ⚪ **White** - In Progress
  - 🔵 **Blue** - Functional (has IOE + Functional dates)
  - 🟢 **Green** - Completed (all 4 dates filled)
  - 🔴 **Red** - Special case (manually highlighted)

### Add New Trainee:
1. Click **"➕ Add Trainee"** button
2. Fill in the modal form:
   - **Batch** (e.g., 2024-03)
   - **Staff ID** (e.g., STF12345)
   - **Rank** (FO, SFO, CAPT, SO, CDT)
   - **Name** (e.g., AHMAD RIZAL)
   - **Dates** (optional - click date pickers)
   - **Sectors Flown** (number)
   - **Remarks** (optional notes)
   - **Manual Highlight** (blue/green/red - optional)
3. Click **"💾 Save to SharePoint"** (saves to localStorage)
4. New trainee appears in table

### Edit Trainee:
1. Find trainee in table
2. Click **✏️** (Edit) button in Actions column
3. Modal opens with current data
4. Update any fields
5. Click **"💾 Save to SharePoint"**
6. Changes saved and table refreshes

### Delete Trainee:
1. Find trainee in table
2. Click **🗑️** (Delete) button in Actions column
3. Confirm deletion
4. Trainee removed from localStorage
5. Table refreshes automatically

---

## 🔍 Filtering & Searching

### Search Box:
1. Type in the **"🔍 Search..."** box at top of table
2. Searches: Name, Staff ID
3. Real-time filtering

### Year Filter:
1. Click **"Year"** dropdown
2. Select year from batch (e.g., 2024)
3. Shows only trainees from that year

### Batch Filter:
1. Click **"Batch"** dropdown
2. Select specific batch (e.g., 2024-03)
3. Shows only trainees from that batch

### Rank Filter:
1. Click **"Rank"** dropdown
2. Select rank (FO, SFO, CAPT, SO, CDT)
3. Shows only trainees with that rank

### Status Filter:
1. Click **"Status"** dropdown
2. Select status:
   - **In Progress** - No functional date yet
   - **Functional** - Has IOE + Functional dates
   - **Completed** - All 4 dates filled
3. Shows only trainees with that status

### Sorting:
1. Click any column header with ⇅ symbol
2. First click: Sort ascending ↑
3. Second click: Sort descending ↓
4. Works on: Batch, Staff ID, Rank, Name, Dates, Sectors

---

## 📈 Analytics Dashboard

### Access Analytics:
1. From Admin Panel, click **"📊 Analytics"** button
2. Analytics dashboard appears

### Available Charts:

**1. Status Distribution (Pie Chart)**
- Shows breakdown of trainee statuses
- In Progress vs Functional vs Completed
- Percentage and count for each

**2. Top 10 Trainees by Sectors (Bar Chart)**
- Leaderboard of most experienced trainees
- Sorted by sectors flown
- Useful for identifying senior trainees

### Filter by Batch:
1. Use the **"Batch"** dropdown in analytics
2. Select specific batch or "All Batches"
3. Charts update automatically

### Return to Admin:
Click **"← Back to Admin"** button

---

## 📝 Change History

### Access History:
1. From Admin Panel, click **"📝 History"** button
2. Change history dashboard appears

### What's Tracked:
- **CREATE** - New trainee added
- **UPDATE** - Trainee information changed
- **DELETE** - Trainee removed
- Timestamp for each change
- User who made the change
- Trainee name and Staff ID

### Return to Admin:
Click **"← Back to Admin"** button

---

## 📊 Exporting Data

### Export to Excel:
1. From Admin Panel, click **"📊 Export to Excel"** button
2. Excel file downloads automatically
3. Filename: `Training_Progress_YYYY-MM-DD.xlsx`
4. Includes all filtered data (respects current filters)
5. Formatted with headers and borders

### Export for Power BI:
1. Click **"📈 Export for Power BI"** button
2. Clean Excel file downloads (optimized for Power BI import)
3. Same format as Excel export
4. Ready to import into Power BI Desktop

**Tip:** Apply filters before exporting to create custom reports!

---

## 🔄 Managing Test Data

### Load Fresh Sample Data:
1. In Test Mode panel, click **"📊 Load Sample Data"**
2. Generates 20 new trainees
3. Overwrites existing data
4. Useful for resetting to demo state

### Clear All Data:
1. In Test Mode panel, click **"🗑️ Clear All Data"**
2. Confirmation dialog appears
3. Click OK to confirm
4. All trainees deleted
5. Change history cleared
6. Start fresh with empty database

**Warning:** Clearing data is permanent (within localStorage). No undo!

---

## 🔀 Switching Between Modes

### Test Mode → SharePoint Mode:
1. Click the toggle switch at top
2. Orange panel disappears, blue panel appears
3. Configure SharePoint Site URL and List Name
4. Sign in with Microsoft account
5. Data switches to SharePoint Lists

**Note:** Test Mode data (localStorage) and SharePoint data are completely separate. Switching modes doesn't transfer data.

### SharePoint Mode → Test Mode:
1. Click the toggle switch at top
2. Blue panel disappears, orange panel appears
3. Test sign in
4. Data switches to localStorage

**Your preference is saved!** When you return to the page, your last selected mode is remembered.

---

## 💾 Data Persistence

### Where is Data Stored?
Test Mode uses **browser localStorage**:
- Key: `test_cadets` (trainee data)
- Key: `test_changeHistory` (change log)
- Key: `testMode` (mode preference)

### Data Persistence Rules:
✅ **Persists when you:**
- Close the browser tab
- Refresh the page
- Close the browser
- Restart your computer

❌ **Data is lost when you:**
- Clear browser cache/cookies
- Clear localStorage manually
- Use incognito/private browsing
- Switch to different browser

### Backup Your Test Data:
1. Export to Excel regularly
2. Save the .xlsx file
3. Manually re-import if needed

---

## 🧪 Test Scenarios

### Scenario 1: New Trainee Onboarding
1. Add trainee with Batch, Staff ID, Name, Rank
2. Leave dates empty (In Progress status)
3. Verify white background in table
4. Update First IOE Date later
5. Check status remains In Progress (needs Functional Date too)

### Scenario 2: Complete Training Flow
1. Add trainee with all basic info
2. Add First IOE Date → Save
3. Add Functional Date → Status becomes "Functional" (blue)
4. Add LRC Date → Still functional
5. Add Interview Date → Status becomes "Completed" (green)

### Scenario 3: Sector Tracking
1. Open User Portal as trainee
2. Update Sectors Flown: 10 → Save
3. Update again: 25 → Save
4. View Change History → See sector updates logged
5. Track progression over time

### Scenario 4: Manual Override
1. Add/Edit trainee
2. Set Manual Highlight to "red"
3. Save → Row turns red regardless of dates
4. Useful for flagging issues or special cases

### Scenario 5: Bulk Management
1. Load 20 sample trainees
2. Filter by Batch: 2024-03
3. Export to Excel (only filtered)
4. Open in Excel, review
5. Use for reporting

---

## 📋 Sample Data Details

### Generated Trainees:
- **Count:** 20 trainees
- **Staff IDs:** STF10000 to STF10019
- **Batches:** 2023-12, 2024-01, 2024-02, 2024-03 (rotated)
- **Ranks:** FO, SFO, CAPT, SO, CDT (rotated)
- **Names:** Realistic Malaysian names
- **Dates:** Random progression (realistic intervals)
- **Sectors:** 0-100 (based on training stage)
- **Status Mix:** ~20% In Progress, ~30% Functional, ~50% Completed

### Example Trainees:
```
STF10000 - AHMAD RIZAL - FO - 2024-01 - Completed
STF10001 - SITI NURHALIZA - SFO - 2024-02 - Functional
STF10002 - CHEN WEI - CAPT - 2024-03 - In Progress
...
```

---

## ⚠️ Limitations

### Test Mode Limitations:

1. **No Real Authentication**
   - Anyone can sign in with any name
   - No actual security
   - Don't use for sensitive data

2. **Browser-Specific Data**
   - Data doesn't sync across browsers
   - Chrome data ≠ Firefox data
   - Different computers = different data

3. **No Multi-User Sync**
   - Can't simulate real-time collaboration
   - No conflict resolution
   - Single browser instance only

4. **Storage Limits**
   - localStorage typically limited to 5-10MB
   - Should handle hundreds of trainees easily
   - Very large datasets may hit limits

5. **No Server-Side Features**
   - No Power BI direct connection
   - No real SharePoint integration
   - No version history (beyond change log)

### What Test Mode IS Good For:
✅ Feature testing and validation
✅ User interface testing
✅ Demo and presentation
✅ Training and onboarding
✅ Prototyping new features
✅ Local development

### What Test Mode is NOT For:
❌ Production use
❌ Multi-user collaboration
❌ Long-term data storage
❌ Cross-device sync
❌ Regulatory compliance

---

## 🔧 Troubleshooting

### Issue: Toggle switch doesn't work
**Solution:**
- Refresh the page (F5)
- Clear browser cache
- Ensure JavaScript is enabled

### Issue: Sample data won't load
**Solution:**
- Check browser console (F12) for errors
- Try "Clear All Data" then "Load Sample Data"
- Ensure you're signed in (test mode)

### Issue: Changes not saving
**Solution:**
- Check localStorage is not full
- Try clearing test data and starting fresh
- Ensure you clicked "Save" button
- Check browser console for errors

### Issue: Data disappeared
**Solution:**
- Did you clear browser cache?
- Are you in the same browser?
- Check localStorage keys exist (F12 → Application → Local Storage)
- Reload sample data if needed

### Issue: Admin password not working
**Solution:**
- In test mode, use "admin" or any non-empty text
- Ensure you're in test mode (orange panel)
- Try refreshing the page

### Issue: Can't switch modes
**Solution:**
- Refresh the page
- Clear browser cache
- Check console for JavaScript errors
- Manually toggle: localStorage.setItem('testMode', 'true')

---

## 🚀 Advanced Tips

### Tip 1: Custom Test Data
Edit the `generateSampleData()` function to create custom test scenarios:
- Different batch patterns
- Specific training stages
- Custom names and IDs
- Realistic company data

### Tip 2: Persistent Demos
For consistent demos:
1. Load sample data
2. Customize specific trainees
3. Never clear data
4. Always use same browser
5. Export backup before major changes

### Tip 3: Multi-Browser Testing
Test cross-browser compatibility:
- Open in Chrome → Load data → Test
- Open in Firefox → Separate data → Test
- Open in Edge → Separate data → Test
- Verify UI/UX consistency

### Tip 4: Developer Console
Use browser console (F12) to:
```javascript
// View current data
console.log(JSON.parse(localStorage.getItem('test_cadets')));

// View change history
console.log(JSON.parse(localStorage.getItem('test_changeHistory')));

// Manually clear
localStorage.removeItem('test_cadets');

// Export data
copy(localStorage.getItem('test_cadets'));
```

### Tip 5: Automated Testing
Once comfortable, you can:
- Write Selenium scripts for automated testing
- Use browser automation tools
- Test all workflows programmatically
- Validate data integrity

---

## 📚 Related Documentation

- **SETUP_GUIDE.md** - Full SharePoint/Azure setup for production
- **QUICK_REFERENCE.md** - End-user quick reference (SharePoint version)
- **CLAUDE.md** - Technical architecture documentation
- **MIGRATION_GUIDE.md** - Google Sheets to SharePoint migration

---

## ❓ FAQ

**Q: Is test mode secure enough for real data?**
A: No. Test mode has no real authentication. Use SharePoint mode for production.

**Q: Can I migrate test data to SharePoint?**
A: Not directly. Export to Excel, then import to SharePoint List manually.

**Q: How many trainees can I store in test mode?**
A: localStorage limits vary, but typically handles 500+ trainees easily.

**Q: Can multiple people use test mode together?**
A: No. Each browser has separate data. Use SharePoint mode for collaboration.

**Q: Will test mode work offline?**
A: Yes! After first page load, works completely offline (except XLSX export library).

**Q: Can I use this on mobile?**
A: Yes, mobile browsers support localStorage. UI is mobile-responsive.

**Q: What happens if I switch browsers?**
A: Data won't transfer. Each browser has separate localStorage.

**Q: Can I backup test data?**
A: Yes, export to Excel regularly. Or copy localStorage keys manually.

**Q: Does test mode expire?**
A: No expiration. Data persists until you clear it or clear browser data.

**Q: Can I test Power BI integration?**
A: Export Excel works. Direct Power BI connection requires SharePoint mode.

---

## 🎉 Getting Started Checklist

Ready to test? Follow this checklist:

- [ ] Start local server (Python or Node.js)
- [ ] Open `index-sharepoint-v3-enhanced.html` in browser
- [ ] Toggle to Test Mode (orange panel)
- [ ] Test sign in (enter any name)
- [ ] Load sample data (or start fresh)
- [ ] Try User Portal (Staff ID: STF10000)
- [ ] Try Admin Panel (Password: admin)
- [ ] Add a new trainee
- [ ] Edit an existing trainee
- [ ] Test filters and search
- [ ] View analytics dashboard
- [ ] View change history
- [ ] Export to Excel
- [ ] Clear data and reload sample data

**You're ready to explore!** 🚀

---

**Version:** 3.0 Enhanced with Test Mode
**Last Updated:** November 2025
**Test Mode Added:** November 2025
