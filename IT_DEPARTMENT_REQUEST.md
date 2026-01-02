# Email Template for IT Department

Copy and paste the email below. Fill in the [BRACKETED] sections with your information.

---

**Subject:** Request: Azure AD App Registration for Training Progress Tracker

---

Hi [IT Contact Name / IT Team],

I hope this email finds you well. I'm requesting assistance to set up an Azure AD App Registration for our **Training Progress Tracker** application. This is an internal web application for managing flight training progress that will use Microsoft 365 authentication and SharePoint Lists for data storage.

---

## Application Overview

**Application Name:** Training Progress Tracker
**Purpose:** Internal tool for tracking trainee progress (IOE dates, functional dates, sectors flown, etc.)
**Users:** [Specify: e.g., "Flight Training Department - approximately 20 users"]
**Data Storage:** SharePoint Lists (existing data permissions apply)
**Authentication:** Microsoft 365 Single Sign-On (supports Microsoft Authenticator)
**Deployment:** [Choose one: SharePoint Document Library / Azure Static Web Apps / Microsoft Teams]

---

## Required Setup Steps

### 1️⃣ Create Azure AD App Registration

**Location:** [Azure Portal](https://portal.azure.com) → Azure Active Directory → App registrations

**Configuration:**
- Click **+ New registration**
- **Name:** `Training Progress Tracker`
- **Supported account types:** **Accounts in this organizational directory only (Single tenant)**
- **Redirect URI:**
  - Platform: **Web**
  - URL: `[PENDING - I will provide once deployed]`

  *(Note: I will confirm the deployment URL shortly. For initial testing, you can use: `http://localhost:8000`)*

---

### 2️⃣ Configure API Permissions

**Location:** App registration → API permissions

**Required Permissions (Microsoft Graph - Delegated):**
1. `User.Read` - Read user profile information
2. `Sites.ReadWrite.All` - Read and write to SharePoint lists

**Important:** Please click **"Grant admin consent for [Organization Name]"** after adding permissions.

**Security Note:** These permissions only allow users to access SharePoint data they already have permissions to view/edit. No additional access is granted.

---

### 3️⃣ Enable Authentication Tokens

**Location:** App registration → Authentication

**Configure Implicit Grant Flow:**
- Under **Implicit grant and hybrid flows**, enable:
  - ✅ **Access tokens (used for implicit flows)**
  - ✅ **ID tokens (used for implicit and hybrid flows)**
- Click **Save**

**Advanced Settings:**
- **Allow public client flows:** No

---

### 4️⃣ Provide Credentials

Once setup is complete, please provide the following:

- ✅ **Application (client) ID:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- ✅ **Directory (tenant) ID:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

You can find these on the **Overview** page of the app registration.

---

## Additional Information

### Security & Compliance
- Application uses Microsoft Authentication Library (MSAL.js) - Microsoft's official authentication library
- Supports MFA and Microsoft Authenticator automatically
- Adheres to existing Conditional Access policies
- All data stored in SharePoint with standard Microsoft 365 security
- Audit trail maintained via SharePoint version history

### Deployment Timeline
- **Estimated deployment date:** [Your date]
- **Update redirect URI:** I will notify you of the final deployment URL within [X days/weeks]

### SharePoint Lists Required
I will create two SharePoint lists in our site:
1. `Training_Progress` - Main data storage
2. `AdminUsers` - Admin access control (optional)

No special SharePoint permissions required beyond standard site member access.

---

## Questions or Concerns?

If you have any questions about this request or need additional information, please let me know. I'm available at [your email] or [your phone number].

If there are any security concerns or alternative authentication methods you'd prefer, I'm happy to discuss.

---

## Summary Checklist

To summarize, I'm requesting:

- [ ] Azure AD App Registration created with name: `Training Progress Tracker`
- [ ] API permissions configured: `User.Read`, `Sites.ReadWrite.All`
- [ ] Admin consent granted for the organization
- [ ] Implicit grant tokens enabled (Access tokens + ID tokens)
- [ ] Application (client) ID provided
- [ ] Directory (tenant) ID provided
- [ ] Redirect URI updated once I provide deployment URL

---

Thank you for your assistance with this request. I appreciate your help in enabling this tool for our team.

Best regards,
[Your Name]
[Your Position]
[Your Department]
[Your Contact Information]

---

# Alternative: Short Version Email

If your IT team prefers shorter requests, use this version instead:

---

**Subject:** Azure AD App Registration Request - Training Progress Tracker

Hi [IT Team],

I need an Azure AD App Registration for our Training Progress Tracker application.

**Quick Details:**
- **App Name:** Training Progress Tracker
- **Purpose:** Internal flight training progress tracking
- **Users:** [Number] staff members
- **Authentication:** Microsoft 365 SSO
- **Data:** SharePoint Lists

**Required Configuration:**

1. **App Registration:**
   - Supported accounts: Single tenant
   - Redirect URI: Web - `http://localhost:8000` (I'll update with production URL)

2. **API Permissions (Microsoft Graph - Delegated):**
   - User.Read
   - Sites.ReadWrite.All
   - **Please grant admin consent**

3. **Authentication:**
   - Enable: Access tokens + ID tokens (implicit flow)

4. **Please provide:**
   - Application (client) ID
   - Directory (tenant) ID

**Security:** Uses MSAL.js, supports MFA/Authenticator, follows existing Conditional Access policies. Users access only SharePoint data they already have permissions for.

Let me know if you need any additional information. Thanks!

[Your Name]
[Contact Info]

---

# After You Receive the Credentials

Once IT provides the Client ID and Tenant ID, reply with:

---

**Subject:** RE: Azure AD App Registration - Deployment URL Update

Hi [IT Contact],

Thank you for setting up the app registration. The application is now deployed at:

**Production URL:** `[YOUR_DEPLOYMENT_URL]`

Could you please update the Redirect URI in the Azure AD App Registration to:
- **Redirect URI:** `[YOUR_DEPLOYMENT_URL]`

If you're using SharePoint, it might look like:
`https://yourcompany.sharepoint.com/sites/FlightTraining/SiteAssets/index-sharepoint-v3-enhanced.html`

Or for Azure Static Web Apps:
`https://your-app.azurestaticapps.net`

Thanks again for your help!

[Your Name]

---
