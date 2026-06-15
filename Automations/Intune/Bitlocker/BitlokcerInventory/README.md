# BitLocker Inventory & Compliance Automation

## 📌 Overview
This automation retrieves managed device details and BitLocker recovery key information from Microsoft Graph using secure, certificate-based authentication. It compares device inventory with available BitLocker keys and identifies devices that are missing or not compliant.

---

## ✅ Problem Statement
Tracking BitLocker encryption status and recovery key availability across devices is critical for security and compliance. Manual verification is inefficient and may lead to unmanaged or unprotected devices going unnoticed.

---

## 💡 Solution
This automation connects securely to Microsoft Graph using an application with certificate-based authentication, retrieves managed devices and BitLocker recovery keys, compares both datasets, and identifies devices that do not have properly escrowed keys. The results are compiled into a report and shared via email with administrators.

---

## ⚙️ Key Features
- Uses **certificate-based authentication** (no stored credentials)
- Connects securely to **Microsoft Graph API**
- Retrieves **managed devices** from Intune / Azure AD
- Fetches **BitLocker recovery keys** escrowed to Azure AD / Intune
- Compares device inventory with available BitLocker keys
- Identifies devices with:
  - Missing recovery keys
  - Unmanaged or non-compliant encryption status
- Generates structured **inventory and compliance report**
- Sends automated **email report to administrators**
- Designed for **unattended execution**

---

## 🔁 Workflow
1. Authenticate to Microsoft Graph using App Registration + Certificate
2. Retrieve managed device inventory via Graph API
3. Retrieve BitLocker recovery keys via Graph API
4. Compare devices against available recovery keys
5. Identify non-compliant devices (missing or unmanaged keys)
6. Generate a consolidated report
7. Send the report via email to stakeholders

---

## 📊 Output
- Device compliance report (CSV/HTML/Table)
- Includes:
  - Device Name
  - User Assigned
  - Device ID
  - BitLocker Key Present (Yes/No)
  - Compliance Status (Compliant / Missing / Unmanaged)

---

## ▶️ How to Run

```powershell
.\Get-BitLockerInventoryReport.ps1
