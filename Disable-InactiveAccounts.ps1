# Users that have not been logged onto this many days will be disabled
$maxAge = 60 # In days

# Change the search OU
$searchBase = 'DC=domain,DC=com'

# Get all Domain Controllers (can be filtered)
$DCs = Get-ADDomainController -Filter *

$minlogontime = (Get-Date).AddDays(-$maxAge).ToFileTime()
$filter = 'lastLogon -le ' + $minlogontime + '-AND LastLogonTimeStamp -le ' + $minlogontime + ' -AND enabled -eq $True -AND lastlogon -gt 0'

function checkUserPresentInUserlist {
    param (
        $Userlist,
        $User
    )

    foreach ($CurrentUser in $Userlist) {
        if ($User.ObjectGUID -eq $CurrentUser.ObjectGUID -AND $User.UserPrincipalName -eq $CurrentUser.UserPrincipalName) {
            return $True
        }
    }

    return $False
}

Write-Host $DCs
$AllDCUsers = @()
$UsersToDisable = @()

foreach ($DC in $DCs) {
    $DCHostname = $DC.HostName

    $users = Get-ADUser -Properties LastLogon, ObjectGUID, UserPrincipalName -Filter $filter -SearchBase $searchBase -Server $DCHostname
    Write-Host $DCHostname ":" $users.Count

    $users = $Users | Sort-Object -Property Samaccountname
    $AllDCUsers += , $users

    Write-Host $users
    Write-Host "`r`n"
}

foreach ($CurrentDCUsers in $AllDCUsers) {

    foreach ($User in $CurrentDCUsers) {

        $IsPresentInAllDCs = $True

        $isUserInList = checkUserPresentInUserlist -Userlist $UsersToDisable -User $User
        if ($isUserInList) {
            # Write-Host "Already added: " $User
            continue;
        } else {
            # Write-Host "Not Present: " $User
        }

        foreach ($InspectedDCUsers in $AllDCUsers) {
            $isUserInList = checkUserPresentInUserlist -Userlist $InspectedDCUsers -User $User
            if ($isUserInList) {
                # Write-Host "$i | Present: " $User
                # $IsPresentInAllDCs = $True
            } else {
                # Write-Host "$i | Not Present: " $User
                $IsPresentInAllDCs = $False
            }
        }

        if ($IsPresentInAllDCs -eq $True) {
            $UsersToDisable += $User
        }
    }
}

foreach ($UserToDisable in $UsersToDisable) {
    # Actual disabling of the accounts
    Disable-ADAccount -Identity $UserToDisable
    Write-Host "User disabled: $UserToDisable"
}
