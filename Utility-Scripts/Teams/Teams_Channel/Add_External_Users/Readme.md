# Microsoft 365 Group Guest Membership Management

## 📌 Overview

This PowerShell automation enables or disables guest membership for a specific Microsoft 365 Group using Microsoft Graph PowerShell.

The script manages the `AllowToAddGuests` property within the `Group.Unified.Guest` group setting.

Administrators can identify the target Microsoft 365 Group using either:

- Microsoft Entra Group Object ID (recommended)
- Exact Microsoft 365 Group Display Name

The automation supports secure delegated authentication, group validation, error handling, WhatIf simulation, and post-change verification.

---

## ✅ Problem Statement

Managing external guest membership in Microsoft 365 Groups involves multiple administrative settings and dependencies.

Even when guest membership is enabled for a specific Microsoft 365 Group, external users may still experience access issues because guest collaboration is controlled by multiple Microsoft 365 services.

These dependencies can include:

- Microsoft Entra B2B collaboration settings
- External collaboration restrictions
- Cross-tenant access policies
- Microsoft 365 Groups guest access settings
- Microsoft Teams guest access policies
- SharePoint external sharing settings
- Sensitivity labels and Conditional Access policies

Manually managing group-specific guest membership settings can become difficult when administrators need to verify existing configurations, prevent unintended changes, and troubleshoot external collaboration issues.

---

## 💡 Solution

This automation provides a controlled method for managing guest membership at the individual Microsoft 365 Group level.

The script:

- Connects securely to Microsoft Graph.
- Validates the required delegated permissions.
- Identifies the target Microsoft 365 Group.
- Confirms that the group is a Microsoft 365 Group.
- Retrieves the existing `Group.Unified.Guest` configuration.
- Creates the setting if it does not exist.
- Updates the setting when required.
- Preserves other existing setting values.
- Supports `-WhatIf` and `-Confirm`.
- Verifies the configuration after modification.
- Returns a structured execution result.

### Important

This automation manages only the group-level `AllowToAddGuests` setting.

It does not automatically modify Microsoft Entra B2B collaboration settings, cross-tenant access policies, Microsoft Teams guest access, SharePoint external sharing, or Conditional Access policies.

These dependencies must be reviewed separately.

---

## ⚙️ Key Features

- Uses **Microsoft Graph PowerShell**
- Supports **Microsoft Entra Group Object ID**
- Supports **exact Group Display Name**
- Enables or disables **guest membership**
- Uses **delegated Microsoft Graph authentication**
- Validates **Microsoft 365 Group type**
- Creates missing **Group.Unified.Guest settings**
- Updates existing **AllowToAddGuests values**
- Preserves other existing setting values
- Prevents unnecessary updates
- Supports **WhatIf simulation**
- Supports **confirmation before modification**
- Performs **post-change verification**
- Returns a **structured result object**
- Provides error handling and verbose execution details

---

## 🔁 Workflow

1. Validate required Microsoft Graph PowerShell modules.
2. Connect to Microsoft Graph using delegated permissions.
3. Verify the authenticated Microsoft Graph session.
4. Identify the target group using Object ID or Display Name.
5. Validate that the target is a Microsoft 365 Group.
6. Retrieve existing Group.Unified.Guest settings.
7. Check the current AllowToAddGuests value.
8. Compare the current value with the requested configuration.
9. Create or update the setting when required.
10. Verify the updated configuration using Microsoft Graph.
11. Return the execution result.

---

## 📊 Output

The automation returns a structured PowerShell object containing the following information:

| Property | Description |
|---|---|
| Status | Execution status |
| Operation | Created, Updated, NoChange, or WhatIfOrDeclined |
| GroupDisplayName | Microsoft 365 Group display name |
| GroupId | Microsoft Entra Group Object ID |
| PreviousAllowToAddGuests | Previous guest membership configuration |
| RequestedAllowToAddGuests | Requested configuration |
| VerifiedAllowToAddGuests | Verified configuration after execution |
| Changed | Indicates whether a modification occurred |
| TimestampUtc | Execution timestamp in UTC |

