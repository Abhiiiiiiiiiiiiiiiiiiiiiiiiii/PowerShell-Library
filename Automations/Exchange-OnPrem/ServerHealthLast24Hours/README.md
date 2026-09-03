# Exchange Server Health Monitoring Automation

## 📌 Overview
This automation collects critical Exchange Server health and performance metrics and sends a consolidated HTML email report to administrators for proactive monitoring and quick issue identification.

---

## ✅ Problem Statement
Monitoring Exchange server health manually across multiple components is time-consuming and reactive. Lack of centralized visibility can delay issue detection and impact service availability.

---

## 💡 Solution
This automation gathers key Exchange server statistics, including queue status, message tracking, disk usage, and service health, and compiles them into a single HTML report for easy analysis and quick decision-making.

<p align="center">
  <img src="./../../../Output%20Screenshots/Health%20check%20and%20stats.png"
       width="900"
       alt="Exchange Server Health and Statistics">
</p>
---

## ⚙️ Key Features
- Collects **queue statistics** from all mailbox servers
- Retrieves **Message Tracking counts** for the last 24 hours
- Monitors **disk usage** across local drives
- Checks **Exchange server component states and health**
- Verifies status of **critical Exchange services**:
  - Frontend Transport
  - Transport
  - Throttling Service
- Generates a **single HTML report** with structured insights
- Sends automated **email report to administrators**
- Enables proactive issue detection and monitoring

---

## 🔁 Workflow
1. Connect to Exchange Server environment
2. Collect queue statistics from mailbox servers
3. Retrieve message tracking data for the last 24 hours
4. Check disk usage on local drives
5. Validate Exchange component and service health
6. Compile results into an HTML report
7. Send the report via email to stakeholders

---

## 📊 Output
- HTML email report including:
  - Queue status summary
  - Message traffic statistics (last 24 hours)
  - Disk usage overview
  - Server component health status
  - Critical service status

---

## ▶️ How to Run

```powershell
.\Get-ExchangeHealthReport.ps1
