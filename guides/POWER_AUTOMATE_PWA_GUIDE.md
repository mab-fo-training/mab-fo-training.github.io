# Power Automate Restructure Guide — Parent/Child Pattern for PWA Integration

This guide walks through restructuring the existing "IOE Progress" Power Automate flow into a parent/child pattern, enabling both Microsoft Forms and the new PWA to trigger the same business logic.

## Overview

```
                    ┌─────────────────────┐
                    │   Child Flow        │
┌───────────┐       │ "IOE Progress -     │
│ Forms     │──────>│  Process Submission" │──── SharePoint Update + Emails
│ (Parent 1)│       │                     │
└───────────┘       │  Contains ALL       │
                    │  business logic     │
┌───────────┐       │                     │
│ PWA HTTP  │──────>│                     │
│ (Parent 2)│       └─────────────────────┘
└───────────┘
```

---

## Step 1: Create the Child Flow — "IOE Progress - Process Submission"

### 1.1 Create New Flow
1. Go to **Power Automate** > **My flows** > **+ New flow** > **Instant cloud flow**
2. Name: `IOE Progress - Process Submission`
3. Trigger: **Manually trigger a flow**
4. Click **Create**

### 1.2 Define Input Parameters
In the trigger, click **+ Add an input** for each:

| Name | Type | Required |
|------|------|----------|
| `submitterEmail` | Text | Yes |
| `traineeName` | Text | Yes |
| `staffNumber` | Text | Yes |
| `fleet` | Text | Yes |
| `totalSectors` | Number | Yes |
| `submissionDate` | Text | Yes |
| `progressionStage` | Text | Yes |
| `referralReasons` | Text | No |

### 1.3 Add SharePoint Lookup
1. Add action: **SharePoint - Get items**
   - Site Address: `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
   - List Name: `Training_Progress`
   - Filter Query: `Staff_ID eq '@{triggerBody()?['staffNumber']}'`
   - Top Count: `1`

### 1.4 Add "No Items Found" Condition
1. Add **Condition**: `length(outputs('Get_items')?['body/value'])` **is equal to** `0`
2. **If yes**: Send email to admin about invalid staff number, then **Terminate** (Status: Failed)
3. **If no**: Continue to Switch

### 1.5 Add Switch on Progression Stage
1. Add action: **Switch**
2. On: `triggerBody()?['progressionStage']`

#### Case: "Cleared Functional"
1. **SharePoint - Update item**:
   - ID: `first(outputs('Get_items')?['body/value'])?['ID']`
   - `Functional_Date`: `triggerBody()?['submissionDate']`
   - `Sectors_Flown`: `triggerBody()?['totalSectors']`
   - `Last_Updated`: `utcNow()`
2. **Send email** to submitter (acknowledgment)
   - To: `triggerBody()?['submitterEmail']`
   - Subject: `IOE Progress Update - @{triggerBody()?['traineeName']} - Cleared Functional`
3. **Send email** to APCT (notification)

#### Case: "Line Release Check COMPLETED"
1. **SharePoint - Update item**:
   - `LRC_Date`: `triggerBody()?['submissionDate']`
   - `Sectors_Flown`: `triggerBody()?['totalSectors']`
   - `Last_Updated`: `utcNow()`
2. 2 emails (same pattern as above)

#### Case: "Command Check COMPLETED"
1. **SharePoint - Update item**:
   - `Command_Check_Date`: `triggerBody()?['submissionDate']`
   - `Sectors_Flown`: `triggerBody()?['totalSectors']`
   - `Last_Updated`: `utcNow()`
2. 2 emails

#### Case: "Cleared for Line Release Check"
1. 2 notification emails only (no SharePoint update)

#### Case: "Cleared for Command Check"
1. 2 notification emails only

#### Case: "REFERRED TO SIP"
1. **Send email** to submitter (acknowledgment)
   - To: `triggerBody()?['submitterEmail']`
2. **Send email** to APCT (alert)
3. **Send email** to Capt Arian/Shazreen (referral details)
   - Include `triggerBody()?['referralReasons']` in body

#### Default
1. 2 notification emails

### 1.6 Save and Test
1. Save the flow
2. Click **Test** > **Manually** > fill in test inputs > Run
3. Verify emails arrive and SharePoint updates correctly

---

## Step 2: Modify Existing Forms Flow — "IOE Progress" (Parent 1)

### 2.1 Open the Existing Flow
1. Go to **My flows** > **IOE Progress** > **Edit**

### 2.2 Delete Business Logic
1. Keep only the first two actions:
   - **When a new response is submitted** (trigger)
   - **Get response details**
2. Delete everything else (Switch, emails, SharePoint updates)

### 2.3 Add Child Flow Call
1. Add action: **Run a Child Flow**
2. Select: `IOE Progress - Process Submission`
3. Map inputs:

| Child Input | Expression / Value |
|---|---|
| `submitterEmail` | `outputs('Get_response_details')?['responder']` |
| `traineeName` | NAME OF TRAINEE field (form field reference) |
| `staffNumber` | STAFF NUMBER field |
| `fleet` | FLEET field |
| `totalSectors` | TOTAL SECTORS field |
| `submissionDate` | DATE field |
| `progressionStage` | Progression Stage field |
| `referralReasons` | Referral Reason(s) field |

### 2.4 Save and Test
1. Save the flow
2. Submit a test entry via Microsoft Forms
3. Verify emails still arrive and SharePoint updates correctly
4. Compare behavior against the old flow — should be identical

---

## Step 3: Create HTTP Flow — "IOE Progress - PWA Submit" (Parent 2)

> **Note**: This flow uses the **HTTP Request** trigger, which requires a **Power Automate Premium** license.

### 3.1 Create New Flow
1. Go to **My flows** > **+ New flow** > **Automated cloud flow**
2. Name: `IOE Progress - PWA Submit`
3. Trigger: **When an HTTP request is received**
4. Click **Create**

### 3.2 Configure HTTP Trigger
Click **Use sample payload to generate schema** and paste:

```json
{
    "submitterEmail": "instructor@malaysiaairlines.com",
    "traineeName": "John Doe",
    "staffNumber": "12345",
    "fleet": "B738",
    "totalSectors": 25,
    "submissionDate": "2026-02-19",
    "progressionStage": "Cleared Functional",
    "referralReasons": ""
}
```

This generates the JSON schema automatically.

### 3.3 Add Child Flow Call
1. Add action: **Run a Child Flow**
2. Select: `IOE Progress - Process Submission`
3. Map inputs directly from `triggerBody()`:

| Child Input | Expression |
|---|---|
| `submitterEmail` | `triggerBody()?['submitterEmail']` |
| `traineeName` | `triggerBody()?['traineeName']` |
| `staffNumber` | `triggerBody()?['staffNumber']` |
| `fleet` | `triggerBody()?['fleet']` |
| `totalSectors` | `triggerBody()?['totalSectors']` |
| `submissionDate` | `triggerBody()?['submissionDate']` |
| `progressionStage` | `triggerBody()?['progressionStage']` |
| `referralReasons` | `triggerBody()?['referralReasons']` |

### 3.4 Add Response Action
1. Add action: **Response**
2. Status Code: `200`
3. Body: `{ "status": "success" }`
4. Headers: `Content-Type: application/json`

### 3.5 Save and Copy URL
1. **Save** the flow
2. The trigger will now show an **HTTP POST URL** — it looks like:
   ```
   https://prod-XX.australiasoutheast.logic.azure.com:443/workflows/...
   ```
3. **Copy this URL** — you need it for the PWA app

### 3.6 Update PWA App with URL
1. Open `docs/pwa/index.html`
2. Find the line:
   ```javascript
   const POWER_AUTOMATE_URL = '';
   ```
3. Paste the URL:
   ```javascript
   const POWER_AUTOMATE_URL = 'https://prod-XX.australiasoutheast.logic.azure.com:443/workflows/...';
   ```
4. Save, commit, and push to deploy

### 3.7 Test with Postman/curl
Before testing with the PWA, verify the flow works:

```bash
curl -X POST "YOUR_HTTP_TRIGGER_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "submitterEmail": "your.email@malaysiaairlines.com",
    "traineeName": "Test Trainee",
    "staffNumber": "12345",
    "fleet": "B738",
    "totalSectors": 10,
    "submissionDate": "2026-02-19",
    "progressionStage": "Cleared Functional",
    "referralReasons": ""
  }'
