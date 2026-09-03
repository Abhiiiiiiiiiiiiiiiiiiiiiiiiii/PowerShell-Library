# Exchange Server Disk Space Alert Automation

## 📌 Overview
This automation monitors disk space usage on Exchange Servers and sends an automated alert email when available disk space falls below a defined threshold. It helps administrators proactively detect storage issues and prevent service disruptions.

---

## ✅ Problem Statement
Low disk space on Exchange Servers can lead to performance degradation, service interruptions, and mail flow issues. Manual monitoring of disk usage is inefficient and may delay issue detection.

---

## 💡 Solution
This automation checks available disk space on Exchange servers and compares it against a predefined threshold. If the free space falls below the threshold limit, an alert email is triggered with relevant server and disk details.

---
<p align="center">
  <img src="../../../Output%20Screenshots/Disk%20automation.png"
       width="900"
       alt="Exchange Disk Storage Alert">
</p>
---

## ⚙️ Key Features
- Monitors **disk space usage** on Exchange servers
- Checks **available free space (GB)**
- Triggers alert when free space falls **below threshold**
- Sends automated **email notification to administrators**
- Includes server and disk details in alert message
- Designed for **scheduled execution**

---

## 🔁 Workflow
1. Retrieve disk space information from Exchange server (local drives)
2. Calculate available free space (GB)
3. Compare with defined threshold value
4. If free space is below threshold:
   - Generate alert message
   - Send email notification to stakeholders

---

## 📊 Alert Details
The email alert includes:
- Server Name
- Drive Name (e.g., C:)
- Total Disk Capacity
- Available Free Space
- Threshold Breach Notification
- Timestamp of alert

---
## ▶️ How to Run

```powershell
.\Get-ExchangeDiskAlert.ps1
