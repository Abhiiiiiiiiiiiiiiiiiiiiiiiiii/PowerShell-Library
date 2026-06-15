$AppId        = "Your_32_Character_AppID"          
$Thumbprint   = "Your_40_Character_ThumbprintID"         
$Organization = "Domain.com"         

# Step 1: Connect to Exchange Online using certificate-based authentication
Connect-ExchangeOnline -AppId $AppId -CertificateThumbprint $Thumbprint -Organization $Organization
# Step 2: Fetch all mailboxes created in the last 7 days
$StartDate = (Get-Date).AddDays(-7)
$NewMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.WhenCreated -ge $StartDate }

if ($NewMailboxes.Count -eq 0) {
    Write-Host "No new mailboxes found in the last 7 days." -ForegroundColor Yellow
} else {
    Write-Host "`nFound $($NewMailboxes.Count) new mailboxes created in the last 7 days." -ForegroundColor Cyan

    foreach ($Mailbox in $NewMailboxes) {
        $MailboxUser = $Mailbox.PrimarySmtpAddress.ToString()
        Write-Host "`nProcessing mailbox: $MailboxUser" -ForegroundColor Magenta
        # Step 3: Enable archive mailbox if not already active
        $archiveStatus = $Mailbox.ArchiveStatus
        if ($archiveStatus -ne "Active") {
            Enable-Mailbox -Identity $MailboxUser -Archive
            Write-Host "Archive mailbox enabled."
        } else {
            Write-Host "Archive mailbox already active."
        }

        # Step 4: Enable auto-expanding archive
        Enable-Mailbox -Identity $MailboxUser -AutoExpandingArchive
        Write-Host "Auto-expanding archive enabled."

        # Step 5: Enable litigation hold and set duration to 5475 days
        Set-Mailbox -Identity $MailboxUser -LitigationHoldEnabled $true -LitigationHoldDuration 5475
        Write-Host "Litigation hold enabled for 5475 days."

        # Step 6: Set calendar permission to LimitedDetails
        Write-Host "`n--- STARTING CALENDAR PERMISSIONS ---" -ForegroundColor Cyan
        try {
            Write-Host "Applying calendar permission: LimitedDetails..."
            Set-MailboxFolderPermission -Identity "${MailboxUser}:\Calendar" -User Default -AccessRights LimitedDetails -ErrorAction Stop
            Write-Host "Calendar permission set to LimitedDetails." -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR setting calendar permission: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Step 7: Disconnect session
Disconnect-ExchangeOnline -Confirm:$false
