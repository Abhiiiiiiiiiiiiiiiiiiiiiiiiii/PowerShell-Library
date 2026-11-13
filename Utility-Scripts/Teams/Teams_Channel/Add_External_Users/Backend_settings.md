# Backend Setup Guide

## 📌 Overview

This document explains the backend configuration and dependencies required before executing the Microsoft 365 Group Guest Membership Management automation.

The script uses Microsoft Graph PowerShell with delegated authentication to configure the `AllowToAddGuests` property within the `Group.Unified.Guest` setting.

Guest collaboration in Microsoft 365 depends on multiple configuration layers.

Enabling guest membership for an individual Microsoft 365 Group does not automatically enable external collaboration across the organization.

---

## 🎯 Purpose

The purpose of this backend setup is to ensure that administrators can securely manage Microsoft 365 Group guest membership while understanding the dependencies that may affect external collaboration.

This setup is commonly used for:

- Microsoft 365 Group guest membership management
- Microsoft Entra B2B collaboration
- Guest access troubleshooting
- External collaboration configuration reviews
- Microsoft Teams guest access troubleshooting
- SharePoint external sharing troubleshooting
- Cross-tenant collaboration verification
- Group-level guest access administration

---

## ✅ Backend Components Required

Before executing the automation, review the following components:

1. Microsoft Graph PowerShell authentication
2. Microsoft Graph delegated permissions
3. Microsoft Entra administrative roles
4. Microsoft 365 Group validation
5. Microsoft Entra B2B collaboration settings
6. Microsoft Entra cross-tenant access settings
7. Microsoft 365 Groups tenant-wide guest settings
8. Microsoft Teams guest access settings, if applicable
9. SharePoint external sharing settings, if applicable
10. Sensitivity labels and Conditional Access policies, if applicable

Not every dependency requires modification.

Administrators should review only the settings relevant to the intended collaboration scenario.

---

## 1. Microsoft Graph Authentication

The automation uses delegated Microsoft Graph authentication.

Required PowerShell modules:

- Microsoft.Graph.Authentication
- Microsoft.Graph.Groups

The script automatically checks whether these modules are available.

### Required Delegated Permissions

```text
Group.Read.All
GroupSettings.ReadWrite.All
```

### Permission Purpose

| Permission | Purpose |
|---|---|
| Group.Read.All | Retrieve and identify Microsoft 365 Groups |
| GroupSettings.ReadWrite.All | Read, create, and update group settings |

### Authentication Method

```powershell
Connect-MgGraph `
    -Scopes "Group.Read.All","GroupSettings.ReadWrite.All"
```

The script automatically initiates authentication when the required Microsoft Graph session is unavailable.

### Important

Microsoft Graph delegated permissions and Microsoft Entra administrative roles are separate authorization requirements.

Having the correct Graph permissions does not automatically grant the signed-in user sufficient administrative privileges.

---

## 2. Microsoft Entra Administrative Roles

For managing Microsoft 365 Group guest settings, the recommended administrative role is:

**Groups Administrator**

This role supports management of Microsoft 365 Group settings, including Group.Unified.Guest configurations.

Other roles or custom role assignments may support specific operations depending on the permissions granted.

### Recommended Configuration

- Assign the Groups Administrator role to an authorized administrator.
- Use least-privilege access.
- Avoid using Global Administrator unnecessarily.
- Verify that the Microsoft Graph application has the required delegated permissions.

---

## 3. Microsoft 365 Group Validation

The target group must be a Microsoft 365 Group.

Microsoft 365 Groups contain the following value in their GroupTypes property:

```text
Unified
```

### Verify the Group

```powershell
Get-MgGroup `
    -GroupId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" `
    -Property Id,DisplayName,GroupTypes
```

### Expected Result

```text
GroupTypes : {Unified}
```

### Important

The automation does not support:

- Security Groups
- Distribution Lists
- Mail-enabled Security Groups

Use the Microsoft Entra Group Object ID whenever possible.

---

## 4. Microsoft Entra B2B Collaboration Settings

Microsoft Entra B2B collaboration allows external users to access resources shared by an organization.

These settings control external guest invitations and collaboration restrictions.

### Configuration Location

Microsoft Entra Admin Center

```text
Microsoft Entra ID
    |
    External Identities
    |
    External collaboration settings
