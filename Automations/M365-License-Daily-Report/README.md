# M365 License Daily Report Automation

## 📌 Overview
This automation retrieves Microsoft 365 license information using Microsoft Graph API with secure, certificate-based authentication. It generates a structured license report by translating SKU IDs into readable license names and sends the report via email to administrators.

---

## ✅ Problem Statement
Manual tracking of M365 license usage is time-consuming and lacks standardization. SKU IDs are not human-readable, making reporting and analysis difficult.

---

## 💡 Solution
This automation securely connects to Microsoft Graph using an application with Directory.Read.All permission and certificate-based authentication, retrieves license subscription details, translates SKU IDs into friendly license names, and generates a report for easy analysis.

<p align="center">
  <img src="../../../Output%20Screenshots/Lincense%20Automation.jpeg"
       width="900"
       alt="M365 License Daily Report">
</p>
---

## ⚙️ Key Features
- Uses **certificate-based authentication** (no stored credentials)
- Connects to **Microsoft Graph API securely**
- Retrieves **subscribed SKU IDs** from the tenant
- Translates SKU IDs into **readable license names**
- Creates a structured **license summary table**
- Sends automated **email report to administrators**
- Designed for **unattended, scheduled execution**

---

## 🔁 Workflow
1. Authenticate to Microsoft Graph using App Registration + Certificate
2. Retrieve subscribed SKU details from tenant
3. Map SKU IDs to friendly license names
4. Generate a structured license report (table format)
5. Send report via email to stakeholders

---

## 📊 Output
- License summary report (CSV/HTML/Table)
- Includes:
  - License Name
  - SKU ID
  - Total Units
  - Consumed Units
  - Available Units

---

## ▶️ How to Run

```powershell
.\Get-M365LicenseDailyReport.ps1
