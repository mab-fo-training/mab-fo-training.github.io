# Power Automate Flow Guide: Trainer Submission → SharePoint Update

This guide walks you through building a Power Automate flow that automatically updates the `Training_Progress` SharePoint list when a trainer submits the Microsoft Forms form.

## Prerequisites

- Access to [Power Automate](https://make.powerautomate.com)
- Owner/Member access to the SharePoint site: `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
- The Microsoft Forms form is already created: `https://forms.office.com/r/aBkYkEMw1f`

## Form Fields Reference

| # | Field | Type | Example |
|---|-------|------|---------|
| 1 | NAME OF TRAINEE | Text | JOHN DOE |
| 2 | STAFF NUMBER | Text | 123456 |
| 3 | FLEET | Choice: A350, A333, B737 | B737 |
| 4 | TOTAL SECTORS | Number | 45 |
| 5 | DATE | Date (M/d/yyyy) | 2/9/2026 |
| 6 | Progression Stage | Choice | Cleared Functional |

## Step-by-Step Instructions

### Step 1: Create the Flow

1. Go to [Power Automate](https://make.powerautomate.com)
2. Click **Create** → **Automated cloud flow**
3. Name: `Training Form → SharePoint Update`
4. Trigger: **When a new response is submitted** (Microsoft Forms)
5. Select your form from the dropdown
6. Click **Create**

### Step 2: Get Form Response Details

1. Add action: **Get response details** (Microsoft Forms)
2. **Form Id**: Select the same form
3. **Response Id**: Select `Response Id` from dynamic content (from the trigger)

### Step 3: Look Up the Trainee in SharePoint

1. Add action: **Get items** (SharePoint)
2. **Site Address**: `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
3. **List Name**: `Training_Progress`
4. **Filter Query** (ODATA):
   ```
   Staff_ID eq '@{outputs('Get_response_details')?['body/r2']}'
   ```
   (Where `r2` is the STAFF NUMBER field — verify the field ID in your form)

### Step 4: Check if Trainee Exists

1. Add a **Condition** action
2. Set condition: `length(body('Get_items')?['value'])` **is greater than** `0`

### Step 5: If Yes — Update the Trainee Record

Inside the **If yes** branch:

#### 5a. Initialize Variables

Add these **Initialize variable** actions (place them *before* the Condition, at the flow's top level — variables cannot be initialized inside conditions):

| Variable | Type | Value |
|----------|------|-------|
| `ItemID` | Integer | 0 |
| `CurrentRemarks` | String | (empty) |

Then inside the **If yes** branch:

1. Add **Set variable** `ItemID`:
   ```
   first(body('Get_items')?['value'])?['Id']
   ```

2. Add **Set variable** `CurrentRemarks`:
   ```
   first(body('Get_items')?['value'])?['Remarks']
   ```

#### 5b. Switch on Progression Stage

1. Add a **Switch** action
2. **On**: Select the Progression Stage response field

Create these cases:

---

**Case: "Cleared Functional"**

Action: **Update item** (SharePoint)
- Site Address: `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
- List Name: `Training_Progress`
- Id: `@{variables('ItemID')}`
- Fields to set:
  - `Functional_Date`: `@{outputs('Get_response_details')?['body/r5']}` (the DATE field)
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}` (TOTAL SECTORS)
  - `Last_Updated`: `@{utcNow()}`

---

**Case: "Line Release Check COMPLETED"**

Action: **Update item** (SharePoint)
- Same site/list/Id as above
- Fields:
  - `LRC_Date`: `@{outputs('Get_response_details')?['body/r5']}`
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}`
  - `Last_Updated`: `@{utcNow()}`

---

**Case: "Command Check COMPLETED"**

Action: **Update item** (SharePoint)
- Same site/list/Id
- Fields:
  - `Command_Check_Date`: `@{outputs('Get_response_details')?['body/r5']}`
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}`
  - `Last_Updated`: `@{utcNow()}`

---

**Case: "Cleared for Line Release Check"**

Action: **Update item** (SharePoint)
- Same site/list/Id
- Fields:
  - `Remarks`: Expression:
    ```
    concat(variables('CurrentRemarks'), if(empty(variables('CurrentRemarks')), '', '; '), 'Cleared for LRC - ', outputs('Get_response_details')?['body/r5'])
    ```
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}`
  - `Last_Updated`: `@{utcNow()}`

---

**Case: "Cleared for Command Check"**

