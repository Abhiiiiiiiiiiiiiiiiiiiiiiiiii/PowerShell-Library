# Backend Setup Guide

## 📌 Overview

This document explains the backend configuration required before executing this automation.

The automation uses Microsoft Entra App Registration, certificate-based authentication, Microsoft Graph API, Exchange Online PowerShell module, and Azure Automation Account for secure unattended execution.

---

## 🎯 Purpose

The purpose of this backend setup is to ensure that the automation can run securely without storing usernames, passwords, or client secrets directly inside the script.

This setup is commonly used for:

- Microsoft Graph API based automation
- Exchange Online automation
- Azure Automation Runbooks
- Scheduled unattended execution
- Secure certificate-based authentication
---
## ✅ Backend Components Required

Before running the automation, the following backend components must be configured:

- Microsoft Entra App Registration & Required Microsoft Graph API permissions
- Creation of certificate for app-only authentication
- Certificate uploaded to App Registration
- Certificate stored in Azure Automation Account
- Required Microsoft Entra admin roles
- Required PowerShell modules in Azure Automation Account
- Automation variables for Tenant ID, Client ID, Certificate Name, and other reusable values
- Runbook configuration
- Schedule configuration, if automation should run automatically
---

## 📚 Official Microsoft Documentation References

Use the below official Microsoft Learn articles while performing backend configuration:

| Area | Official Microsoft Article |
|---|---|
| Register Microsoft Entra App | [Register an application in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app) |
| Add certificate/client credential to App Registration | [Add and manage application credentials in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/how-to-add-credentials) |
| Microsoft Graph app-only authentication using PowerShell | [Use app-only authentication with the Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/app-only?view=graph-powershell-1.0) |
| Build PowerShell scripts with Graph app-only authentication | [Build PowerShell scripts with Microsoft Graph and app-only authentication](https://learn.microsoft.com/en-us/graph/tutorials/powershell-app-only) |
| Exchange Online app-only authentication | [App-only authentication in Exchange Online PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/app-only-auth-powershell-v2?view=exchange-ps) |
| Assign Microsoft Entra roles | [Assign Microsoft Entra roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/manage-roles-portal) |
| Azure Automation certificates | [Manage certificates in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/shared-resources/certificates) |
| Azure Automation modules | [Manage modules in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/shared-resources/modules) |
| Azure Automation variables | [Manage variables in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/shared-resources/variables) |
| Azure Automation runbooks | [Manage runbooks in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/manage-runbooks) |
| Azure Automation schedules | [Manage schedules in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/shared-resources/schedules) |
| Azure Automation security best practices | [Security best practices in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/automation-security-guidelines) |

---

## Validation Checklist
Before executing the automation, validate the below items:

 App Registration created
 Client ID copied
 Tenant ID copied
 Certificate created
 .cer uploaded to App Registration
 .pfx uploaded to Automation Account
 Required Graph API permissions added
 Admin consent granted
 Exchange.ManageAsApp permission added if Exchange automation is used
 Exchange Administrator role assigned if required
 Compliance Administrator role assigned if required
 Required modules imported
 Automation variables created
 Runbook created
 Runbook published
 Test authentication completed
 Schedule configured

