# Email to IT

**Subject:** Follow-up: Training Tracker App - Need Delegated Permission Instead of Sites.Selected

---

Hi Team,

Thank you for running the PowerShell script to grant site permission. Unfortunately, we're still getting a 403 error, and after investigation, I've identified the root cause.

## Why Sites.Selected Isn't Working

`Sites.Selected` is an **Application permission** designed for daemon/service applications that run without user interaction (e.g., background jobs, scheduled tasks). These apps authenticate using client credentials (client ID + secret), not user sign-in.

Our Training Tracker app uses **interactive user sign-in** (MSAL popup authentication) because:
- Users need to be identified for audit/accountability
- Different users may have different access levels in future
- It's a web application used by staff, not a background service

When a user signs in, only **Delegated permissions** apply. The site-level grant via `New-MgSitePermission` only works for application-only authentication, which is why we're still blocked.

## Requested Action

Please add a **Delegated** permission to the app and grant admin consent:

1. Azure Portal → Azure Active Directory → App Registrations
2. Find: **Training Tracker SharePoint App** (ID: `82a4ec5a-d90d-4957-8021-3093e60a4d70`)
3. Go to **API Permissions**
4. Click **Add a permission** → Microsoft Graph → **Delegated permissions**
5. Search and select: `Sites.ReadWrite.All`
6. Click **Add permissions**
7. Click **Grant admin consent for [tenant]**

## Security Considerations & Mitigations

I understand IT preferred `Sites.Selected` for its restrictive scope. Here's how we're mitigating risk with `Sites.ReadWrite.All`:

| Concern | Mitigation |
|---------|------------|
| **Broader access than needed** | App code only accesses FLTOPS-TRAINING site and Training_Progress list - hardcoded in configuration |
| **User could access other sites** | Access is limited by user's own SharePoint permissions (users can only access sites they already have permission to) |
| **Data exposure risk** | App only reads/writes training records; no sensitive data traversal |
| **Audit trail** | All actions tied to signed-in user identity via Azure AD logs |
| **App distribution** | Internal use only, not published to app store |

Additionally:
- The app is a single-purpose training tracker, not a general SharePoint browser
- We can implement Conditional Access policies if needed
- Azure AD sign-in logs provide full audit trail of app usage

## Summary

| Item | Value |
|------|-------|
| App Name | Training Tracker SharePoint App |
| App ID | `82a4ec5a-d90d-4957-8021-3093e60a4d70` |
| Permission Needed | `Sites.ReadWrite.All` (Delegated) |
| Action | Add permission + Grant admin consent |

Please let me know if you have any questions or concerns. Happy to discuss further or implement additional controls if required.

Thank you for your support.

Shazreen