Action: **Update item** (SharePoint)
- Same site/list/Id
- Fields:
  - `Remarks`: Expression:
    ```
    concat(variables('CurrentRemarks'), if(empty(variables('CurrentRemarks')), '', '; '), 'Cleared for Command Check - ', outputs('Get_response_details')?['body/r5'])
    ```
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}`
  - `Last_Updated`: `@{utcNow()}`

---

**Case: "REFERRED TO SIP"**

Action: **Update item** (SharePoint)
- Same site/list/Id
- Fields:
  - `Manual_Highlight`: `red`
  - `Remarks`: Expression:
    ```
    concat(variables('CurrentRemarks'), if(empty(variables('CurrentRemarks')), '', '; '), 'Referred to SIP - ', outputs('Get_response_details')?['body/r5'])
    ```
  - `Sectors_Flown`: `@{outputs('Get_response_details')?['body/r4']}`
  - `Last_Updated`: `@{utcNow()}`

> **Note (2026-04):** The tracker's User Portal now auto-detects the SIP flag via the `[REFERRED TO SIP - DD/MM/YYYY]` token in `Remarks`. If you prefer the token-based format (so the Trainee Alert modal displays the date), replace the Remarks expression above with:
> ```
> concat(if(empty(first(outputs('Get_items')?['body/value'])?['Remarks']), '', concat(first(outputs('Get_items')?['body/value'])?['Remarks'], ' ')), '[REFERRED TO SIP - ', formatDateTime(utcNow(), 'dd/MM/yyyy'), ']')
> ```

### Trainee Alert & Planner Task (2026-04)

The REFERRED TO SIP case is extended with a Planner task so the APCT team has a trackable to-do list. Add these two actions **immediately after** the Update item action in the `REFERRED TO SIP` switch case (same order shown below).

**Action: Create a task (Planner)**
- **Group Id:** Select the M365 group that owns the existing SIP Planner plan (dropdown)
- **Plan Id:** Select the existing SIP plan by name (dropdown)
- **Bucket Id:** Select the appropriate bucket (e.g., "New Referrals")
- **Title:**
  ```
  SIP Referral: @{outputs('Get_response_details')?['body/r13aa5d088a6d46748fbbd853740d279c']} (@{outputs('Get_response_details')?['body/<STAFF_ID_FIELD_ID>']})
  ```
  - Replace `<STAFF_ID_FIELD_ID>` with the STAFF NUMBER form field ID.
- **Assigned User Ids:** *(leave empty — unassigned, anyone on the team can pick it up)*
- **Due Date:** *(leave empty — no due date per requirement)*

**Action: Update task details (Planner)**
Runs on the task ID returned by the previous action.
- **Task Id:** `@{outputs('Create_a_task')?['body/id']}`
- **Description:**
  ```
  Trainee: @{outputs('Get_response_details')?['body/r13aa5d088a6d46748fbbd853740d279c']}
  Staff ID: @{outputs('Get_response_details')?['body/<STAFF_ID_FIELD_ID>']}
  Fleet: @{outputs('Get_response_details')?['body/<FLEET_FIELD_ID>']}
  Date submitted: @{outputs('Get_response_details')?['body/<DATE_FIELD_ID>']}
  Submitted by: @{triggerOutputs()?['body/responder']}
  Referral Reason(s):
  @{outputs('Get_response_details')?['body/r02e9c5a816524d259d5703b5e1e05f36']}
  ```
  All placeholders `<..._FIELD_ID>` are filled from the form field ID table below (or via dynamic content picker in the Power Automate UI).
- **Checklist:** Add four checklist items (title + isChecked = false each):
  1. `Contact trainee`
  2. `Schedule SIP session`
  3. `Conduct SIP review`
  4. `Document outcome in Training Tracker`

**Notes:**
- No due date is set.
- The title is kept human-readable so the Planner board is scannable at a glance.
- The Planner task is not linked back to SharePoint. Admins clear referrals by editing the trainee in the Admin panel (setting `Manual Highlight` → `None`) and marking the Planner task complete separately.
- When the admin clears `Manual_Highlight`, the User Portal modal will no longer appear for that trainee on their next sign-in.

---

### Step 6: If No — Send Notification

Inside the **If no** branch:

1. Add action: **Send an email (V2)** (Office 365 Outlook)
2. **To**: Your admin email (e.g., `mohamadshazreen.sazali@malaysiaairlines.com`)
3. **Subject**: `Training Form: Unknown Staff ID submitted`
4. **Body**:
   ```
   A trainer submitted a form for a trainee not found in the Training_Progress list.

   Name: [NAME OF TRAINEE field]
   Staff Number: [STAFF NUMBER field]
   Progression Stage: [Progression Stage field]

   Please add this trainee to the tracker first, then resubmit.
   ```

### Step 7: Save and Test

1. Click **Save**
2. Submit a test entry via the Microsoft Forms form
3. Verify:
   - The SharePoint list item is updated correctly
   - The correct date field is populated
   - Sectors_Flown is updated
   - Last_Updated timestamp is set
   - For "Cleared for..." stages, remarks are appended
   - For "REFERRED TO SIP", the Manual_Highlight is set to "red"

## Flow Diagram

```
Form Submitted
    ↓
Get Response Details
    ↓
Get Items (filter by Staff_ID)
    ↓
Condition: Trainee exists?
    ├── Yes → Switch on Progression Stage
    │         ├── Cleared Functional → Update Functional_Date
    │         ├── LRC COMPLETED → Update LRC_Date
    │         ├── Command Check COMPLETED → Update Command_Check_Date
    │         ├── Cleared for LRC → Append to Remarks
    │         ├── Cleared for Command Check → Append to Remarks
    │         └── REFERRED TO SIP → Set red highlight + Append Remarks
    │
    └── No → Send email notification
```

## Field ID Reference

The form field IDs (r1, r2, etc.) may differ in your form. To find the correct IDs:

1. In Power Automate, add the **Get response details** action
2. Click **Add dynamic content**
3. The field names shown correspond to the form questions
4. Use the dynamic content picker instead of typing field IDs manually

## Troubleshooting

- **Flow not triggering**: Ensure the form is owned by your account (not shared)
- **Staff ID not found**: Check that Staff_ID values match exactly (case, spaces, leading zeros)
- **Update fails**: Verify the SharePoint column names match exactly (case-sensitive internal names)
- **Date format issues**: The DATE field from Forms is M/d/yyyy; SharePoint date columns accept this format
- **Remarks too long**: SharePoint "Multiple lines of text" supports up to 63,999 characters — not a concern in practice
