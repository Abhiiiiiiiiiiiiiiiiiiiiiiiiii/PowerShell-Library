#BitLocker key inventory script for Azure Automation Version 1.0
#Requires -Modules MSAL.PS

param(
    [ValidateSet("Present", "NotPresent")]
    [string]$State = "NotPresent"
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ===============================
# Azure Automation assets
# ===============================
$TenantId = Get-AutomationVariable -Name 'TenantId'
$ClientId = Get-AutomationVariable -Name 'AppClientId'
$Cert     = Get-AutomationCertificate -Name 'BitLocker Certificate'

if (-not $TenantId -or -not $ClientId -or -not $Cert) {
    throw "Missing Automation Variable or Certificate."
}

# ===============================
# App-only auth (MSAL.PS)
# ===============================
$token = Get-MsalToken `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientCertificate $Cert `
    -ErrorAction Stop

$Headers = @{
    Authorization = $token.CreateAuthorizationHeader()
    "Content-Type" = "application/json"
}

# ===============================
# Helper: Graph paging
# ===============================
function Get-AllGraphPages {
    param(
        [hashtable]$Headers,
        [string]$Url
    )

    $results = @()
    while ($Url) {
        $resp = Invoke-RestMethod -Method GET -Uri $Url -Headers $Headers -ErrorAction Stop
        if ($resp.value) { $results += $resp.value }
        $Url = $resp.'@odata.nextLink'
    }
    return $results
}

# ===============================
# 1) Intune Windows devices (A)
# ===============================
$devicesUrl =
"https://graph.microsoft.com/beta/deviceManagement/managedDevices?" +
"`$filter=operatingSystem eq 'Windows'&" +
"`$select=id,deviceName,azureADDeviceId"

$ManagedDevices = Get-AllGraphPages -Headers $Headers -Url $devicesUrl
Write-Output "Total Intune Windows devices: $($ManagedDevices.Count)"

# ===============================
# 2) BitLocker recovery keys (B)
# ===============================
$keysUrl =
"https://graph.microsoft.com/beta/informationProtection/bitlocker/recoveryKeys?" +
"`$select=deviceId"

$BitLockerKeys = Get-AllGraphPages -Headers $Headers -Url $keysUrl
Write-Output "Total BitLocker recovery key records: $($BitLockerKeys.Count)"

# ===============================
# ✅ FIX: Case‑insensitive lookup set
# ===============================
$KeyDeviceIds = New-Object System.Collections.Generic.HashSet[string] `
    ([System.StringComparer]::OrdinalIgnoreCase)

foreach ($k in $BitLockerKeys) {
    if ($k.deviceId) {
        $KeyDeviceIds.Add($k.deviceId) | Out-Null
    }
}

# ===============================
# 3) Result set C = A − B
# ===============================
$Result = @($ManagedDevices | Where-Object {
    if (-not $_.azureADDeviceId) { return $false }

    $hasKey = $KeyDeviceIds.Contains($_.azureADDeviceId)

    if ($State -eq "Present") {
        $hasKey
    }
    else {
        -not $hasKey
    }
} | Select-Object deviceName, id, azureADDeviceId
)

# ===============================
# Output (Azure Automation‑safe)
# ===============================
Write-Output "========================================"
Write-Output "RESULT SET C (A - B)"
Write-Output "Devices MISSING BitLocker recovery keys"
Write-Output "========================================"
Write-Output "Total devices in Result set C: $($Result.Count)"
Write-Output ""

if ($Result.Count -eq 0) {
    Write-Output "✅ No devices missing BitLocker recovery keys."
}
else {
    foreach ($device in $Result) {
        Write-Output ("DeviceName      : {0}" -f $device.deviceName)
        Write-Output ("IntuneDeviceId  : {0}" -f $device.id)
        Write-Output ("AzureADDeviceId : {0}" -f $device.azureADDeviceId)
        Write-Output "----------------------------------------"
    }
}

Write-Output "=== Script execution completed successfully ==="
# ===============================
# 4) Send report by email as CSV attachment using app-only Mail.Send
# ===============================
# Automation variable 'ReportMailbox' should contain the mailbox address to send as
$ReportMailbox = Get-AutomationVariable -Name 'ReportMailbox' -ErrorAction SilentlyContinue

if (-not $ReportMailbox) {
    Write-Output "No 'ReportMailbox' Automation Variable found. Skipping email send."
}
else {
    try {
        $subject = "BitLocker missing key report - $(Get-Date -Format 'yyyy-MM-dd')"

        # Build CSV content
        $header = 'DeviceName,IntuneDeviceId,AzureADDeviceId'
        $lines = @()

        if ($Result.Count -eq 0) {
            $lines += 'All devices have BitLocker recovery keys registered.'
            $csv = $lines -join "`r`n"
        }
        else {
            foreach ($d in $Result) {
                $fn = ($d.deviceName -replace '"', '""')
                $id = ($d.id -replace '"', '""')
                $aad = ($d.azureADDeviceId -replace '"', '""')
                $lines += '"' + $fn + '","' + $id + '","' + $aad + '"'
            }
            $csv = $header + "`r`n" + ($lines -join "`r`n")
        }

        # Create file attachment (base64 encoded)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($csv)
        $base64 = [System.Convert]::ToBase64String($bytes)

        $attachment = @{ '@odata.type' = '#microsoft.graph.fileAttachment';
                         name = 'BitLockerMissingKeys.csv';
                         contentType = 'text/csv';
                         contentBytes = $base64 }

        $bodyText = if ($Result.Count -eq 0) { 'No missing BitLocker keys. See attachment for details.' } else { 'Attached: devices missing BitLocker recovery keys.' }

        $message = @{
            subject = $subject
            body = @{ contentType = 'Text'; content = $bodyText }
            toRecipients = @(@{ emailAddress = @{ address = $ReportMailbox } })
            attachments = @($attachment)
        }

        $mailJson = $message | ConvertTo-Json -Depth 8
        $sendUrl = "https://graph.microsoft.com/v1.0/users/$ReportMailbox/sendMail"

        Write-Output "Sending CSV report to $ReportMailbox..."
        Invoke-RestMethod -Method POST -Uri $sendUrl -Headers $Headers -Body $mailJson -ErrorAction Stop
        Write-Output "Email (with CSV attachment) sent to $ReportMailbox."
    }
    catch {
        Write-Output "Failed to send email report: $($_.Exception.Message)"
    }
}

exit 0
