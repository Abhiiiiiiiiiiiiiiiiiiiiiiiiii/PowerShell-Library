# Define parameters
$smtpServer = "loadbalancer.Domain.com"
$from = "Your_Sender_Email_ID"
$to = "Your_Admin_Email_ID"
$subject = "Exchange Server Disk Space Alert"
$thresholdGB = 140  # Set your desired threshold in gigabytes
$drive = "C:"     # Specify the drive you want to monitor
# Get disk space information
$disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq $drive}
$freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
# Check if free space is below threshold
if ($freeSpaceGB -lt $thresholdGB) {
    $body = "Dear Team,
This is an automated alert to notify you that the disk usage on your Exchange Server has exceeded the configured threshold.
Server: Your_Server_Hostname: 
C drive total space: 255GB
C drive Free space available C: $freeSpaceGB GB"
    # Send email
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $msg = New-Object Net.Mail.MailMessage($from, $to, $subject, $body)
    $smtp.Send($msg)
}
else {
    Write-Output "Disk space is sufficient. No alert sent."
}
