Subject: Request: Enable HTML Rendering on New SharePoint Site - IOE Training Tracker

Hi Team,

I wanted to provide a quick update on the IOE Training Progress Tracker project and request a small configuration change.

**Change of Approach**

After reviewing the Azure Function App approach we previously discussed, we've decided to simplify the architecture. Instead of building a backend proxy with Azure Functions (which required Function App creation, certificate management, and ongoing maintenance), we've pivoted to a simpler solution:

- **Created a dedicated Communication Site**: https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker
- **Purpose**: This site serves solely as the data backend and hosting platform for the Training Progress Tracker app
- **Why a separate site**: Rather than using the shared FLTOPS-TRAINING site, a dedicated site gives us full control over permissions and keeps training tracker data isolated
- **Access model**: Using "Everyone except external users" as site members with delegated authentication (MSAL) — no app-only auth or Azure Function needed
- **Result**: The existing Azure AD app registration (Client ID: 82a4ec5a-d90d-4957-8021-3093e60a4d70) works as-is with delegated permissions. No additional API permissions or backend infrastructure required.

This approach eliminates the need for the Azure Function App we previously requested. Thank you for your help with the permissions work — the delegated permissions you granted are exactly what we're using.

**Request**

We need one SharePoint configuration change to allow the HTML-based tracker app to render directly in the browser when hosted in the site's document library. Currently SharePoint opens the file in preview mode instead of executing it.

Could you please run the following PowerShell command:

```powershell
Set-SPOSite -Identity "https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker" -DenyAddAndCustomizePages 0
```

This enables HTML files to render in the browser on this specific site only. It does not affect any other sites.

**Context**:
- The tracker is a single-page HTML application (no server-side code)
- It uses MSAL.js for Microsoft 365 authentication and SharePoint REST API for data storage
- The file is uploaded to the site's document library
- Without this setting, SharePoint shows an HTML preview instead of rendering the app

Thank you for your help. Please let me know if you have any questions.

Best regards,
Shazreen
