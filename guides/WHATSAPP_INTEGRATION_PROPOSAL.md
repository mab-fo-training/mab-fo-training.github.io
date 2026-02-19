# WhatsApp-to-SharePoint Integration Proposal

## Executive Summary

This proposal integrates a WhatsApp-based submission channel into the existing Training Progress Tracker, allowing 30+ instructors to submit trainee progress updates from their personal mobile devices. It runs **alongside** the existing Microsoft Forms + Power Automate flow — not replacing it.

---

## 1. Current System Overview

```
┌─────────────┐    ┌──────────────────┐    ┌──────────────────────────┐
│  Instructor  │───▶│  Microsoft Forms  │───▶│  Power Automate Flow     │
│  (Browser)   │    │  (IOE Progress)   │    │  "IOE Progress"          │
└─────────────┘    └──────────────────┘    │  - Switch on Stage       │
                                            │  - Update SharePoint     │
┌─────────────┐    ┌──────────────────┐    │  - Send emails           │
│  Admin/User  │───▶│  Web App (GitHub  │    └──────────┬───────────────┘
│  (Browser)   │    │  Pages + MSAL)    │               │
└─────────────┘    └──────────┬───────┘               │
                              │                        ▼
                              │              ┌──────────────────┐
                              └─────────────▶│  SharePoint List  │
                                             │  Training_Progress│
                                             └──────────────────┘
```

### What Instructors Currently Submit (via Forms)
| Field | Example |
|-------|---------|
| NAME OF TRAINEE | JOHN DOE |
| STAFF NUMBER | 123456 |
| FLEET | B737 (ignored — already in SP) |
| TOTAL SECTORS | 45 |
| DATE | 2/9/2026 |
| Progression Stage | Cleared Functional / LRC COMPLETED / Command Check COMPLETED / REFERRED TO SIP / etc. |
| REFERRED TO SIP | (text, if applicable) |
| Referral Reason(s) | (text, if applicable) |

### What Power Automate Does with It
- Looks up trainee by Staff_ID in `Training_Progress`
- Switches on Progression Stage:
  - **Cleared Functional** → sets `Functional_Date`, `Sectors_Flown`
  - **LRC COMPLETED** → sets `LRC_Date`, `Sectors_Flown`
  - **Command Check COMPLETED** → sets `Command_Check_Date`, `Sectors_Flown`
  - **Cleared for LRC / Command Check** → appends to `Remarks`
  - **REFERRED TO SIP** → sets `Manual_Highlight: red`, appends to `Remarks`
- Sets `Last_Updated` to `utcNow()`
- Sends notification emails

---

## 2. Proposed Architecture (Adapted to Existing System)

The original WhatsApp-to-SharePoint txt proposed new SharePoint lists. **We don't need those.** We reuse the existing `Training_Progress` list and map to the same fields.

```
┌─────────────┐    ┌──────────────────┐    ┌──────────────────────────┐
│  Instructor  │───▶│  Microsoft Forms  │───▶│  Power Automate          │
│  (Browser)   │    └──────────────────┘    │  "IOE Progress"          │
│              │                             └──────────┬───────────────┘
│              │    ┌──────────────────┐                │
│  Instructor  │───▶│  WhatsApp (Twilio)│    ┌──────────┼───────────────┐
│  (Mobile)    │    └────────┬─────────┘    │          ▼               │
└─────────────┘             │               │  ┌──────────────────┐    │
                    ┌───────▼──────────┐    │  │  SharePoint List  │    │
                    │  Twilio Studio    │    │  │  Training_Progress│    │
                    │  (Chat Flow)      │    │  └──────────────────┘    │
                    └───────┬──────────┘    │                          │
                            │               │  ┌──────────────────┐    │
                    ┌───────▼──────────┐    │  │  Authorized_      │    │
                    │  Power Automate   │───▶│  │  Instructors (SP) │    │
                    │  "WhatsApp Worker"│    │  └──────────────────┘    │
                    └──────────────────┘    └──────────────────────────┘
```

