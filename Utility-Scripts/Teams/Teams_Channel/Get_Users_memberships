# Microsoft Teams Bulk User Membership Report

## 1. Overview

This repository provides a PowerShell automation solution to retrieve Microsoft Teams membership information for multiple users and export the results into a consolidated CSV report.

The script uses the Microsoft Teams PowerShell module to identify Teams associated with each user, retrieve their membership roles, and collect relevant Team information.

This automation is designed for Microsoft 365 administrators, Microsoft Teams administrators, and IT support engineers who need to perform bulk Teams membership reporting and access reviews.

### Key Features

- Retrieve Microsoft Teams membership for multiple users.
- Process users from a CSV input file.
- Identify Teams associated with each user.
- Retrieve membership roles (Owner or Member).
- Retrieve Team names and Microsoft 365 Group IDs.
- Identify Team privacy settings (Public or Private).
- Retrieve Team descriptions.
- Handle invalid users and processing failures.
- Generate a consolidated CSV report.
- Perform read-only operations without modifying memberships.

---

## 2. Importance

Managing Microsoft Teams membership manually can become time-consuming, especially when administrators need to verify access for multiple users.

Checking membership individually through the Microsoft Teams Admin Center is inefficient for bulk reporting requirements.

This PowerShell automation helps administrators:

### Reduce Manual Effort
Retrieve Teams membership information for multiple users through a single execution.

### Improve Visibility
Identify which Microsoft Teams each user belongs to and their membership roles.

### Support Access Reviews
Generate membership reports for internal audits, access reviews, and administrative verification.

### Simplify Troubleshooting
Identify users with no returned Teams memberships and capture processing failures.

### Generate Reports
Export membership information into a structured CSV file for further analysis.

---

## 3. Repository Structure

```text
Microsoft-Teams-Bulk-User-Membership-Report/
│
├── README.md
│
├── Get-BulkUsersTeamsMembership.ps1
│
├── Backend-Settings.md
│
├── TeamsChannelUser.csv
│
└── .gitignore
```

### File Descriptions

| File | Description |
|------|-------------|
| README.md | Complete documentation for the automation |
| Get-BulkUsersTeamsMembership.ps1 | PowerShell automation script |
| Backend-Settings.md | Backend configuration, authentication, and permissions |
| TeamsChannelUser.csv | Sample CSV containing user principal names |
| .gitignore | Excludes local reports and sensitive files |

---

## 4. Prerequisites

Before executing the script, ensure the following requirements are met:

- Windows PowerShell 5.1 or a supported PowerShell 7 version.
- Microsoft Teams PowerShell module.
- Access to a Microsoft 365 tenant.
- Appropriate Microsoft Teams administrative permissions.
- Successful authentication to Microsoft Teams PowerShell.
- CSV file containing valid user principal names.
- Permission to read the input file and write the output report.

For detailed administrative roles, authentication requirements, and environment configuration, refer to:

**[Backend-Settings.md](Backend-Settings.md)**

---

## 5. CSV Input Format

The script processes users from a CSV file.

### Input Filename

`TeamsChannelUser.csv`

### Sample CSV

```csv
User
user1@contoso.com
user2@contoso.com
user3@contoso.com
```

### CSV Requirements

1. The column header must be `User`.
2. Each row must contain a user principal name.
3. Enter one user per row.
4. Avoid duplicate entries.
5. Ensure the user principal names are valid.
6. Save the file in CSV format.

### Default Input Location

```text
C:\Temp\TeamsChannelUser.csv
```

The input location can be modified inside the PowerShell script.

---

## 6. Complete PowerShell Script

### Script Name

`Get-BulkUsersTeamsMembership.ps1`

