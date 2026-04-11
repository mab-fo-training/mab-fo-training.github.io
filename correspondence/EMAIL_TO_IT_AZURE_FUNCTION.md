# Email to IT: Azure Function App Request

**Subject:** Request: Create Azure Function App for Training Tracker (Security Enhancement)

---

Dear IT Team,

Thank you for running the PowerShell command to grant the app site-level permission.

I would like to request the creation of an Azure Function App to serve as a secure backend for the Training Tracker application. This approach provides significant security benefits:

**Why Azure Function Backend?**

1. **No SharePoint Access Required for Users**
   - Trainees will NOT need to be added to the FLTOPS-TRAINING SharePoint site
   - The Azure Function authenticates directly using app-only credentials
   - Users interact only with the web app; SharePoint remains completely isolated
   - Reduces attack surface and simplifies user management

2. **Principle of Least Privilege**
   - The app uses `Sites.Selected` permission (already granted)
   - Access is restricted to only the Training_Progress list
   - No broad SharePoint permissions needed for end users

3. **Minimal Cost (Effectively Free)**

   **Azure Functions Consumption Plan (Free Tier):**
   - 1 million executions/month FREE
   - 400,000 GB-seconds/month FREE
   - Estimated app usage: ~30,000 executions/month (3% of free tier)
   - Function execution cost: **$0.00**

   **Storage Account (required, no free tier):**
   - Used only for function code and runtime coordination
   - Hot storage: ~$0.018/GB/month
   - Our usage: Few KB of code, minimal transactions
   - Estimated cost: **$0.01 - $0.50/month**

   **Total Estimated Cost: Under $1/month**

**Requested Configuration:**

| Setting | Value |
|---------|-------|
| Function App Name | `training-tracker-api` (or similar) |
| Runtime | Node.js 18 |
| Region | Southeast Asia |
| Plan | Consumption (Serverless) |
| Resource Group | New or existing |

Once created, please add me as a **Contributor** to the Function App so I can deploy the application code.

Please let me know if you have any questions or require additional information.

Best regards,
Capt. Mohamad Shazreen Sazali

---

## References

- [Azure Functions Pricing](https://azure.microsoft.com/en-us/pricing/details/functions/)
- [Estimating consumption-based costs | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-functions/functions-consumption-costs)
