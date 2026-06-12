# Create Exchange session
$exchangeServer = "Your_Server_HostName"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri http://$exchangeServer/PowerShell/ `
    -Authentication Kerberos
Import-PSSession $Session -DisableNameChecking

# Email configuration
$smtpServer = "Your_Server_HostName.Domain.com"
$smtpFrom = "Your Sender Email ID"
$smtpTo = "Your Admin Email ID"
$subject = "Exchange Queue Alert"
$smtpPort = 25

function Send-AlertEmail {
    param ([string]$body)
    Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $subject `
        -Body $body -SmtpServer $smtpServer -Port $smtpPort
}

function Check-QueueStatus {
    try {
        $queues = Get-Queue -Server $exchangeServer
        $stuckQueues = $queues | Where-Object { $_.MessageCount -gt 25 }

        if ($stuckQueues) {
            $report = $stuckQueues |
                Select Identity, Status, MessageCount |
                Format-Table -AutoSize | Out-String

            Send-AlertEmail "⚠ Exchange Queue Alert`n`n$report"
        }
    }
    catch {
        Send-AlertEmail "Error checking Exchange queues: $($_.Exception.Message)"
    }
}

Check-QueueStatus

Remove-PSSession $Session
