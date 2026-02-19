# Training Progress Tracker - SharePoint Integration Setup Guide

## 📋 Overview

This guide will walk you through integrating your Training Progress Tracker with Microsoft SharePoint Lists. The integration provides:

✅ **Cloud storage** - All data stored securely in SharePoint
✅ **Microsoft Authentication** - Secure sign-in with your Microsoft 365 account
✅ **Real-time collaboration** - Multiple users can access simultaneously
✅ **Automatic backups** - SharePoint handles versioning and backups
✅ **Enterprise security** - Inherits SharePoint permissions

---

## 🎯 Prerequisites

Before starting, ensure you have:

- [ ] Microsoft 365 account with SharePoint access
- [ ] Azure Active Directory admin permissions (or someone who has them)
- [ ] SharePoint site where you can create lists
- [ ] Basic understanding of SharePoint

---

## 📝 Step 1: Create SharePoint List

### 1.1 Navigate to Your SharePoint Site
- Go to your SharePoint site (e.g., `https://yourtenant.sharepoint.com/sites/yoursite`)
- Click **Site contents** or **New** → **List**

### 1.2 Create New List
- Click **+ New** → **List**
- Choose **Blank list**
- Name: `Training_Progress`
- Description: "Trainee progress tracking for flight training programs"
- Click **Create**

### 1.3 Add Required Columns

Click **+ Add column** for each of these (in order):

| Column Name | Type | Settings |
|------------|------|----------|
| **Batch** | Single line of text | Required: No |
| **Staff_ID** | Single line of text | Required: Yes |
| **Rank** | Choice | Choices: FO, SFO, CAPT |
| **Name** | Single line of text | Required: Yes |
| **First_IOE_Date** | Date and time | Include time: No |
| **Functional_Date** | Date and time | Include time: No |
| **LRC_Date** | Date and time | Include time: No |
| **Interview_Date** | Date and time | Include time: No |
| **Sectors_Flown** | Number | Decimal places: 0, Default: 0 |
| **Status** | Single line of text | Required: No |
| **Remarks** | Multiple lines of text | Plain text |
| **Last_Updated** | Date and time | Include time: Yes |
| **Manual_Highlight** | Choice | Choices: blue, green, red |

**Important Notes:**
- Column names must match exactly (including underscores and capitalization)
- The default "Title" column will be used automatically for the trainee name
- Don't delete the Title column!

### 1.4 Configure List Settings (Optional)
- Go to **List settings** → **Versioning settings**
- Enable **Version history** for audit trail
- Set to keep at least 50 versions

---

## 🔐 Step 2: Create Azure AD App Registration

