<#
.SYNOPSIS
   Exchange Health and Mail Flow Report
.DESCRIPTION
   Collects:
     - Queue statistics for all mailbox servers
     - MessageTracking counts (last 24 hours)
     - Disk usage (local drives)
     - Exchange server component/service health
     - Critical Exchange Services (Frontend Transport / Transport / Throttling)
   Sends a single HTML email report
#>

# ================== CONFIG ==================
$Servers = Get-ExchangeServer | Where-Object {$_.ServerRole -match "Mailbox"} | Select-Object -ExpandProperty Name
$From    = "Your Sender Email ID"
$To      = "Your Admin Email ID"
$SMTP    = "Your Server Hostname.Domain.com"
$Subject = "Exchange Health Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Thresholds for alert coloring
$DeferThreshold = 1000
$FailThreshold  = 200
# ============================================

# --- Queue Stats ---
$queueStats = foreach ($s in $Servers) {
   Get-Queue -Server $s | Select-Object Identity,MessageCount,Status,NextHopDomain
}
$QueueHtml = $queueStats | ConvertTo-Html -Fragment -PreContent "<h2>Queue Statistics</h2>"

# --- Message Flow (last 24 hour) ---
$flowStats = foreach ($s in $Servers) {
   $stats = Get-MessageTrackingLog -Server $s -Start (Get-Date).AddHours(-24) -ResultSize Unlimited
   [PSCustomObject]@{
       Server       = $s
       RECEIVE      = ($stats | Where-Object {$_.EventId -eq "RECEIVE"}).Count
       SENDEXTERNAL = ($stats | Where-Object {$_.EventId -eq "SENDEXTERNAL"}).Count
       DEFER        = ($stats | Where-Object {$_.EventId -eq "DEFER"}).Count
       FAIL         = ($stats | Where-Object {$_.EventId -eq "FAIL"}).Count
       DSN          = ($stats | Where-Object {$_.EventId -eq "DSN"}).Count
       BADMAIL      = ($stats | Where-Object {$_.EventId -eq "BADMAIL"}).Count
   }
}

# Add conditional coloring flags for DEFER / FAIL (kept as-is)
$flowStats | ForEach-Object {
   $_ | Add-Member -NotePropertyName "DeferClass" -NotePropertyValue ($(if ($_.DEFER -gt $DeferThreshold) { "red" } else { "" }))
   $_ | Add-Member -NotePropertyName "FailClass"  -NotePropertyValue ($(if ($_.FAIL  -gt $FailThreshold)  { "red" } else { "" }))
}

$FlowHtml = $flowStats | ConvertTo-Html -Fragment -PreContent "<h2>Mail Flow (Last 24 Hour)</h2>" `
   -Property Server,RECEIVE,SENDEXTERNAL,DEFER,FAIL,DSN,BADMAIL

# --- Disk Usage ---
$diskStats = foreach ($s in $Servers) {
   Get-WmiObject Win32_LogicalDisk -ComputerName $s -Filter "DriveType=3" |
       Select-Object @{n="Server";e={$s}},
                    @{n="Drive";e={$_.DeviceID}},
                    @{n="Size(GB)";e={[math]::Round($_.Size/1GB,2)}},
                    @{n="Free(GB)";e={[math]::Round($_.FreeSpace/1GB,2)}},
                    @{n="Free(%)";e={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}
}
$DiskHtml = $diskStats | ConvertTo-Html -Fragment -PreContent "<h2>Disk Usage</h2>"

# --- Server Health ---
$healthStats = foreach ($s in $Servers) {
   try {
       Test-ServiceHealth -Server $s | Select-Object Server,Role,RequiredServicesRunning
   } catch {
       [PSCustomObject]@{
           Server = $s
           Role   = "Mailbox"
           RequiredServicesRunning = "Access Denied / Unable to Query"
       }
   }
}
$HealthHtml = $healthStats | ConvertTo-Html -Fragment -PreContent "<h2>Exchange Service Health</h2>"

# --- Critical Exchange Services (Mail Flow Core) ---
$CriticalServiceList = @(
    @{ DisplayName = "Microsoft Exchange Frontend Transport"; Name = "MSExchangeFrontEndTransport"; ExpectedStart = "Auto" },
    @{ DisplayName = "Microsoft Exchange Transport";          Name = "MSExchangeTransport";          ExpectedStart = "Auto" },
    @{ DisplayName = "Microsoft Exchange Throttling";         Name = "MSExchangeThrottling";        ExpectedStart = "Auto" }
)

$criticalSvcResults = foreach ($s in $Servers) {
    foreach ($svc in $CriticalServiceList) {
        try {
            # CIM gives both State + StartMode reliably
            $w = Get-CimInstance Win32_Service -ComputerName $s -Filter "Name='$($svc.Name)'" -ErrorAction Stop

            $isBad = ($w.State -ne "Running" -or $w.StartMode -ne $svc.ExpectedStart)

            [PSCustomObject]@{
                Server      = $s
                Service     = $svc.DisplayName
                ServiceName = $svc.Name
                Status      = $w.State
                Startup     = $w.StartMode
                _RowClass   = $(if ($isBad) { "red" } else { "" })
            }
        } catch {
            [PSCustomObject]@{
                Server      = $s
                Service     = $svc.DisplayName
                ServiceName = $svc.Name
                Status      = "Unable to Query"
                Startup     = ""
                _RowClass   = "red"
            }
        }
    }
}

# Build HTML manually so we can apply row-level red highlighting
$CriticalSvcHtml = "<h2>Critical Exchange Services (Mail Flow Core)</h2>"
$CriticalSvcHtml += "<table><tr><th>Server</th><th>Service</th><th>Service Name</th><th>Status</th><th>Startup</th></tr>"

foreach ($r in $criticalSvcResults) {
    $rowClass = $r._RowClass
    $CriticalSvcHtml += "<tr class='$rowClass'><td>$($r.Server)</td><td>$($r.Service)</td><td>$($r.ServiceName)</td><td>$($r.Status)</td><td>$($r.Startup)</td></tr>"
}
$CriticalSvcHtml += "</table>"

# --- Combine Report ---
$style = @"
<style>
body {font-family:Arial; font-size:12px;}
h2 {background:#4CAF50; color:white; padding:4px;}
table {border-collapse:collapse; width:100%;}
th, td {border:1px solid black; padding:5px; text-align:center;}
th {background:#f2f2f2;}
.red {background-color:#f44336; color:white;}
</style>
"@

$ReportBody = ($QueueHtml + $FlowHtml + $DiskHtml + $HealthHtml + $CriticalSvcHtml) -join "`n"
$Report = ConvertTo-Html -Head $style -Body $ReportBody -Title "Exchange Health Report" | Out-String

# --- Send Email ---
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Report -BodyAsHtml -SmtpServer $SMTP -Port 25
