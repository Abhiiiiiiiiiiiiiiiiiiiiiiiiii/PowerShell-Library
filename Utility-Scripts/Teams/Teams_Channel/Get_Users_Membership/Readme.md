# Microsoft Teams Bulk User Membership Report

## 📌 Overview

This PowerShell automation retrieves Microsoft Teams membership information for multiple users from a CSV input file.

It identifies the Teams associated with each user, retrieves their membership roles, and generates a consolidated CSV report containing Team names, Group IDs, privacy settings, descriptions, and processing status.

---

## ✅ Problem Statement

Manually checking Microsoft Teams membership for multiple users is time-consuming and inefficient.

Administrators often need to identify which Teams users belong to, verify their membership roles, and generate reports for access reviews, audits, and troubleshooting.

Performing these checks individually through the Microsoft Teams Admin Center requires significant manual effort.

---

## 💡 Solution

This automation connects to Microsoft Teams using PowerShell and retrieves Teams membership information for multiple users.

The script:

- Reads user principal names from a CSV file.
- Retrieves Teams associated with each user.
- Identifies membership roles (Owner or Member).
- Collects Team names, Group IDs, privacy settings, and descriptions.
- Captures processing failures and users with no returned Teams.
- Generates a consolidated CSV report.

This approach reduces manual administrative effort and simplifies Teams membership reporting.

---

## ⚙️ Key Features

- Supports **bulk user processing through CSV input**
- Connects to **Microsoft Teams PowerShell**
- Retrieves **Teams associated with each user**
- Identifies **membership roles (Owner/Member)**
- Retrieves **Team names and Microsoft 365 Group IDs**
- Identifies **Team privacy settings (Public/Private)**
- Retrieves **Team descriptions**
- Handles **invalid users and processing failures**
- Generates a **consolidated CSV report**
- Performs **read-only operations without modifying memberships**

---

## 🔁 Workflow

1. Authenticate to Microsoft Teams PowerShell.
2. Read user principal names from the input CSV.
3. Retrieve Teams associated with each user using `Get-Team`.
4. Retrieve membership information using `Get-TeamUser`.
5. Identify membership roles and Team properties.
6. Record processing status for each user.
7. Generate a consolidated CSV report.
8. Export the report to the configured output location.

---

## 📊 Output

The automation generates a CSV report containing the following information:

- User Principal Name
- Team Name
- Microsoft 365 Group ID
- Membership Role
- Team Privacy
- Team Description
- Processing Status

### Sample Output

| User | TeamName | Role | Privacy | ProcessingStatus |
|---|---|---|---|---|
| user1@contoso.com | IT Support | Member | Private | Success |
| user1@contoso.com | Operations | Owner | Public | Success |
| user2@contoso.com | Finance | Member | Private | Success |
| user3@contoso.com | | | | No Teams found |

### Output File

```text
C:\Temp\UsersTeamsMembership.csv
```

### Important Note

This automation retrieves **Microsoft Teams membership information**, not individual channel membership.

Standard channels inherit membership from their parent Team, while private and shared channels can have separate membership configurations.

---

## ▶️ How to Run

### Step 1: Prepare Input CSV

Create a CSV file named:

`TeamsChannelUser.csv`

Sample format:

```csv
User
user1@contoso.com
user2@contoso.com
user3@contoso.com
```

### Step 2: Connect to Microsoft Teams

```powershell
Connect-MicrosoftTeams
```

### Step 3: Execute the Script

```powershell
.\Get-BulkUsersTeamsMembership.ps1
```

### Step 4: Review the Report

The generated report will be available at:

```text
C:\Temp\UsersTeamsMembership.csv
```

---

## 📚 Microsoft Documentation

- [Manage Teams with PowerShell](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-managing-teams)
- [Get-Team](https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-team?view=teams-ps)
- [Get-TeamUser](https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-teamuser?view=teams-ps)
- [Connect-MicrosoftTeams](https://learn.microsoft.com/en-us/powershell/module/microsoftteams/connect-microsoftteams?view=teams-ps)

---

## ⚠️ Disclaimer

This PowerShell automation is provided for educational and administrative reporting purposes.

Administrators should review and test the script before executing it in production environments.

The script performs read-only operations and does not modify Microsoft Teams membership or configuration.

Results depend on the permissions of the authenticated account and the information returned by Microsoft Teams PowerShell.

This repository is not officially affiliated with or endorsed by Microsoft.
