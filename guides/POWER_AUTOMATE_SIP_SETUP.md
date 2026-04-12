# Power Automate Setup — SIP Referral Auto-Highlight & Planner Task

Step-by-step guide to add the Update item, Create Planner task, and Update task details actions to the existing `IOE Progress` flow.

---

## Prerequisites

Gather these before starting:

1. **Microsoft 365 Group ID** that owns the SIP Planner plan
2. **Planner Plan ID** (the existing SIP plan)
3. **Bucket ID** inside that plan (e.g., "New Referrals")
4. **STAFF NUMBER form field ID** — find via a previous flow run's `Get response details` outputs
5. **FLEET form field ID** and **DATE form field ID** (same method)

> Tip: Temporarily add a "List buckets" action in Power Automate, run the flow once, copy the IDs from the output, then delete the action.

---

## Step 1 — Open the Flow

1. Go to https://make.powerautomate.com
2. Sign in with your Microsoft Airlines account
3. Click **My flows** in the left sidebar
4. Find **IOE Progress** and click it
5. Click **Edit** (pencil icon)

---

## Step 2 — Navigate to the REFERRED TO SIP Switch Case

1. Expand the flow to the **Switch on Progression Stage** block
2. Find the case labeled **REFERRED TO SIP**
3. Expand it — you should see the existing 3 email actions

---

## Step 3 — Update the "Update item" Remarks Expression

This makes the remark match the format the User Portal modal looks for (`[REFERRED TO SIP - DD/MM/YYYY]`).

1. Find the existing **Update item** action in the REFERRED TO SIP case. If there is none, add one:
   - Click **+ New step** → search "Update item" → select **SharePoint → Update item**
2. Fill in:
   - **Site Address:** `https://mabitdept.sharepoint.com/sites/FlightOpsIOETrainingTracker`
   - **List Name:** `Training_Progress`
   - **Id:** Expression tab → paste:
     ```
     first(outputs('Get_items')?['body/value'])?['ID']
     ```
   - **Title:** (required by SharePoint) Expression tab:
     ```
     first(outputs('Get_items')?['body/value'])?['Title']
     ```
3. Click **Show advanced options**
4. Set:
   - **Manual_Highlight Value:** `red`
   - **Remarks:** Expression tab → paste:
     ```
     concat(if(empty(first(outputs('Get_items')?['body/value'])?['Remarks']), '', concat(first(outputs('Get_items')?['body/value'])?['Remarks'], ' ')), '[REFERRED TO SIP - ', formatDateTime(utcNow(), 'dd/MM/yyyy'), ']')
     ```
   - **Last_Updated:** Expression → `utcNow()`

---

## Step 4 — Add "Create a task" (Planner)

1. Below the Update item action, click **+ New step**
2. Search **Planner** → select **Create a task**
3. Fill in:

   | Field | Value |
   |---|---|
   | **Group Id** | Dropdown → pick the M365 group that owns the SIP plan |
   | **Plan Id** | Dropdown → pick your SIP plan |
   | **Bucket Id** | Dropdown → pick "New Referrals" (or your preferred bucket) |
   | **Title** | See below |
   | **Assigned User Ids** | *(leave empty)* |
   | **Start Date Time** | *(leave empty)* |
   | **Due Date Time** | *(leave empty)* |

4. For **Title**, use Dynamic content:
   - Type: `SIP Referral: `
   - Insert **NAME OF TRAINEE** from dynamic content
   - Type: ` (`
   - Insert **STAFF NUMBER** from dynamic content
   - Type: `)`
   - Result: `SIP Referral: [NAME OF TRAINEE] ([STAFF NUMBER])`

---

## Step 5 — Add "Update task details" (Planner)

Must come **directly after** Create task — it uses the returned task ID.

1. Click **+ New step** → search **Planner** → select **Update task details**
2. Fill in:
   - **Group Id:** same group as Create task
   - **Task Id:** Dynamic content → under *Create a task* → select **Id**

3. **Description:** Compose with literals + dynamic content (press Enter for line breaks):
   ```
   Trainee: [dynamic: NAME OF TRAINEE]
   Staff ID: [dynamic: STAFF NUMBER]
   Fleet: [dynamic: FLEET]
   Date submitted: [dynamic: DATE]
   Submitted by: [dynamic: Responders' Email]
   Referral Reason(s):
   [dynamic: Referral Reason(s)]
   ```
   > Each `[dynamic: xxx]` is a blue token from the Dynamic content panel.

4. **Checklist:** Click **Show advanced options** → find **Checklist**
   - Add 4 items (all with Is Checked = `false`):
     1. `Contact trainee`
     2. `Schedule SIP session`
     3. `Conduct SIP review`
     4. `Document outcome in Training Tracker`

   > If the UI shows a single JSON field instead of a repeatable form, paste:
   > ```json
   > {
   >   "item1": { "@odata.type": "#microsoft.graph.plannerChecklistItem", "title": "Contact trainee", "isChecked": false },
   >   "item2": { "@odata.type": "#microsoft.graph.plannerChecklistItem", "title": "Schedule SIP session", "isChecked": false },
   >   "item3": { "@odata.type": "#microsoft.graph.plannerChecklistItem", "title": "Conduct SIP review", "isChecked": false },
   >   "item4": { "@odata.type": "#microsoft.graph.plannerChecklistItem", "title": "Document outcome in Training Tracker", "isChecked": false }
   > }
   > ```

---

## Step 6 — Save the Flow

1. Click **Save** at the top-right
2. Wait for "Your flow has been saved"
3. Fix any red exclamation marks on actions

---

## Step 7 — Test

1. Open the form: https://forms.office.com/r/aBkYkEMw1f
2. Submit a test entry with **Progression Stage = "REFERRED TO SIP"**
3. In Power Automate → **Run history** → click the latest run → all green ticks
4. Verify:
   - **SharePoint:** Trainee row is red, Remarks has `[REFERRED TO SIP - DD/MM/YYYY]`
   - **Planner:** New task in the SIP plan with description + 4 checklist items
   - **User Portal:** Sign in with the test trainee's Staff ID → red modal appears
5. **Clear the test:** Admin panel → edit trainee → Manual Highlight = None → Save. User Portal re-login → no modal.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Create_a_task" permission error | Flow owner must be a member of the Planner group |
| Task created but no description | Move description to Update task details, not Create task |
| Description missing values | Use blue Dynamic content tokens, not literal `@{...}` text |
| Remarks expression error | Use the **Expression** tab (not Dynamic content) to paste the concat formula |
| Modal not appearing | Check trainee's `Manual_Highlight` is exactly `red` (lowercase) in SharePoint |
