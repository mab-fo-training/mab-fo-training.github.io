# Quick Start Guide - Training Progress Tracker Setup

**⏱️ Estimated Total Time: 2-3 hours** (1-2 days if waiting for IT approval)

---

## 🎯 What You're Setting Up

A web-based training tracker that uses:
- ✅ **Microsoft 365 sign-in** (supports Microsoft Authenticator automatically)
- ✅ **SharePoint Lists** for data storage
- ✅ **No servers required** - just upload a single HTML file

---

## 📊 Setup Process Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        SETUP WORKFLOW                            │
└─────────────────────────────────────────────────────────────────┘

WEEK 1: IT Request
├─ Day 1: Send email to IT (use IT_DEPARTMENT_REQUEST.md)
├─ Day 2-3: IT creates Azure AD App Registration
└─ Day 3: Receive Client ID and Tenant ID

WEEK 1-2: Your Configuration
├─ Create SharePoint lists (30 minutes)
├─ Update HTML file with IDs (5 minutes)
├─ Deploy file to SharePoint/Azure (15 minutes)
└─ Notify IT of deployment URL (5 minutes)

WEEK 2: Testing & Launch
├─ Test authentication (10 minutes)
├─ Test data entry (15 minutes)
├─ Invite 2-3 users to test (1 hour)
└─ Roll out to full team
```

---

## 🚀 4-Step Quick Start

### Step 1️⃣: Send IT Request (15 minutes)

**What to do:**
1. Open `IT_DEPARTMENT_REQUEST.md`
2. Fill in the [BRACKETED] sections:
   - [IT Contact Name]
   - [Your name/department/contact info]
   - [Number of users]
   - [Estimated deployment date]
3. Copy the full email or short version
4. Send to IT department

**What to expect:**
- IT will create Azure AD App Registration (usually 1-3 business days)
- They'll send you two IDs (Client ID and Tenant ID)
- They might ask clarifying questions - that's normal!

**Files needed:** `IT_DEPARTMENT_REQUEST.md`

---

### Step 2️⃣: Create SharePoint Lists (30 minutes)

**While waiting for IT, set up your SharePoint lists:**

#### Main List: Training_Progress

1. Go to your SharePoint site
2. Click **Site contents** → **+ New** → **List**
3. Name: `Training_Progress`
4. Add these 13 columns:

| # | Column Name | Type | Details |
|---|-------------|------|---------|
| 1 | Batch | Single line of text | - |
| 2 | Staff_ID | Single line of text | Required ✓ |
| 3 | Rank | Choice | FO, SFO, CAPT |
| 4 | Name | Single line of text | Required ✓ |
| 5 | First_IOE_Date | Date | No time |
| 6 | Functional_Date | Date | No time |
| 7 | LRC_Date | Date | No time |
| 8 | Interview_Date | Date | No time |
| 9 | Sectors_Flown | Number | 0 decimals |
| 10 | Status | Single line of text | - |
| 11 | Remarks | Multiple lines | Plain text |
| 12 | Last_Updated | Date and time | With time ✓ |
| 13 | Manual_Highlight | Choice | blue, green, red |

**⚠️ Important:** Column names must match exactly (including underscores and capitals)!

#### Admin List: AdminUsers (Optional, 5 minutes)

1. Create another list: `AdminUsers`
2. Add two columns:
   - **Email** (Single line of text)
   - **Password** (Single line of text)
3. Add your admin emails to the list

**Save your SharePoint site URL:**
```
Example: https://yourcompany.sharepoint.com/sites/FlightTraining
Your URL: _______________________________________________
```

---

### Step 3️⃣: Configure & Deploy (20 minutes)

**Once IT sends you the Client ID and Tenant ID:**

#### A. Update HTML File (5 minutes)

1. Open `index-sharepoint-v3-enhanced.html` in Notepad/VS Code
2. Press `Ctrl+F` and search for: `YOUR_CLIENT_ID_HERE`
3. You'll find line 867-868:

```javascript
clientId: 'YOUR_CLIENT_ID_HERE',
authority: 'https://login.microsoftonline.com/YOUR_TENANT_ID_HERE',
```

4. Replace with actual IDs:

```javascript
clientId: 'a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6',
authority: 'https://login.microsoftonline.com/z9y8x7w6-v5u4-t3s2-r1q0-p9o8n7m6l5k4',
```

5. Save the file (`Ctrl+S`)

#### B. Deploy to SharePoint (15 minutes)

**Recommended: Upload to SharePoint**

1. Go to your SharePoint site
2. Click **Documents** (or create a new library)
3. Click **Upload** → **Files**
4. Select `index-sharepoint-v3-enhanced.html`
5. After upload, right-click the file → **Copy link**
6. Your deployment URL looks like:
   ```
   https://yourcompany.sharepoint.com/sites/FlightTraining/Shared%20Documents/index-sharepoint-v3-enhanced.html
   ```

**Alternative: Local Testing (Development Only)**

1. Open Command Prompt or Terminal
2. Navigate to folder: `cd "C:\Users\shazreen\Desktop\Microsoft Training Tracker"`
3. Run: `python -m http.server 8000`
4. Open browser: `http://localhost:8000/index-sharepoint-v3-enhanced.html`
5. URL: `http://localhost:8000`

