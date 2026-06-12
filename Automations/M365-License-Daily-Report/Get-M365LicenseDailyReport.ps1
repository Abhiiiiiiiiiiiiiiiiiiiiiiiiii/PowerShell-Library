# Certificate based Authentication for license Inventory report automation
# --- Variables ---
$TenantId = "Your 32 Character TenantId"
$ClientId = "Your 32 Character ClientId"
$Scope    = "https://graph.microsoft.com/.default"

$AutomationCertName = "Your certificate name"  # Automation certificate which will stored in 1- App registartion manange/certifactes section and 2- Automation account resouce/certificates section 

$FromUPN = "Your Sender Email ID"
$ToUPN   = "Your Admin Email ID"
$Subject = "Daily Microsoft 365 License Summary"

# --- Helpers ---
function ConvertTo-Base64Url {
    param([byte[]]$Bytes)
    $b64 = [Convert]::ToBase64String($Bytes)
    $b64.TrimEnd('=').Replace('+','-').Replace('/','_')
}

function New-ClientAssertionJwt {
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    $aud = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

    $now = [DateTimeOffset]::UtcNow
    $nbf = [int]$now.ToUnixTimeSeconds()
    $exp = [int]$now.AddMinutes(10).ToUnixTimeSeconds()
    $jti = [Guid]::NewGuid().ToString()

    # x5t header = base64url(cert thumbprint bytes)
    $x5t = ConvertTo-Base64Url -Bytes $Certificate.GetCertHash()

    $header = @{ alg="RS256"; typ="JWT"; x5t=$x5t }
    $payload = @{
        aud = $aud
        iss = $ClientId
        sub = $ClientId
        jti = $jti
        nbf = $nbf
        exp = $exp
    }

    $headerJson  = $header  | ConvertTo-Json -Compress
    $payloadJson = $payload | ConvertTo-Json -Compress

    $unsigned = (ConvertTo-Base64Url -Bytes ([Text.Encoding]::UTF8.GetBytes($headerJson))) + "." +
                (ConvertTo-Base64Url -Bytes ([Text.Encoding]::UTF8.GetBytes($payloadJson)))

    # IMPORTANT FIX: GetRSAPrivateKey is an extension method - call it via the extension class
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)
    if (-not $rsa) { throw "RSA private key not accessible. Ensure the Automation certificate asset includes the private key (PFX)." }

    $sigBytes = $rsa.SignData(
        [Text.Encoding]::UTF8.GetBytes($unsigned),
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
    )

    $unsigned + "." + (ConvertTo-Base64Url -Bytes $sigBytes)
}

function Get-GraphTokenWithCertAssertion {
    param(
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    $assertion = New-ClientAssertionJwt -TenantId $TenantId -ClientId $ClientId -Certificate $Certificate

    $tokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    $body = @{
        client_id             = $ClientId
        scope                 = $Scope
        grant_type            = "client_credentials"
        client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
        client_assertion      = $assertion
    }

    (Invoke-RestMethod -Method POST -Uri $tokenUri -Body $body -ContentType "application/x-www-form-urlencoded").access_token
}

# --- Main ---
$ErrorActionPreference = "Stop"

# Get cert from Azure Automation certificate asset (no cert store) -us/graph/api/user-sendmail?view=graph-rest-1.0)[2](https://learn.microsoft.com/en-us/graph/api/subscribedsku-get?view=graph-rest-1.0)
$cert = Get-AutomationCertificate -Name $AutomationCertName
if (-not $cert -or -not $cert.HasPrivateKey) {
    throw "Automation certificate '$AutomationCertName' not found or missing private key."
}
Write-Output "Using cert thumbprint: $($cert.Thumbprint)"

# Token
$accessToken = Get-GraphTokenWithCertAssertion -TenantId $TenantId -ClientId $ClientId -Scope $Scope -Certificate $cert
$headers = @{ Authorization = "Bearer $accessToken" }

# Inventory: subscribedSkus [3](https://learn.microsoft.com/en-us/powershell/module/az.automation/?view=azps-15.5.0)
$response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/subscribedSkus" -Headers $headers -Method GET

# Build table (keep your full skuMap if you want)
$skuMap = @{
  "SPE_E5"="Microsoft 365 E5"
  "EXCHANGEENTERPRISE"="Exchange Online (Plan 2)"
  "OFFICESUBSCRIPTION"="Microsoft 365 Apps for Enterprise"
  "Microsoft_365_Copilot"="Microsoft 365 Copilot"
}

$table = foreach ($sku in $response.value) {
    $skuName = $sku.skuPartNumber
    $name = if ($skuMap.ContainsKey($skuName)) { $skuMap[$skuName] } else { $skuName }

    $purchased = $sku.prepaidUnits.enabled
    $assigned  = $sku.consumedUnits
    $available = if ($null -ne $purchased -and $null -ne $assigned) { $purchased - $assigned } else { "N/A" }

    [PSCustomObject]@{
        "License Name" = $name
        "Purchased"    = if ($null -ne $purchased) { $purchased } else { "N/A" }
        "Assigned"     = if ($null -ne $assigned)  { $assigned  } else { "N/A" }
        "Available"    = $available
    }
}

# HTML
$style = @"
<style>
  body { font-family: Arial, sans-serif; color: #333; }
  table { border-collapse: collapse; width: 100%; }
  th { background-color: #6A0DAD; color: white; padding: 8px; text-align: left; }
  td { border: 1px solid #ddd; padding: 8px; }
  tr:nth-child(even) { background-color: #f3e8ff; }
</style>
"@

$rows = ($table | ForEach-Object {
  "<tr><td>$($_.'License Name')</td><td>$($_.Purchased)</td><td>$($_.Assigned)</td><td>$($_.Available)</td></tr>"
}) -join "`n"

$htmlBody = @"
<html><head>$style</head><body>
<p>Hello Team,</p>
<p>Please find below the current Microsoft 365 license summary:</p>
<table>
<tr><th>License Name</th><th>Purchased</th><th>Assigned</th><th>Available</th></tr>
$rows
</table>
<p>Best Regards,<br/>M365 Operations Team - Accenture</p>
</body></html>
"@

# Send mail via Graph [4](https://learn.microsoft.com/en-us/entra/identity-platform/msal-acquire-cache-tokens)
$emailJson = @{
  message = @{
    subject = $Subject
    body    = @{ contentType = "HTML"; content = $htmlBody }
    toRecipients = @(@{ emailAddress = @{ address = $ToUPN } })
  }
  saveToSentItems = $false
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$FromUPN/sendMail" `
  -Method POST `
  -Headers @{ Authorization = "Bearer $accessToken" } `
  -Body $emailJson `
  -ContentType "application/json"

Write-Output "Success: email sent to $ToUPN"
