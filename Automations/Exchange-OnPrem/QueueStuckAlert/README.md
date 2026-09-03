# Exchange Queue Alert Automation

## 📌 Overview
This automation monitors Exchange Server mail queues and sends an alert email when the number of stuck or pending emails exceeds a defined threshold. It helps administrators quickly identify and respond to mail flow issues.

---

## ✅ Problem Statement
Mail flow issues caused by stuck or delayed emails in Exchange queues can lead to delivery delays and business impact. Manual monitoring is inefficient and may delay issue detection.

---

## 💡 Solution
This automation continuously checks Exchange mail queues and identifies servers where the number of queued messages exceeds a defined limit. If the threshold is breached, an automated alert email is sent to administrators.


---
## ⚙️ Key Features
- Monitors queue status across Exchange servers
- Identifies servers with **queued messages greater than threshold (e.g., 25)**
- Detects potential mail flow issues proactively
- Sends automated **email alerts to administrators**
- Lightweight and designed for scheduled execution
- Supports customizable threshold values

---

## 🔁 Workflow
1. Connect to Exchange Server environment
2. Retrieve queue statistics from all servers
3. Check message count in each queue
4. Compare against threshold (default: 25)
5. Identify servers exceeding the threshold
6. Send alert email with queue details

---

## 📊 Output
- Alert email containing:
  - Server name
  - Queue identity
  - Number of messages in queue
  - Timestamp of detection

---

## ▶️ How to Run

```powershell
.\Get-ExchangeQueueAlert.ps1