### Key Design Decisions
1. **No new data lists** — writes directly to `Training_Progress` (same as Forms flow)
2. **New `Authorized_Instructors` list** — for phone-based auth (see Security section)
3. **Separate Power Automate flow** — "WhatsApp Worker" handles WhatsApp submissions independently
4. **Both channels coexist** — instructors choose whichever is convenient

---

## 3. Systematic Implementation Plan

### Phase 0: Prerequisites (Day 1)
| # | Task | Owner | Notes |
|---|------|-------|-------|
| 0.1 | Create Twilio account | Admin | twilio.com — free trial includes $15 credit |
| 0.2 | Purchase WhatsApp-enabled number | Admin | ~$1.15/month + per-message fees |
| 0.3 | Apply for WhatsApp Business API | Admin | Via Twilio — requires Facebook Business verification |
| 0.4 | Create `Authorized_Instructors` SharePoint list | Admin | See schema below |

> **Important**: WhatsApp Business API approval can take 1-7 days. Start this first.

#### `Authorized_Instructors` List Schema
| Column | Type | Example | Notes |
|--------|------|---------|-------|
| Title | Text | CAPT AHMAD BIN ALI | Instructor name |
| Phone_Number | Text | +60123456789 | Must include country code |
| Email | Text | ahmad@malaysiaairlines.com | For cross-reference |
| PIN | Text | 4837 | 4-digit verification PIN (see Security) |
| Is_Active | Yes/No | Yes | To disable without deleting |

### Phase 1: Power Automate Flows (Day 2-3)

#### Flow A: "WhatsApp — Validate Instructor"
```
Trigger: HTTP Request (POST)
Input: { "phone": "+60123456789" }

→ Get Items from Authorized_Instructors
  Filter: Phone_Number eq '{phone}' and Is_Active eq 1
→ Condition: Found?
  → YES: Response { "authorized": true, "name": "CAPT AHMAD" }
  → NO:  Response { "authorized": false }
```

#### Flow B: "WhatsApp — Validate Staff ID"
```
Trigger: HTTP Request (POST)
Input: { "staff_id": "123456" }

→ Get Items from Training_Progress
  Filter: Staff_ID eq '{staff_id}'
→ Condition: Found?
  → YES: Response { "valid": true, "name": "JOHN DOE", "fleet": "B738", "batch": "24/05" }
  → NO:  Response { "valid": false }
```

#### Flow C: "WhatsApp — Save Update"
```
Trigger: HTTP Request (POST)
Input: {
  "staff_id": "123456",
  "sectors": 45,
  "stage": "Cleared Functional",
  "date": "2026-02-17",
  "instructor_phone": "+60123456789",
  "pin": "4837"
}

→ Step 1: Re-validate instructor (phone + PIN match)
→ Step 2: Get Items from Training_Progress (filter by Staff_ID)
→ Step 3: Switch on "stage" (IDENTICAL logic to existing IOE Progress flow):
    ├── Cleared Functional → Update Functional_Date, Sectors_Flown
    ├── LRC COMPLETED → Update LRC_Date, Sectors_Flown
    ├── Command Check COMPLETED → Update Command_Check_Date, Sectors_Flown
    ├── Cleared for LRC → Append Remarks, Update Sectors_Flown
    ├── Cleared for Command Check → Append Remarks, Update Sectors_Flown
    └── REFERRED TO SIP → Set Manual_Highlight: red, Append Remarks
→ Step 4: Set Last_Updated = utcNow()
→ Step 5: Set Remarks append: "[Via WhatsApp - CAPT AHMAD - 2026-02-17]"
→ Step 6: Send notification emails (same recipients as Forms flow)
→ Response: { "success": true }
```

### Phase 2: Twilio Studio Chatbot (Day 3-5)