#### C. Update IT with Deployment URL (5 minutes)

Send this email to IT:

```
Subject: RE: Azure AD App Registration - Deployment URL Update

Hi [IT Contact],

The application is now deployed at:

[YOUR DEPLOYMENT URL]

Could you please update the Redirect URI in the Azure AD App
Registration to this URL?

Thanks!
[Your Name]
```

---

### Step 4️⃣: First Login & Configuration (10 minutes)

**After IT updates the redirect URI:**

1. **Open your deployment URL** in browser

2. **Configure SharePoint Connection:**
   - In the configuration section, enter:
     - **SharePoint Site URL:** `https://yourcompany.sharepoint.com/sites/FlightTraining`
     - **List Name:** `Training_Progress`
   - Click **💾 Save Configuration**

3. **Sign In:**
   - Click **🔐 Sign in with Microsoft**
   - Microsoft login page opens
   - Enter your work email and password
   - **If Microsoft Authenticator is set up:**
     - You'll get a push notification on your phone
     - Approve the sign-in
   - **If MFA is required:**
     - Complete the additional authentication step
   - Accept permissions (first time only)

4. **Test Connection:**
   - Click **🔌 Test Connection**
   - You should see "✅ Connected"
   - Your name should appear in the top right corner

5. **Load Data:**
   - Click **🔄 Refresh from SharePoint**
   - Table will load (empty if new)

6. **Add Test Trainee:**
   - Click **➕ Add Trainee**
   - Fill in test data
   - Click **💾 Save to SharePoint**
   - Verify trainee appears in table
   - Check SharePoint list to confirm data saved

**✅ If all steps work, you're done!**

---

## 📱 Microsoft Authenticator - How It Works

**Good News:** Microsoft Authenticator works automatically with your setup. No special configuration needed!

### For Users:

**If Authenticator is already set up:**
- Sign in with work email
- Get notification on phone
- Tap "Approve"
- Signed in! ✅

**If Authenticator is NOT set up:**
- User can set it up anytime via: https://aka.ms/mysecurityinfo
- Or IT can provide setup instructions
- Once set up, all future sign-ins can use phone approval

**If IT enforces MFA:**
- All users will be prompted to set up Authenticator (or SMS/call)
- This happens automatically during first sign-in
- No configuration needed from your side

### Security Features:
- ✅ Passwordless sign-in (if enabled by IT)
- ✅ Number matching for extra security
- ✅ Biometric approval (Face ID, fingerprint)
- ✅ Works offline (generates codes)

---

## 🎓 Using the Application

### User Portal (Cadet View)

**For trainees to update their own progress:**

1. Click **👤 Cadet View**
2. Enter your Staff ID
3. First time: Select your rank (FO, SFO, CAPT)
4. Update dates and sectors flown
5. Click **💾 Save**
6. View your analytics and progress charts

