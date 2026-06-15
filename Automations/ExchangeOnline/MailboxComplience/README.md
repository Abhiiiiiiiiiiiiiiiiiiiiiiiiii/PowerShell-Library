# Exchange Online User Lifecycle Automation (Certificate-Based Authentication)

## 📌 Overview
This automation provisions and standardizes mailbox configurations for newly created users in Exchange Online. It uses certificate-based authentication with an application that has Exchange Administrator and Compliance Administrator roles to securely perform lifecycle management tasks.

---

## ✅ Problem Statement
Newly created mailboxes in Exchange Online often require multiple manual configuration steps such as enabling archive, litigation hold, and setting permissions. Manual execution is time-consuming and may lead to inconsistency and compliance gaps.

---

## 💡 Solution
This automation securely connects to Microsoft Graph and Exchange Online using certificate-based authentication. It identifies users created within the last 7 days and automatically applies required mailbox configurations to ensure consistency, compliance, and governance.

---

## ⚙️ Key Features
- Uses **certificate-based authentication** for secure, unattended execution
- Utilizes **Azure AD App Registration with:
  - Exchange Administrator role
  - Compliance Administrator role
- Connects to **Exchange Online PowerShell module**
- Identifies **users created in the last 7 days**
- Automatically performs the following actions:
  - Enables **Archive Mailbox**
  - Enables **Auto-Expanding Archive**
  - Applies **Litigation Hold**
  - Sets **Calendar Permissions to Limited Details**
- Ensures standardized mailbox configuration across new users
- Designed for scheduled and automated execution

---

## 🔁 Workflow
1. Authenticate using App Registration + Certificate
2. Connect to Exchange Online PowerShell module
3. Retrieve users created within the last 7 days
4. Iterate through each mailbox
5. Apply configuration policies:
   - Enable archive mailbox
   - Enable auto-expanding archive
   - Apply litigation hold
   - Set calendar permissions (Limited Details)

---

## 📊 Output
- Execution summary (logs)
- Includes:
  - User/UPN
  - Archive Status
  - Litigation Hold Status
  - Action Result (Success/Failed)

---

## ▶️ How to Run

```powershell
.\ExchangeOnlineMailboxAutomation.ps1
