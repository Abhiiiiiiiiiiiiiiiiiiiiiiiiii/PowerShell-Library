# Add Multiple Users to Shared Mailbox

## 📌 Overview

This PowerShell script grants **Full Access** permission to multiple users on a single Shared Mailbox in Exchange Online.

The Shared Mailbox address is specified once in the script, while the users are imported from a CSV file.

---

## ✅ Importance of This Script

When multiple users require access to the same Shared Mailbox, assigning permissions individually can be repetitive and time-consuming.

This script helps Exchange Online administrators:

- Manage one Shared Mailbox
- Add multiple users using a CSV file
- Grant Full Access permission
- Validate the Shared Mailbox before processing
- Validate each user before assigning permission
- Detect and skip existing Full Access permissions
- Continue processing when one user fails
- Display success, skipped, and failed results
- Display an execution summary
- Avoid storing administrator credentials in the script

> **Important:** This script grants **Full Access** permission only. It does not grant **Send As** or **Send on Behalf** permission.

---

## 📁 Repository Structure

```text
Bulk-Operations/SharedMailbox
│
├── AddUsers
├── Users.csv
└── README.md
```

---

## 📄 CSV File

Create a CSV file named:

```text
Users.csv
```

Use the following format:

```csv
User
user1@contoso.com
user2@contoso.com
user3@contoso.com
user4@contoso.com
user5@contoso.com
```

The CSV file contains only one column:

```text
User
```

Each row represents one user who requires Full Access permission to the Shared Mailbox.

> Replace the fictional `contoso.com` addresses with approved user addresses from your environment.

---

## 💻 PowerShell Script

Save the following script as:

```text
Add-UsersToSharedMailbox.ps1
```