```

### Settings to Review

#### Guest User Access

Determine the level of directory information that guest users can access.

#### Guest Invite Settings

Verify which users or administrative roles are permitted to invite external users.

#### Collaboration Restrictions

Review whether external domains are:

- Allowed
- Blocked
- Restricted through organizational policies

### Important

If external invitations are restricted by Microsoft Entra policies, enabling AllowToAddGuests for a Microsoft 365 Group does not override those restrictions.

---

## 5. Microsoft Entra Cross-Tenant Access Settings

Cross-tenant access settings control B2B collaboration between Microsoft Entra organizations.

### Configuration Location

```text
Microsoft Entra Admin Center
    |
    External Identities
    |
    Cross-tenant access settings
```

### Settings to Review

#### Default Settings

Review the default inbound and outbound B2B collaboration configuration.

#### Organizational Settings

Check whether specific external organizations have customized policies.

#### Inbound Access

Controls whether external identities can access resources in your tenant.

#### Outbound Access

Controls whether users from your tenant can access resources in external organizations.

### Important

For collaboration with another Microsoft Entra tenant, relevant inbound and outbound access policies must permit the intended scenario.

A group-level guest setting cannot override cross-tenant restrictions.

---

## 6. Microsoft 365 Groups Tenant-Wide Guest Settings

Microsoft 365 Groups have organization-wide guest access controls.

### Configuration Location

```text
Microsoft 365 Admin Center
    |
    Settings
    |
    Org settings
    |
    Microsoft 365 Groups
```

### Settings to Review

- Whether people outside the organization can access group resources.
- Whether group owners can add external users to groups.

### Important

The automation modifies the guest setting for an individual Microsoft 365 Group.

It does not modify tenant-wide Microsoft 365 Groups guest access policies.

Tenant-wide restrictions may prevent the intended guest collaboration scenario even when the group-specific setting is enabled.

---

## 7. Microsoft Teams Guest Access Dependencies

If the Microsoft 365 Group is associated with Microsoft Teams, additional guest access settings may apply.

### Configuration Location

```text
Microsoft Teams Admin Center
    |
    Users
    |
    Guest access
```

### Settings to Review

- Whether guest access is enabled.
- Applicable guest permissions and capabilities.
- Relevant organizational policies.
- Whether the guest has been added to the Team.

### Important

Enabling Microsoft 365 Group guest membership does not automatically configure Microsoft Teams guest access.

The Microsoft Teams guest access configuration must independently support the intended collaboration scenario.

---

## 8. SharePoint External Sharing Dependencies

Microsoft 365 Groups can have associated SharePoint sites.

Guest access to SharePoint resources depends on the organization's external sharing configuration.

### Configuration Location

```text
SharePoint Admin Center
    |
    Policies
    |
    Sharing