```powershell
# ==============================================
# Microsoft Teams Bulk User Membership Report
# ==============================================

# Input/output files
$UserFile   = "C:\Temp\TeamsChannelUser.csv"
$OutputFile = "C:\Temp\UsersTeamsMembership.csv"

# Validate input file
if (-not (Test-Path -LiteralPath $UserFile -PathType Leaf)) {
    throw "Input CSV file not found: $UserFile"
}

# Create output directory if required
$OutputDirectory = Split-Path -Path $OutputFile -Parent

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force |
        Out-Null
}

# Read users from CSV
$InputData = @(Import-Csv -LiteralPath $UserFile)

if (
    $InputData.Count -eq 0 -or
    "User" -notin $InputData[0].PSObject.Properties.Name
) {
    throw "Input CSV must contain a User column with at least one row."
}

$Users = @(
    $InputData |
        ForEach-Object {
            if ($null -ne $_.User) {
                $_.User.Trim()
            }
        } |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        } |
        Select-Object -Unique
)

if ($Users.Count -eq 0) {
    throw "No valid user entries found in the input CSV."
}

# Create result collection
$Result = foreach ($User in $Users) {

    Write-Host "Processing: $User" -ForegroundColor Cyan

    try {

        # Get all Teams associated with the user
        $Teams = @(Get-Team -User $User -ErrorAction Stop)

        if ($Teams.Count -gt 0) {

            foreach ($Team in $Teams) {

                try {

                    # Get user's membership information
                    $UserInfo = @(
                        Get-TeamUser `
                            -GroupId $Team.GroupId `
                            -ErrorAction Stop |
                        Where-Object {
                            $_.User -eq $User
                        }
                    )

                    $Role = if ($UserInfo.Count -gt 0) {
                   
                    }
                    else {
                        ""
                    }

                    $Status = if ($UserInfo.Count -gt 0) {
                        "Success"
                    }
                    else {
                        "User role not found"
                    }

                    # Create report entry
                    [PSCustomObject]@{
                        User             = $User
                        TeamName         = $Team.DisplayName
                        GroupId          = $Team.GroupId
                        Role             = $Role
                        Privacy          = $Team.Visibility
                        Description      = $Team.Description
                        ProcessingStatus = $Status
                    }

                }
                catch {

                    [PSCustomObject]@{
                        User             = $User
                        TeamName         = $Team.DisplayName
                        GroupId          = $Team.GroupId
                        Role             = ""
                        Privacy          = $Team.Visibility
                        Description      = $Team.Description
                        ProcessingStatus = "Failed to get Team user info: $($_.Exception.Message)"
                    }

                }

            }

        }
        else {

            # User has no Teams returned
            [PSCustomObject]@{
                User             = $User
                TeamName         = ""
                GroupId          = ""
                Role             = ""
                Privacy          = ""
                Description      = ""
                ProcessingStatus = "No Teams found"
            }

        }

    }
    catch {

        # Handle invalid users, permissions, etc.
        [PSCustomObject]@{
            User             = $User
            TeamName         = ""
            GroupId          = ""
            Role             = ""
            Privacy          = ""
            Description      = ""
            ProcessingStatus = "Failed: $($_.Exception.Message)"
        }

    }

}

# Display results
$Result |
    Format-Table User, TeamName, Role, Privacy, ProcessingStatus -AutoSize

# Export everything to CSV
$Result |
    Export-Csv `
        -LiteralPath $OutputFile `
        -NoTypeInformation `
        -Encoding UTF8

Write-Host ""
Write-Host "Report exported to: $OutputFile" -ForegroundColor Green
```

---

## 7. Configuration

The script contains two configurable file paths.

```powershell
$UserFile   = "C:\Temp\TeamsChannelUser.csv"
$OutputFile = "C:\Temp\UsersTeamsMembership.csv"
```

### Input File

`$UserFile` specifies the location of the CSV containing user principal names.

### Output File

`$OutputFile` specifies where the generated Teams membership report will be saved.

### Backend Configuration

For administrative roles, authentication, permissions, and environment requirements, refer to:

**Backend-Settings.md**

---

## 8. Usage Steps

### Step 1: Prepare the Input CSV

Create the following file:

```text
C:\Temp\TeamsChannelUser.csv
```

Add the required user principal names under the `User` column.

### Step 2: Connect to Microsoft Teams

Open PowerShell and authenticate:

```powershell
Connect-MicrosoftTeams
```

Sign in using an account with the required permissions.

### Step 3: Configure File Paths

Open:

`Get-BulkUsersTeamsMembership.ps1`

Update the input and output file paths if required.

### Step 4: Execute the Script

Navigate to the directory containing the script.

Run:

```powershell
.\Get-BulkUsersTeamsMembership.ps1
```

### Step 5: Monitor Execution

The script displays the user currently being processed.

Example:

```text
Processing: user1@contoso.com
Processing: user2@contoso.com
Processing: user3@contoso.com
```

### Step 6: Review the Report

After execution, the script generates:

```text
C:\Temp\UsersTeamsMembership.csv
```

Open the CSV using Microsoft Excel or another compatible application.

---

## 9. Execution Summary

The script performs the following operations:

1. Validates the input CSV file.
2. Reads the user principal names.
3. Removes blank and duplicate entries.
4. Processes each user individually.
5. Retrieves Teams associated with the user.
6. Retrieves the user's membership role.
7. Collects Team properties.
8. Records processing status.
9. Continues processing if individual users fail.
10. Exports the consolidated report.

### Processing Status Values

| Status | Description |
|--------|-------------|
| Success | Team membership information retrieved successfully |
| No Teams found | No Teams were returned for the user |
| User role not found | Team was returned, but the user's role was not resolved |
| Failed | User-level processing failed |
| Failed to get Team user info | Team membership lookup failed |

---

## 10. Output CSV Format

The generated report contains the following columns:

| Column | Description |
|--------|-------------|
| User | User principal name |
| TeamName | Microsoft Teams display name |
| GroupId | Microsoft 365 Group ID |
| Role | Membership role |
| Privacy | Public or Private |
| Description | Team description |
| ProcessingStatus | Processing result |

### Example Output

| User | TeamName | Role | Privacy | ProcessingStatus |
|------|----------|------|---------|------------------|
| user1@contoso.com | IT Support | Member | Private | Success |
| user1@contoso.com | Operations | Owner | Public | Success |
| user2@contoso.com | Finance | Member | Private | Success |
| user3@contoso.com | | | | No Teams found |

The above output is illustrative.

### Expected Behavior

If a user belongs to multiple Teams, the report generates one row per Team.

If no Teams are returned, the report records the status as `No Teams found`.

If a membership lookup fails, the error is recorded without stopping the entire operation.

---

## 11. Verification

Administrators can verify the generated report using Microsoft Teams PowerShell.

### Verify Teams Associated with a User

```powershell
Get-Team -User user1@contoso.com
```

### Verify Membership of a Specific Team

```powershell
Get-TeamUser -GroupId "YOUR-TEAM-GROUP-ID"
```

### Verify Membership Roles

```powershell
Get-TeamUser -GroupId "YOUR-TEAM-GROUP-ID" |
Select-Object User, Role
```

### Verification Checklist

- Confirm the input users were processed.
- Verify the Team names.
- Verify the Group IDs.
- Confirm membership roles.
- Review processing failures.
- Compare selected results with Microsoft Teams PowerShell.

---

## 12. Automation Workflow

```text
Start
  |
  v