### 2.1 Access Azure Portal
- Go to [Azure Portal](https://portal.azure.com)
- Sign in with your admin account
- Navigate to **Azure Active Directory**

### 2.2 Create New App Registration
1. Click **App registrations** (left menu)
2. Click **+ New registration**
3. Fill in details:
   - **Name**: `Training Progress Tracker`
   - **Supported account types**: Select **Accounts in this organizational directory only (Single tenant)**
   - **Redirect URI**: 
     - Type: **Web**
     - URL: Your deployment URL (e.g., `https://yoursite.com` or `http://localhost:8000` for testing)
4. Click **Register**

### 2.3 Note Your IDs
After creation, you'll see the Overview page. **Copy and save these:**

- ✏️ **Application (client) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- ✏️ **Directory (tenant) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**You'll need these later!**

### 2.4 Configure API Permissions
1. Click **API permissions** (left menu)
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Delegated permissions**
5. Search and add these permissions:
   - ✅ `User.Read` (should already be there)
   - ✅ `Sites.ReadWrite.All`
6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Confirm by clicking **Yes**

### 2.5 Configure Authentication (Important!)
1. Click **Authentication** (left menu)
2. Under **Implicit grant and hybrid flows**, check:
   - ✅ **Access tokens**
   - ✅ **ID tokens**
3. Under **Advanced settings**:
   - Allow public client flows: **No**
4. Click **Save**

---

## 💻 Step 3: Configure the HTML File

### 3.1 Open the HTML File
Open `index-sharepoint.html` in a text editor (VS Code, Notepad++, etc.)

### 3.2 Update MSAL Configuration
Find lines 350-352 and replace with your IDs:

```javascript
auth: {
    clientId: 'YOUR_CLIENT_ID_HERE',        // ← Replace with Application (client) ID
    authority: 'https://login.microsoftonline.com/YOUR_TENANT_ID_HERE',  // ← Replace with Directory (tenant) ID
    redirectUri: window.location.origin
}
```

**Example:**
```javascript
auth: {
    clientId: 'a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6',
    authority: 'https://login.microsoftonline.com/z9y8x7w6-v5u4-t3s2-r1q0-p9o8n7m6l5k4',
    redirectUri: window.location.origin
}
```

### 3.3 Save the File

---

## 🌐 Step 4: Deploy the Application

### Option A: Quick Test (Local Development)

**Using Python:**
```bash
# In the folder with your HTML file
python -m http.server 8000
```

**Using Node.js:**
```bash
# Install http-server globally
npm install -g http-server

# Run server
http-server -p 8000
```

Then open: `http://localhost:8000/index-sharepoint.html`

### Option B: SharePoint (Recommended)

1. **Create a Document Library** in your SharePoint site
2. **Upload** the HTML file
3. **Copy the file URL** (right-click → Copy link)
4. **Share** the link with your team

**Note:** You may need to update the Azure AD redirect URI to match the SharePoint URL.

### Option C: Azure Static Web Apps (Production)

1. Go to Azure Portal → **Static Web Apps**
2. Click **+ Create**
3. Follow the wizard to deploy your HTML file
4. Get the deployment URL
5. Update Azure AD redirect URI with this URL

### Option D: Microsoft Teams

1. Upload to SharePoint first
2. In Teams channel, click **+** to add a tab
3. Select **Website**
4. Paste your SharePoint file URL
5. Name it "Training Tracker"

---

## 🚀 Step 5: First-Time Setup

### 5.1 Open Your Deployed Application
Navigate to your deployment URL

### 5.2 Configure SharePoint Connection
1. In the **SharePoint Configuration** section:
   - **SharePoint Site URL**: Enter your full site URL
     - Example: `https://contoso.sharepoint.com/sites/FlightTraining`
   - **List Name**: Enter `Training_Progress`
2. Click **💾 Save Configuration**

### 5.3 Sign In
1. Click **🔐 Sign in with Microsoft**
2. Enter your Microsoft 365 credentials
3. Accept the permission consent (first time only)
4. You should see your name in the top right

### 5.4 Test Connection
1. Click **🔌 Test Connection**
2. You should see "✅ Connected"
3. If you see errors, check:
   - SharePoint URL is correct
   - List name matches exactly
   - You have permissions to the list

### 5.5 Load Data
1. Click **🔄 Refresh from SharePoint**
2. Your list should load (empty if new)
3. Try adding a test trainee

---

## 📊 Step 6: Migrate Existing Data (Optional)

If you have existing data in Google Sheets:

### 6.1 Export from Google Sheets
1. Open your Google Sheet
2. **File** → **Download** → **Microsoft Excel (.xlsx)**

### 6.2 Import to SharePoint
1. In your SharePoint list, click **Integrate** → **Excel**
2. Click **Import from Excel**
3. Select your downloaded Excel file
4. Map columns to match your SharePoint columns
5. Click **Import**

### 6.3 Refresh the Tracker
1. In your tracker app, click **🔄 Refresh from SharePoint**
2. Verify all data loaded correctly

---

## 🔧 Troubleshooting

### Issue: "Authentication failed"
**Solution:**
- Verify Client ID and Tenant ID are correct
- Check Azure AD redirect URI matches your deployment URL
- Ensure API permissions were granted admin consent

### Issue: "Connection failed"
**Solution:**
- Verify SharePoint URL is complete and correct
- Ensure list name is exactly `Training_Progress`
- Check you have permissions to access the SharePoint site
- Try accessing the list directly in SharePoint first

### Issue: "Failed to load data"
**Solution:**
- Ensure all required columns exist in SharePoint
- Column names must match exactly (case-sensitive!)
- Check SharePoint list permissions
- View browser console (F12) for detailed errors

### Issue: CORS errors
**Solution:**
- Don't use `file://` protocol - use a web server
- If hosting on SharePoint, ensure proper permissions
- For Azure Static Web Apps, CORS is handled automatically

### Issue: "Token expired"
**Solution:**
- Sign out and sign in again
- Clear browser cache
- Check token expiration settings in Azure AD

---

## 🎓 Usage Guide

### Adding a Trainee
1. Click **➕ Add Trainee**
2. Fill in required fields (Batch, Staff ID, Name)
3. Add optional dates and information
4. Click **💾 Save to SharePoint**

### Editing a Trainee
1. Click **✏️** (edit) button in the Actions column
2. Update information
3. Click **💾 Save to SharePoint**

### Deleting a Trainee
1. Click **🗑️** (delete) button in the Actions column
2. Confirm deletion
3. Data is removed from SharePoint

### Filtering Data
- **Search**: Type name or staff ID
- **Year**: Filter by year from batch
- **Batch**: Filter by specific batch
- **Rank**: Filter by FO, SFO, or CAPT

### Exporting Data
- **📊 Export to Excel**: Download current filtered view
- **📈 Export for Power BI**: Download in Power BI-ready format

### Refreshing Data
- Click **🔄 Refresh from SharePoint** to sync latest data
- Useful when multiple users are working simultaneously

---

## 🔐 Security Best Practices

1. **Permissions**: Configure SharePoint list permissions appropriately
   - Site members: Read/Write
   - Visitors: Read only (or no access)

2. **Azure AD**: Keep your Client ID and Tenant ID secure
   - Don't commit to public repositories
   - Use environment variables for production

3. **Data Privacy**: 
   - SharePoint data is encrypted at rest and in transit
   - Audit trail via SharePoint version history
   - Compliance with your organization's data policies

4. **Access Control**:
   - Review Azure AD permissions regularly
   - Remove access for departing team members
   - Use SharePoint groups for team access

---

## 📈 Power BI Integration

### Create a Power BI Report

1. **Export Data**: Click **📈 Export for Power BI** in your tracker
2. **Open Power BI Desktop**
3. **Get Data** → **Excel** → Select your exported file
4. **Create Visualizations**:
   - Bar chart: Trainees by Batch
   - Pie chart: Status distribution
   - Table: Recent completions
   - Line chart: Progress over time

### Connect Power BI Directly to SharePoint

1. **Power BI Desktop** → **Get Data** → **SharePoint Online List**
2. Enter your SharePoint site URL
3. Select `Training_Progress` list
4. Click **Load**
5. Create your dashboards
6. **Publish** to Power BI Service
7. Set up **Scheduled Refresh** for automatic updates

---

## 🎯 Best Practices

1. **Regular Backups**: SharePoint handles this, but export Excel weekly
2. **Data Validation**: Use SharePoint column validation rules
3. **Naming Conventions**: Keep batch naming consistent
4. **Status Updates**: Update dates promptly for accurate tracking
5. **Remarks Field**: Use for important notes and exceptions
6. **Team Training**: Ensure all users understand the workflow

---

## 🆘 Support Resources

- **SharePoint Help**: https://support.microsoft.com/en-us/sharepoint
- **Azure AD Documentation**: https://docs.microsoft.com/en-us/azure/active-directory/
- **Microsoft Graph API**: https://docs.microsoft.com/en-us/graph/
- **MSAL.js Documentation**: https://github.com/AzureAD/microsoft-authentication-library-for-js

---

## 📝 Frequently Asked Questions

**Q: Can multiple people use this at the same time?**
A: Yes! Data is stored in SharePoint, so multiple users can access simultaneously.

**Q: What happens if I lose internet connection?**
A: The app requires internet to load/save data. Any unsaved changes will be lost.

**Q: Can I access this on mobile?**
A: Yes, it's mobile-responsive and works on phones/tablets.

**Q: How do I give access to new team members?**
A: Add them to the SharePoint site. They'll automatically have access.

**Q: Can I customize the columns?**
A: Yes, add columns in SharePoint, then modify the HTML to display them.

**Q: Is my data secure?**
A: Yes, it uses Microsoft's enterprise-grade security and your organization's compliance policies.

**Q: What if I need to rollback changes?**
A: Use SharePoint's version history to restore previous versions.

**Q: Can I use this with SharePoint On-Premises?**
A: No, this requires SharePoint Online (Microsoft 365).

---

## ✅ Checklist

Use this checklist to ensure everything is set up:

- [ ] SharePoint list created with all required columns
- [ ] Azure AD App Registration created
- [ ] Client ID and Tenant ID obtained
- [ ] API permissions configured and consented
- [ ] HTML file updated with IDs
- [ ] Application deployed (SharePoint/Azure/local)
- [ ] Redirect URI updated in Azure AD
- [ ] Successfully signed in
- [ ] Connection test passed
- [ ] Data loads correctly
- [ ] Test trainee added successfully
- [ ] Export functions work
- [ ] Team members can access

---

## 🎉 You're Done!

Your Training Progress Tracker is now fully integrated with the Microsoft ecosystem! 

Enjoy seamless collaboration, enterprise security, and powerful reporting capabilities.

For questions or issues, refer to the troubleshooting section or contact your IT department.

---

**Version**: 3.0 SharePoint Edition
**Last Updated**: October 2025
**Author**: Claude AI Assistant