```

### Settings to Review

- Organization-level external sharing.
- Site-level external sharing.
- External sharing restrictions.
- Allowed or blocked domains.
- Existing guest permissions.

### Important

SharePoint site-level sharing cannot be more permissive than the organization's external sharing policy.

Enabling guest membership for a Microsoft 365 Group does not automatically enable SharePoint external sharing.

---

## 9. Sensitivity Labels and Conditional Access

Organizations may apply additional security controls to Microsoft 365 Groups and external identities.

### Sensitivity Labels

Sensitivity labels can control external collaboration settings for Microsoft 365 Groups and associated Teams or SharePoint sites.

Administrators should verify whether the target group has a sensitivity label that restricts guest access.

### Conditional Access

Conditional Access policies may restrict guest sign-in based on organizational security requirements.

Examples include:

- Multifactor authentication requirements
- Device compliance requirements
- Sign-in risk restrictions
- Application access restrictions

### Important

The automation does not modify sensitivity labels or Conditional Access policies.

These controls must be reviewed separately when troubleshooting guest access.

---

## 10. Group.Unified.Guest Configuration

The automation manages the following Microsoft 365 Group setting:

```text
Group.Unified.Guest
```

### Setting Name

```text
AllowToAddGuests
```

### Supported Values

| Value | Description |
|---|---|
| True | Allows guest additions at the group-specific setting level |
| False | Restricts guest additions through the applicable group setting |

### Group Setting Template ID

```text
08d542b9-071f-4e16-94b0-74abb372e3d9
```

### Important

The setting controls guest additions at the Microsoft 365 Group level.

It does not automatically:

- Invite external users.
- Create Microsoft Entra B2B guest accounts.
- Add guests to the group.
- Remove existing guest members.
- Revoke existing guest access.
- Modify cross-tenant access policies.
- Enable Microsoft Teams guest access.
- Enable SharePoint external sharing.

---

## 📚 Official Microsoft Documentation References

Use the following Microsoft Learn documentation when reviewing backend configuration.

| Area | Official Microsoft Documentation |
|---|---|
| Microsoft 365 Group Settings | [Configure Group Settings Using PowerShell](https://learn.microsoft.com/en-us/entra/identity/users/groups-settings-cmdlets) |
| Microsoft Graph Group Settings | [Update Group Settings](https://learn.microsoft.com/en-us/graph/api/groupsetting-update?view=graph-rest-1.0) |
| Create Group Settings | [Create Group Settings](https://learn.microsoft.com/en-us/graph/api/group-post-settings?view=graph-rest-1.0) |
| Microsoft 365 Groups Guest Access | [Manage Guest Access in Microsoft 365 Groups](https://learn.microsoft.com/en-us/microsoft-365/admin/create-groups/manage-guest-access-in-groups?view=o365-worldwide) |
| Microsoft Entra B2B Collaboration | [Configure External Collaboration](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure) |
| Cross-Tenant Access | [Cross-Tenant Access Settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration) |
| External Collaboration Overview | [Microsoft 365 External Collaboration](https://learn.microsoft.com/en-us/microsoft-365/enterprise/external-guest-access) |
| Teams and SharePoint External Access | [Secure External Access to Teams and SharePoint](https://learn.microsoft.com/en-us/entra/architecture/9-secure-access-teams-sharepoint) |

---

## ✅ Validation Checklist

Before executing the automation, validate the following requirements.

### Microsoft Graph Authentication

- [ ] Microsoft.Graph.Authentication module available
- [ ] Microsoft.Graph.Groups module available
- [ ] Microsoft Graph authentication successful
- [ ] Correct Microsoft 365 tenant selected
- [ ] Required delegated permissions granted

### Microsoft Graph Permissions

- [ ] Group.Read.All available
- [ ] GroupSettings.ReadWrite.All available
- [ ] Required consent granted

### Administrative Roles

- [ ] Authorized administrator account available
- [ ] Groups Administrator role assigned where required
- [ ] Least-privilege requirements reviewed

### Microsoft 365 Group Validation

- [ ] Target group exists
- [ ] Group Object ID verified
- [ ] GroupTypes contains Unified
- [ ] Group display name verified
- [ ] Existing guest membership setting reviewed

### Microsoft Entra B2B Collaboration

- [ ] External collaboration settings reviewed
- [ ] Guest invitation permissions reviewed
- [ ] Allowed or blocked domain restrictions reviewed
- [ ] Guest account requirements verified

### Cross-Tenant Access

- [ ] Inbound B2B collaboration settings reviewed
- [ ] Outbound B2B collaboration settings reviewed
- [ ] Organization-specific restrictions reviewed
- [ ] Relevant external tenant collaboration permitted

### Microsoft 365 Groups Settings

- [ ] Tenant-wide guest access settings reviewed
- [ ] Group owner guest invitation settings reviewed
- [ ] Group-specific AllowToAddGuests configuration reviewed

### Microsoft Teams Dependencies

If the group is associated with Microsoft Teams:

- [ ] Teams guest access settings reviewed
- [ ] Relevant Teams policies reviewed
- [ ] Guest membership requirements verified

### SharePoint Dependencies

If SharePoint collaboration is required:

- [ ] Organization-level external sharing reviewed
- [ ] Site-level external sharing reviewed
- [ ] Sharing restrictions reviewed
- [ ] Guest access requirements verified

### Security Policies

- [ ] Sensitivity label restrictions reviewed
- [ ] Conditional Access requirements reviewed
- [ ] Organizational security approval obtained where required

### Final Validation

- [ ] Test execution completed using WhatIf
- [ ] Target Microsoft 365 Group verified
- [ ] Requested AllowToAddGuests value confirmed
- [ ] Script executed successfully
- [ ] Post-change verification completed
- [ ] Group setting returned the expected value
- [ ] External collaboration tested separately, if required

---

## 🔐 Security Considerations

- Use least-privileged administrative roles.
- Obtain appropriate approvals before enabling external collaboration.
- Avoid unnecessary Global Administrator access.
- Review tenant-wide guest access policies.
- Validate cross-tenant collaboration restrictions.
- Review Conditional Access and sensitivity label requirements.
- Do not store authentication credentials in the script.
- Test changes using WhatIf before production execution.
- Record changes according to organizational change management procedures.