#### Conversation Flow
```
INSTRUCTOR sends any message to WhatsApp number
    │
    ▼
BOT: "Training Progress Tracker 🛫
      Reply with your 4-digit PIN to continue."
    │
    ▼
INSTRUCTOR: "4837"
    │
    ▼
[HTTP → Flow A: Validate phone + PIN]
    │
    ├── FAIL: "Unauthorized. Contact admin if you believe this is an error."
    │
    ▼ PASS
BOT: "Welcome, Capt Ahmad. Enter trainee Staff ID:"
    │
    ▼
INSTRUCTOR: "123456"
    │
    ▼
[HTTP → Flow B: Validate Staff ID]
    │
    ├── FAIL: "Staff ID not found. Try again:"
    │
    ▼ PASS
BOT: "Found: JOHN DOE (B738, Batch 24/05)
      Select progression stage:
      1️⃣ Cleared Functional
      2️⃣ LRC COMPLETED
      3️⃣ Command Check COMPLETED
      4️⃣ Cleared for LRC
      5️⃣ Cleared for Command Check
      6️⃣ REFERRED TO SIP"
    │
    ▼
INSTRUCTOR: "1"
    │
    ▼
BOT: "Enter total sectors flown:"
    │
    ▼
INSTRUCTOR: "45"
    │
    ▼
BOT: "Enter date (DD/MM/YYYY) or type TODAY:"
    │
    ▼
INSTRUCTOR: "TODAY"
    │
    ▼
BOT: "📋 Please confirm:
      Trainee: JOHN DOE (123456)
      Stage: Cleared Functional
      Sectors: 45
      Date: 17/02/2026

      Reply YES to submit or NO to cancel."
    │
    ▼
INSTRUCTOR: "YES"
    │
    ▼
[HTTP → Flow C: Save Update]
    │
    ▼
BOT: "✅ Updated successfully.
      JOHN DOE → Cleared Functional
      Notification emails sent."
```

#### Twilio Studio Widget Map
| # | Widget Type | Purpose |
|---|------------|---------|
| 1 | Trigger | Incoming WhatsApp message |
| 2 | Send & Wait for Reply | Ask for PIN |
| 3 | HTTP Request | Call Flow A (validate instructor + PIN) |
| 4 | Split Based On | Check authorization result |
| 5 | Send & Wait for Reply | Ask for Staff ID |
| 6 | HTTP Request | Call Flow B (validate staff ID) |
| 7 | Split Based On | Check if trainee found |
| 8 | Send Message | Show trainee details + stage menu |
| 9 | Send & Wait for Reply | Get stage selection |
| 10 | Send & Wait for Reply | Get total sectors |
| 11 | Send & Wait for Reply | Get date |
| 12 | Send Message | Show confirmation summary |
| 13 | Send & Wait for Reply | Get YES/NO |
| 14 | Split Based On | Check confirmation |
| 15 | HTTP Request | Call Flow C (save to SharePoint) |
| 16 | Send Message | Success confirmation |

### Phase 3: Testing & Rollout (Day 5-7)
| # | Task |
|---|------|
| 3.1 | Test with 1-2 instructors on Twilio sandbox (no WhatsApp approval needed) |
| 3.2 | Verify SharePoint updates match Forms flow output exactly |
| 3.3 | Verify notification emails are sent |
| 3.4 | Test error paths: wrong PIN, invalid Staff ID, cancelled submission |
| 3.5 | Deploy to production WhatsApp number |
| 3.6 | Add all 30+ instructors to `Authorized_Instructors` list |
| 3.7 | Distribute WhatsApp number and PINs to instructors |

---

## 4. Security Analysis & Improvements

### Original Proposal Security Gaps

| Gap | Risk | Severity |
|-----|------|----------|
| Phone number only auth | Numbers can be spoofed/stolen | **High** |
| No PIN or 2FA | Anyone with the number can submit | **High** |
| HTTP endpoints publicly accessible | Anyone with the URL can call flows | **Medium** |
| No audit trail of who submitted | Hard to trace bad submissions | **Medium** |
| No rate limiting | Could be spammed | **Low** |

### Security Measures in This Proposal