Validate Input CSV
  |
  v
Read User Principal Names
  |
  v
Remove Blank/Duplicate Entries
  |
  v
Process Each User
  |
  v
Retrieve Associated Teams
  |
  v
Retrieve Membership Roles
  |
  v
Collect Team Properties
  |
  v
Record Processing Status
  |
  v
Process Remaining Users
  |
  v
Export Consolidated CSV
  |
  v
End
```

---

## 13. Expected Result

After successful execution:

- Multiple users are processed automatically.
- Teams associated with each user are retrieved.
- Membership roles are recorded.
- Team names and Group IDs are collected.
- Team privacy settings are included.
- Team descriptions are included.
- Processing failures are captured.
- A consolidated CSV report is generated.

### Default Output Location

```text
C:\Temp\UsersTeamsMembership.csv
```

---

## 14. Important Notes

1. This script retrieves Microsoft Teams membership information.

2. It does not retrieve individual Teams channel membership.

3. Standard channels inherit membership from their parent Team.

4. Private and shared channels can have separate membership configurations.

5. The script performs read-only operations.

6. No users are added to or removed from Teams.

7. Users associated with multiple Teams appear in multiple report rows.

8. The signed-in account must have sufficient permissions.

9. The report reflects membership information returned during execution.

10. Processing errors are captured in the output CSV.

11. The output CSV may contain organizational membership information and should be handled securely.

12. The script does not automatically connect to Microsoft Teams PowerShell.

---

## 15. Common Issues

### Issue 1: Get-Team Is Not Recognized

**Possible Cause:**

The Microsoft Teams PowerShell module is unavailable or not loaded.

**Resolution:**

Verify that the required Microsoft Teams PowerShell module is available.

Refer to `Backend-Settings.md` for environment requirements.

### Issue 2: Access Denied

**Possible Cause:**

The signed-in account does not have sufficient permissions.

**Resolution:**

Verify the Microsoft Teams administrative role and authentication context.

### Issue 3: No Teams Found

**Possible Causes:**

- User has no returned Team memberships.
- Incorrect user principal name.
- Limited visibility due to permissions.

**Resolution:**

Verify the user using:

```powershell
Get-Team -User user1@contoso.com
```

### Issue 4: Input CSV Not Found

**Possible Cause:**

Incorrect input file path.

**Resolution:**

Verify the configured `$UserFile` location.

### Issue 5: CSV Export Failed

**Possible Causes:**

- Insufficient folder permissions.
- Output file is locked.
- Invalid output path.

**Resolution:**

Verify the output directory and ensure the destination file is accessible.

### Issue 6: User Role Not Found

**Possible Cause:**

The Team was returned, but the user could not be matched in the membership results.

**Resolution:**

Verify the user principal name and inspect the Team membership directly.

---

## 16. Microsoft Documentation

Official Microsoft documentation:

### Microsoft Teams PowerShell

https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-managing-teams

### Get-Team

https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-team?view=teams-ps

### Get-TeamUser

https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-teamuser?view=teams-ps

### Connect-MicrosoftTeams

https://learn.microsoft.com/en-us/powershell/module/microsoftteams/connect-microsoftteams

---

## 17. Disclaimer

This PowerShell script is provided for educational, administrative, and reporting purposes.

Administrators should review and test the script in a controlled environment before executing it in production.

The script performs read-only operations and does not intentionally modify Microsoft Teams membership or configuration.

Results depend on the permissions of the authenticated account and the information returned by Microsoft Teams PowerShell.

The author is not responsible for unintended results, permission-related issues, or environmental limitations.

This repository is not officially affiliated with or endorsed by Microsoft.

---

**Microsoft 365 | Microsoft Teams | PowerShell Automation | Bulk Membership Reporting**