```

Expected response: `{ "status": "success" }`

---

## Step 4: Verification Checklist

### Forms Path (Parent 1 → Child)
- [ ] Submit via Microsoft Forms
- [ ] Verify form response is captured
- [ ] Verify child flow runs
- [ ] Verify SharePoint record updated
- [ ] Verify emails received

### PWA Path (Parent 2 → Child)
- [ ] POST JSON to HTTP trigger URL
- [ ] Verify child flow runs
- [ ] Verify SharePoint record updated
- [ ] Verify emails received (same as Forms path)

### PWA App
- [ ] Sign in with MSAL
- [ ] Look up trainee by Staff ID
- [ ] Fill form and submit
- [ ] Verify success screen
- [ ] Test on iPad Safari
- [ ] "Add to Home Screen" → verify standalone mode

### Edge Cases
- [ ] Invalid Staff ID → error in child flow → admin notified
- [ ] CUC batch → Command Check options visible
- [ ] CPC batch → Command Check options hidden
- [ ] REFERRED TO SIP → 3 emails sent (not 2)
- [ ] Network failure → error toast in PWA

---

## Troubleshooting

### "HTTP trigger URL not working"
- Ensure the flow is **turned on**
- Verify the URL was copied completely (they're very long)
- Check the flow run history for errors

### "Child flow not found"
- Both parent flows and child flow must be in the **same environment**
- The child flow must use the **"Manually trigger a flow"** trigger type

### "Emails not sending"
- Check the child flow run history — expand each action to see errors
- Verify email addresses are correct in the Send Email actions
- Check for Office 365 connector authorization issues

### "CORS error from PWA"
- Power Automate HTTP triggers handle CORS automatically — no configuration needed
- If you still see CORS errors, check the CSP meta tag in `index.html`