### Admin Panel

**For administrators to manage all trainees:**

1. Click **🔐 Admin**
2. Sign in with admin credentials
3. Use filters and search to find trainees
4. Add/edit/delete trainees
5. View analytics dashboard
6. Export to Excel or Power BI

---

## 📞 Common Questions

**Q: Do I need to install anything?**
A: No! It's a web application. Just open the URL in your browser.

**Q: Does it work on mobile?**
A: Yes, it's mobile-responsive and works on phones/tablets.

**Q: Can multiple people use it at once?**
A: Yes! Data is stored in SharePoint, supports concurrent users.

**Q: What if I forget to sign out?**
A: The session is secure. Tokens expire automatically after a period of inactivity.

**Q: Can users access it from home?**
A: Yes, as long as they have Microsoft 365 access and internet connection.

**Q: What browsers are supported?**
A: Chrome, Edge, Firefox, Safari (modern versions).

**Q: Is our data secure?**
A: Yes! Uses Microsoft 365 enterprise security, encryption, and audit trails.

**Q: Can IT see who accesses what?**
A: Yes, SharePoint maintains access logs and version history.

---

## 🆘 Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| **Can't sign in** | Clear browser cache, try incognito mode, verify redirect URI with IT |
| **"Configuration not saved"** | Check browser console (F12), ensure localStorage is enabled |
| **SharePoint connection failed** | Verify site URL is correct, check you have site access |
| **List not found** | Confirm list name is exactly `Training_Progress` (case-sensitive) |
| **Data not saving** | Check internet connection, verify SharePoint permissions |
| **Charts not showing** | Refresh page, check browser console for errors |
| **Export doesn't work** | Ensure pop-ups are not blocked, try different browser |

**Still stuck?** Check the full troubleshooting guide in `DEPLOYMENT_CHECKLIST.md`

---

## 📚 Reference Documents

In your folder: `C:\Users\shazreen\Desktop\Microsoft Training Tracker\`

| File | Purpose | When to Use |
|------|---------|-------------|
| **IT_DEPARTMENT_REQUEST.md** | Email template for IT | Step 1 - Send to IT |
| **DEPLOYMENT_CHECKLIST.md** | Detailed step-by-step checklist | Throughout setup |
| **SETUP_GUIDE.md** | Complete technical setup guide | Reference during setup |
| **QUICK_REFERENCE.md** | End-user guide | Share with team after launch |
| **TEST_MODE_GUIDE.md** | Offline testing mode | Development/testing |
| **CLAUDE.md** | Developer documentation | For customizations |

---

## ✅ Final Checklist

Before launching to users:

- [ ] IT provided Client ID and Tenant ID
- [ ] SharePoint lists created (`Training_Progress` + optional `AdminUsers`)
- [ ] HTML file updated with IDs
- [ ] File deployed to SharePoint/Azure
- [ ] IT updated redirect URI
- [ ] Successful test sign-in
- [ ] Test connection shows "✅ Connected"
- [ ] Test trainee added and appears in SharePoint
- [ ] Test with 2-3 users successful
- [ ] User guide shared with team

---

## 🎉 Ready to Launch!

**Share these with your team:**
- 🔗 **Deployment URL:** `[Your SharePoint/Azure URL]`
- 📖 **User Guide:** `QUICK_REFERENCE.md`
- 🆘 **Support Contact:** [Your email/Teams channel]

**For admins:**
- 🔐 Add admin emails to `AdminUsers` SharePoint list
- 📊 Review analytics dashboard
- 📥 Set up weekly Excel export backup

---

**Questions or Issues?**
- Check `DEPLOYMENT_CHECKLIST.md` for detailed troubleshooting
- Contact IT if authentication issues persist
- Review `SETUP_GUIDE.md` for technical details

**Need Customizations?**
- See `CLAUDE.md` for code structure and modification guides
- All code is in a single HTML file for easy editing

---

**Good luck with your deployment! 🚀**
