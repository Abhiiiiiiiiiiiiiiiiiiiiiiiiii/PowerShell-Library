# Input/output files
$UserFile  = "C:\Temp\TeamsChannelUser.csv"
$OutputFile = "C:\Temp\UsersTeamsMembership.csv"

# Read all users
$Users = Import-Csv $UserFile | Select-Object -ExpandProperty User

# Create result collection
$Result = foreach ($User in $Users) {

    $User = $User.Trim()

    if ([string]::IsNullOrWhiteSpace($User)) {
        continue
    }

    Write-Host "Processing: $User" -ForegroundColor Cyan

    try {

        # Get all Teams associated with the user
        $Teams = Get-Team -User $User -ErrorAction Stop

        if ($Teams) {

            foreach ($Team in $Teams) {

                try {

                    # Get user's information/role in this Team
                    $UserInfo = Get-TeamUser -GroupId $Team.GroupId -ErrorAction Stop |
                        Where-Object { $_.User -eq $User }

                    # Create report entry
                    [PSCustomObject]@{
                        User            = $User
                        TeamName        = $Team.DisplayName
                        GroupId         = $Team.GroupId
                        Role            = $UserInfo.Role
                        Privacy         = $Team.Visibility
                        Description     = $Team.Description
                        ProcessingStatus = "Success"
                    }

                }
                catch {

                    [PSCustomObject]@{
                        User            = $User
                        TeamName        = $Team.DisplayName
                        GroupId         = $Team.GroupId
                        Role            = ""
                        Privacy         = $Team.Visibility
                        Description     = $Team.Description
                        ProcessingStatus = "Failed to get Team user info: $($_.Exception.Message)"
                    }
                }
            }
        }
        else {

            # User has no Teams returned
            [PSCustomObject]@{
                User            = $User
                TeamName        = ""
                GroupId         = ""
                Role            = ""
                Privacy         = ""
                Description     = ""
                ProcessingStatus = "No Teams found"
            }
        }
    }
    catch {

        # Handles invalid users, permissions, etc.
        [PSCustomObject]@{
            User            = $User
            TeamName        = ""
            GroupId         = ""
            Role            = ""
            Privacy         = ""
            Description     = ""
            ProcessingStatus = "Failed: $($_.Exception.Message)"
        }
    }
}

# Display results
$Result | Format-Table User, TeamName, Role, Privacy, ProcessingStatus -AutoSize

# Export everything to CSV
$Result | Export-Csv $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Report exported to: $OutputFile" -ForegroundColor Green