```powershell
<#
.SYNOPSIS
Grants Full Access permission to multiple users
on one Shared Mailbox.

.DESCRIPTION
The script imports users from a CSV file and grants
Full Access permission to each user on one Shared Mailbox.

Users who already have Full Access are skipped.
#>

# ============================================
# Configuration
# ============================================

$SharedMailbox = "support@contoso.com"
$CsvPath = Join-Path $PSScriptRoot "Users.csv"

# Change to $true if Outlook AutoMapping is required
$AutoMapping = $false

# ============================================
# Connect to Exchange Online
# ============================================

try {
    Connect-ExchangeOnline `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Host "Connected to Exchange Online." `
        -ForegroundColor Green
}
catch {
    Write-Host "Failed to connect to Exchange Online." `
        -ForegroundColor Red

    Write-Host "Reason: $($_.Exception.Message)" `
        -ForegroundColor Red

    return
}

try {
    # ============================================
    # Validate CSV File
    # ============================================

    if (-not (Test-Path -Path $CsvPath)) {
        throw "CSV file not found: $CsvPath"
    }

    $Users = Import-Csv `
        -Path $CsvPath `
        -ErrorAction Stop

    if (-not $Users) {
        throw "The CSV file does not contain any users."
    }

    if ("User" -notin $Users[0].PSObject.Properties.Name) {
        throw "The CSV file must contain a column named User."
    }

    Write-Host "CSV file imported successfully." `
        -ForegroundColor Green

    Write-Host "Users imported: $($Users.Count)" `
        -ForegroundColor Cyan

    # ============================================
    # Validate Shared Mailbox
    # ============================================

    $Mailbox = Get-Mailbox `
        -Identity $SharedMailbox `
        -ErrorAction Stop

    if ($Mailbox.RecipientTypeDetails -ne "SharedMailbox") {
        throw "$SharedMailbox is not a Shared Mailbox."
    }

    Write-Host "`nShared Mailbox validated successfully." `
        -ForegroundColor Green

    Write-Host "Shared Mailbox: $SharedMailbox" `
        -ForegroundColor Cyan

    # ============================================
    # Result Counters
    # ============================================

    $SuccessCount = 0
    $SkippedCount = 0
    $FailedCount = 0

    # ============================================
    # Process Users
    # ============================================

    foreach ($Entry in $Users) {

        $User = $Entry.User

        try {
            # Validate the CSV value
            if ([string\]::IsNullOrWhiteSpace($User)) {
                throw "User value is empty."
            }

            $User = $User.Trim()

            Write-Host "`n----------------------------------------" `
                -ForegroundColor DarkGray

            Write-Host "Processing User: $User" `
                -ForegroundColor Cyan

            # ============================================
            # Validate User
            # ============================================

            $Recipient = Get-Recipient `
                -Identity $User `
                -ErrorAction Stop

            Write-Host "User validated successfully." `
                -ForegroundColor DarkGreen

            # ============================================
            # Check Existing Full Access
            # ============================================

            $ExistingPermission = Get-MailboxPermission `
                -Identity $SharedMailbox `
                -User $Recipient.
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.AccessRights -contains "FullAccess" -and
                    $_.IsInherited -eq $false -and
                    $_.Deny -eq $false
                }

            # ============================================
            # Skip Existing Permission
            # ============================================

            if ($ExistingPermission) {
                Write-Host "SKIPPED: $User already has Full Access." `
                    -ForegroundColor Yellow

                $SkippedCount++

                continue
            }

            # ============================================
            # Grant Full Access
            # ============================================

            Add-MailboxPermission `
                -Identity $SharedMailbox `
                -User $Recipient.Identity `
                -AccessRights FullAccess `
                -InheritanceType All `
                -AutoMapping $AutoMapping `
                -ErrorAction Stop |
                Out-Null

            Write-Host "SUCCESS: Added Full Access for $User" `
                -ForegroundColor Green

            $SuccessCount++
        }
        catch {
            Write-Host "FAILED: $User" `
                -ForegroundColor Red

            Write-Host "Reason: $($_.Exception.Message)" `
                -ForegroundColor Red

            $FailedCount++
        }
    }

    # ============================================
    # Execution Summary
    # ============================================

    Write-Host "`n========================================" `
        -ForegroundColor Cyan

    Write-Host "Execution Summary" `
        -ForegroundColor Cyan

    Write-Host "========================================" `
        -ForegroundColor Cyan

    Write-Host "Shared Mailbox : $SharedMailbox"

    Write-Host "Successful     : $SuccessCount" `
        -ForegroundColor Green

    Write-Host "Skipped        : $SkippedCount" `
        -ForegroundColor Yellow

    Write-Host "Failed         : $FailedCount" `
        -ForegroundColor Red
}
catch {
    Write-Host "`nScript execution failed." `
        -ForegroundColor Red

    Write-Host "Reason: $($_.Exception.Message)" `
        -ForegroundColor Red
}
finally {
    # ============================================
    # Disconnect Exchange Online
    # ============================================

    Disconnect-ExchangeOnline `
        -Confirm:$false `
        -ErrorAction SilentlyContinue

    Write-Host "`nDisconnected from Exchange Online." `
        -ForegroundColor Cyan
}
```

---

## 🔧 Configure the Shared Mailbox

Open:

```text
Add-UsersToSharedMailbox.ps1
```

Find the following configuration:

```powershell
$SharedMailbox = "support@contoso.com"
```

Replace the sample address with the required Shared Mailbox address:

```powershell
$SharedMailbox = "sharedmailbox@contoso.com"
```

The Shared Mailbox needs to be specified only once.

---

## ▶️ How to Use the Script

### Step 1: Create the Project Folder

Create a folder named:

```text
Shared-Mailbox-Bulk-User-Access
```

### Step 2: Create the Required Files

Save the following files in the project folder:

```text
Add-UsersToSharedMailbox.ps1
Users.csv
README.md
```

### Step 3: Update the Shared Mailbox

Open `Add-UsersToSharedMailbox.ps1` and update:

```powershell
$SharedMailbox = "support@contoso.com"
```

Example:

```powershell
$SharedMailbox = "helpdesk@contoso.com"
```

### Step 4: Update the CSV File

Open:

```text
Users.csv
```

Add the required users:

```csv
User
user1@contoso.com
user2@contoso.com
user3@contoso.com
```

Do not change the CSV header:

```text
User
```

### Step 5: Open PowerShell

Navigate to the project folder:

```powershell
cd "C:\Scripts\Shared-Mailbox-Bulk-User-Access"
```

### Step 6: Run the Script

```powershell
.\Add-UsersToSharedMailbox.ps1
```

### Step 7: Sign In

When prompted, sign in using an Exchange Online administrator account with the required mailbox-management permissions.

### Step 8: Review the Results

The script displays the result for every user.

Successful assignment:

```text
SUCCESS: Added Full Access for user1@contoso.com
```

Existing permission:

```text
SKIPPED: user2@contoso.com already has Full Access.
```

Failed assignment:

```text
FAILED: user3@contoso.com
Reason: The specified user could not be found.
```

---

## 📊 Execution Summary

After processing all users, the script displays a summary:

```text
========================================
Execution Summary
========================================
Shared Mailbox : support@contoso.com
Successful     : 3
Skipped        : 1
Failed         : 1
```

The values indicate:

- `Successful`: Users who received Full Access
- `Skipped`: Users who already had Full Access
- `Failed`: Users who could not be processed

---

## 🔍 Verify Full Access Permissions

Use the following command to view explicitly assigned Full Access permissions on the Shared Mailbox:

```powershell
Get-MailboxPermission `
    -Identity "support@contoso.com" |
    Where-Object {
        $_.AccessRights -contains "FullAccess" -and
        $_.IsInherited -eq $false -and
        $_.Deny -eq $false
    } |
    Format-Table User,AccessRights,Deny,IsInherited -AutoSize
```

Replace:

```text
support@contoso.com
```

with the correct Shared Mailbox address.

---

## 🔄 AutoMapping

The script uses the following configuration:

```powershell
$AutoMapping = $false
```

This prevents the Shared Mailbox from being automatically added to the user's Outlook profile when Full Access is granted.

To enable AutoMapping, change the configuration to:

```powershell
$AutoMapping = $true
```

The permission assignment will then use:

```powershell
Add-MailboxPermission `
    -Identity $SharedMailbox `
    -User $Recipient.Identity `
    -AccessRights FullAccess `
    -InheritanceType All `
    -AutoMapping $AutoMapping `
    -ErrorAction Stop
```

> Changing AutoMapping affects new Full Access assignments performed by the script.

---

## 🔁 Workflow

```text
Start Script
     │
     ▼
Connect to Exchange Online
     │
     ▼
Import Users.csv
     │
     ▼
Validate Shared Mailbox
     │
     ▼
Read First User
     │
     ▼
Validate User
     │
     ▼
Check Existing Permission
     │
     ├── Permission Exists
     │         │
     │         ▼
     │       Skip User
     │
     └── Permission Does Not Exist
               │
               ▼
        Grant Full Access
               │
               ▼
         Display Result
               │
               ▼
       Process Next User
               │
               ▼
       Display Final Summary
               │
               ▼
    Disconnect Exchange Online
```

---

## 📌 Expected Result

After successful execution:

- Users receive Full Access permission to the Shared Mailbox
- Users can open and manage the Shared Mailbox contents
- Existing Full Access permissions are skipped
- Failed entries do not stop the remaining users from being processed
- AutoMapping follows the value configured in `$AutoMapping`
- Send As permission remains unchanged
- Send on Behalf permission remains unchanged

---

## ⚠️ Important Notes

- The script manages only one Shared Mailbox per execution
- The CSV file should contain users only
- Keep the CSV column name exactly as `User`
- Full Access is the only permission assigned
- Send As permission is not assigned
- Send on Behalf permission is not assigned
- Test the script with a small CSV file first
- Verify the Shared Mailbox address before running the script
- Confirm that all users in the CSV are correct
- Do not include empty rows in the CSV
- Review skipped and failed entries after execution
- Do not store administrator credentials in the script
- Do not publish real organizational email addresses in a public repository

---

## 🛠️ Common Issues

### CSV File Not Found

Confirm that both files are saved in the same folder:

```text
Add-UsersToSharedMailbox.ps1
Users.csv
```

The script uses:

```powershell
$CsvPath = Join-Path $PSScriptRoot "Users.csv"
```

This automatically looks for `Users.csv` in the same folder as the script.

---

### Incorrect CSV Header

The CSV header must be:

```csv
User
```

Do not use headers such as:

```text
Users
Email
EmailAddress
UserPrincipalName
```

---

### Shared Mailbox Not Found

Confirm the Shared Mailbox address configured in the script:

```powershell
$SharedMailbox = "support@contoso.com"
```

You can verify it using:

```powershell
Get-Mailbox -Identity "support@contoso.com"
```

---

### User Not Found

Verify the affected user:

```powershell
Get-Recipient -Identity "user1@contoso.com"
```

---

### Permission Already Exists

The script checks existing Full Access permission before adding it.

If the permission already exists, the user is skipped:

```text
SKIPPED: user1@contoso.com already has Full Access.
```

---

## 📚 Microsoft Documentation

- [Manage permissions for recipients in Exchange Online](https://learn.microsoft.com/en-us/exchange/recipients-in-exchange-online/manage-permissions-for-recipients)
- https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/add-mailboxpermission
- https://learn.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell

---

## Disclaimer

Test this script with a small group of users before using it for a larger production change.

Review the Shared Mailbox address, CSV input, Full Access requirement, and AutoMapping configuration before executing the script.