### Example Output

```text
Status                     : Success
Operation                  : Updated
GroupDisplayName           : EUC Support Team
GroupId                    : aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
PreviousAllowToAddGuests   : False
RequestedAllowToAddGuests  : True
VerifiedAllowToAddGuests   : True
Changed                    : True
TimestampUtc               : 2026-11-13 12:00:00
```

The above output is illustrative.

### Supported Operations

| Operation | Description |
|---|---|
| Created | Guest setting was created |
| Updated | Existing guest setting was modified |
| NoChange | Requested configuration already exists |
| WhatIfOrDeclined | Modification was simulated or declined |

### Important Behavior

Setting `AllowToAddGuests` to `$true` allows guest membership at the group-specific setting level.

Setting it to `$false` restricts guest additions through the applicable group policy.

However, this does not automatically remove existing guest members or revoke their existing access.

The setting also does not override tenant-level external collaboration restrictions.

---

## ▶️ How to Run

### Step 1: Open PowerShell

Open a supported PowerShell environment.

Ensure the required Microsoft Graph PowerShell modules are available.

### Step 2: Enable Guest Membership Using Group ID

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -AllowToAddGuests $true
```

### Step 3: Disable Guest Membership Using Group ID

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -AllowToAddGuests $false
```

### Step 4: Enable Guest Membership Using Group Name

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupName "EUC Support Team" `
    -AllowToAddGuests $true
```

### Step 5: Disable Guest Membership Using Group Name

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupName "EUC Support Team" `
    -AllowToAddGuests $false
```

### Step 6: Simulate the Change

Before modifying the configuration, use WhatIf:

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupName "EUC Support Team" `
    -AllowToAddGuests $true `
    -WhatIf
```

This displays the proposed action without applying the modification.

### Step 7: Request Confirmation

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupName "EUC Support Team" `
    -AllowToAddGuests $false `
    -Confirm
```

### Step 8: Enable Verbose Output

```powershell
.\Set-M365GroupGuestMembership.ps1 `
    -GroupName "EUC Support Team" `
    -AllowToAddGuests $true `
    -Verbose
```

### Default Behavior

If `-AllowToAddGuests` is not specified, the script defaults to:

```powershell
-AllowToAddGuests $true
```

### Backend Requirements

For Microsoft Graph permissions, administrative roles, B2B collaboration dependencies, and validation requirements, refer to:

**Backend-Settings.md**

---

## ⚠️ Important Notes

- This script supports Microsoft 365 Groups only.
- Security groups and distribution lists are not supported.
- Group Object ID is recommended to avoid duplicate display names.
- The script does not invite guest users.
- The script does not add or remove group members.
- The script does not modify tenant-wide B2B policies.
- The script does not modify Teams or SharePoint guest settings.
- Existing guest access is not automatically revoked when guest additions are disabled.
- Administrators should validate external collaboration dependencies before enabling guest membership.

---

## 📚 Microsoft Documentation

- [Configure Group Settings Using PowerShell](https://learn.microsoft.com/en-us/entra/identity/users/groups-settings-cmdlets)
- [Manage Guest Access in Microsoft 365 Groups](https://learn.microsoft.com/en-us/microsoft-365/admin/create-groups/manage-guest-access-in-groups?view=o365-worldwide)
- [Microsoft Entra External Collaboration Settings](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure)
- [Cross-Tenant Access Settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration)
- [Microsoft Graph Group Settings](https://learn.microsoft.com/en-us/graph/api/groupsetting-update?view=graph-rest-1.0)

---

## ⚠️ Disclaimer

This PowerShell automation is provided for educational and Microsoft 365 administrative purposes.

Administrators should review organizational guest access policies and obtain the necessary approvals before modifying Microsoft 365 Group settings.

Enabling group-level guest membership does not guarantee that external users can access Microsoft Teams, SharePoint, or other Microsoft 365 resources.

The automation should be tested in a controlled environment before production execution.

This repository is not officially affiliated with or endorsed by Microsoft.