#### 4.1 Two-Factor Verification (Phone + PIN)
- Instructor must send from their registered phone number **AND** provide a 4-digit PIN
- PIN is stored in `Authorized_Instructors` list (hashed if possible, plain if Power Automate can't hash)
- PINs are distributed privately to each instructor
- PINs can be rotated by admin at any time

#### 4.2 Re-validation on Save
- Flow C re-checks phone + PIN before writing to SharePoint
- Prevents replay attacks where someone captures the save URL

#### 4.3 Audit Trail
- Every WhatsApp submission appends `[Via WhatsApp - INSTRUCTOR NAME - DATE]` to Remarks
- Distinguishes WhatsApp updates from Forms updates in the data
- Admin can filter/search by submission source

#### 4.4 `Is_Active` Flag
- Instructors can be deactivated instantly without deleting their record
- Useful when someone leaves or changes role

#### 4.5 Session Timeout in Twilio Studio
- Set conversation timeout to 5 minutes
- If instructor doesn't complete within 5 minutes, session resets
- Prevents someone picking up an unlocked phone mid-conversation

#### 4.6 Confirmation Step
- Every submission requires explicit "YES" confirmation
- Shows full summary before saving — prevents fat-finger mistakes

#### 4.7 Power Automate HTTP Trigger Security
- Use the auto-generated SAS token in the HTTP trigger URL (built-in to Power Automate)
- Only Twilio Studio knows the full URL with token
- Optionally add an `X-API-Key` header checked in the flow

#### 4.8 What We CAN'T Fully Mitigate
- **SIM swapping/phone theft**: If someone steals a phone AND knows the PIN, they can submit. Mitigation: instructor reports lost phone → admin sets `Is_Active = No` immediately.
- **Twilio account compromise**: If Twilio credentials leak, attacker could modify the flow. Mitigation: enable 2FA on Twilio account, restrict API key permissions.

---

## 5. Alternative Approaches

### Alternative A: Microsoft Teams Bot (Recommended — Zero Cost)

Instead of WhatsApp via Twilio, build a bot inside Microsoft Teams using Power Virtual Agents (included in M365 licenses).

```
Instructor (Teams mobile app) → Power Virtual Agents Bot → Power Automate → SharePoint
```

| Pros | Cons |
|------|------|
| **Zero cost** — included in M365 | Requires Teams app installed |
| **Native M365 auth** — no phone/PIN needed | Less familiar than WhatsApp for some |
| **No third-party accounts** — IT-friendly | Power Virtual Agents learning curve |
| **Admin-managed** — lives in your tenant | Bot builder UI can be clunky |
| **Audit trail built-in** — Teams logs everything | |
| **Works on mobile** — Teams mobile app | |

**Security**: Inherits Microsoft 365 authentication — no phone spoofing risk. The instructor is whoever is logged into Teams.

**Effort**: ~3-5 days, similar to Twilio approach.

### Alternative B: Adaptive Card via Teams (Simplest — Zero Cost)

Skip the chatbot entirely. Send instructors a Teams message with an **Adaptive Card** (interactive form embedded in the chat).

```
Power Automate (scheduled/on-demand) → Send Adaptive Card to Instructor →
Instructor fills card → Power Automate → SharePoint
```

| Pros | Cons |
|------|------|
| **Extremely simple** — no bot to build | Less conversational |
| **Zero cost** | Must be in Teams |
| **Native auth** | Card design has limitations |
| **Rich UI** — dropdowns, date pickers | Cards expire after a while |
| **2 clicks to submit** | |

**How it works**:
1. Admin triggers a flow (or instructor sends a keyword to a Teams channel)
2. Power Automate sends an Adaptive Card to the instructor in Teams
3. Card has: Staff ID field, Stage dropdown, Sectors field, Date picker
4. Instructor fills in and clicks Submit
5. Flow processes the card response → updates SharePoint

**Security**: Full M365 auth. No external services.

**Effort**: ~1-2 days. Simplest option.

### Alternative C: Progressive Web App (PWA) Shortcut

Make the existing web app mobile-friendly and add it to instructors' home screens.

```
Instructor opens PWA → Signs in (MSAL) → Quick-submit form → SharePoint
```

| Pros | Cons |
|------|------|
| **Already built** — web app exists | Requires browser sign-in each time |
| **Full M365 auth** | Less convenient than WhatsApp |
| **No new services** | Needs mobile-optimized submit form |
| **Rich UI** | Token expires, re-auth needed |

**What's needed**: Add a simplified "Quick Submit" form to the existing app optimized for mobile instructors — just the 4 fields (Staff ID, Stage, Sectors, Date) with large touch targets.

**Effort**: ~1 day to add the mobile form.

### Alternative D: WhatsApp via Twilio (Original Proposal, Enhanced)

This is what's detailed in Sections 2-4 above.

| Pros | Cons |
|------|------|
| **WhatsApp is universal** — everyone has it | ~$2-5/month ongoing cost |
| **No app install needed** | Third-party dependency (Twilio) |
| **Works offline** (queues messages) | WhatsApp Business API approval needed |
| **Familiar UX** | Phone-based auth is weaker |
| | 30+ instructors on personal phones = security concern |
| | Twilio account management overhead |

---

## 6. Comparison Matrix

| Criteria | WhatsApp (Twilio) | Teams Bot (PVA) | Adaptive Card | PWA Quick Submit |
|----------|:-:|:-:|:-:|:-:|
| **Cost** | ~$2-5/mo | Free | Free | Free |
| **Security** | Medium (phone+PIN) | High (M365 auth) | High (M365 auth) | High (M365 auth) |
| **Mobile UX** | Excellent | Good | Good | Fair |
| **Setup effort** | 5-7 days | 3-5 days | 1-2 days | 1 day |
| **Maintenance** | Medium (Twilio) | Low | Low | None |
| **No app required** | ✅ (just WhatsApp) | ❌ (Teams app) | ❌ (Teams app) | ❌ (browser) |
| **Works without internet** | Partial (queues) | ❌ | ❌ | ❌ |
| **IT approval needed** | Maybe (Twilio) | No | No | No |
| **Instructor familiarity** | High | Medium | Medium | Low |
| **Audit trail** | Manual (Remarks) | Built-in | Built-in | Built-in |

---

## 7. Recommendation

### Best Overall: **Alternative B — Adaptive Card via Teams**
- Zero cost, minimal setup (1-2 days), strong security via M365 auth
- Good enough mobile UX — Teams mobile app is already on most phones
- No third-party dependencies, no maintenance overhead
- Start here, and only move to WhatsApp if instructors refuse to use Teams

### Best UX: **Alternative D — WhatsApp via Twilio**
- If instructors strongly prefer WhatsApp and budget allows
- Implement with the security enhancements from Section 4
- Consider as Phase 2 after proving the concept with Adaptive Cards

### Suggested Rollout Strategy
```
Phase 1 (Week 1):     Adaptive Card in Teams — quick win, free, secure
Phase 2 (Week 2-3):   Gather feedback — is Teams sufficient?
Phase 3 (If needed):  WhatsApp via Twilio — only if Teams adoption is low
```

---

## 8. Cost Summary

| Item | Adaptive Card | WhatsApp (Twilio) |
|------|:---:|:---:|
| Monthly service | $0 | ~$1.15 (number) |
| Per-submission | $0 | ~$0.04 (WhatsApp msg) |
| Est. 100 submissions/mo | **$0** | **~$5.15** |
| Annual cost | **$0** | **~$62** |

---

## 9. Next Steps

1. **Decide** which approach to start with
2. If Adaptive Card: Build the card JSON + Power Automate flow (1-2 days)
3. If WhatsApp: Start Twilio signup + WhatsApp Business API approval immediately (bottleneck)
4. Create `Authorized_Instructors` list in SharePoint (needed for WhatsApp only)
5. Test with 2-3 instructors before full rollout
6. Update `CLAUDE.md` and `POWER_AUTOMATE_GUIDE.md` with new flow documentation

---

*Proposal prepared: 2026-02-17*
*System: Training Progress Tracker v3.0 Enhanced*
