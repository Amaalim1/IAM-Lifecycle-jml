<#
.SYNOPSIS  Creates joiner accounts from an HR feed using Microsoft Graph.
.NOTES     Lab use. Requires: Connect-MgGraph -Scopes User.ReadWrite.All,Group.ReadWrite.All
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$HrFeed,
    [string]$Domain = 'contoso.example',
    [hashtable]$RoleGroups = @{
        'Finance'     = 'ROLE-Finance-Analyst'
        'Engineering' = 'ROLE-Eng-Developer'
        'IT'          = 'ROLE-IT-Support'
    }
)

$joiners = Import-Csv $HrFeed | Where-Object EventType -eq 'Joiner'

foreach ($j in $joiners) {
    $upn = ('{0}.{1}@{2}' -f $j.GivenName, $j.Surname, $Domain).ToLower()

    if (Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue) {
        Write-Warning "$upn already exists, skipping."
        continue
    }

    if ($PSCmdlet.ShouldProcess($upn, 'Create joiner')) {
        $password = -join ((48..57 + 65..90 + 97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
        $user = New-MgUser -DisplayName "$($j.GivenName) $($j.Surname)" `
            -GivenName $j.GivenName -Surname $j.Surname `
            -UserPrincipalName $upn -MailNickname $upn.Split('@')[0] `
            -Department $j.Department -JobTitle $j.JobTitle `
            -EmployeeId $j.EmployeeId -AccountEnabled:$false `
            -PasswordProfile @{ Password = $password; ForceChangePasswordNextSignIn = $true }

        $mgr = Get-MgUser -Filter "userPrincipalName eq '$($j.ManagerUpn)'" -ErrorAction SilentlyContinue
        if ($mgr) { Set-MgUserManagerByRef -UserId $user.Id -BodyParameter @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($mgr.Id)" } }

        foreach ($name in @('BR-AllEmployees', $RoleGroups[$j.Department])) {
            $g = Get-MgGroup -Filter "displayName eq '$name'"
            if ($g) { New-MgGroupMember -GroupId $g.Id -DirectoryObjectId $user.Id }
            else    { Write-Warning "Group $name not found." }
        }
        Write-Output "Created $upn (disabled until $($j.EffectiveDate)). Enable and issue TAP on start date."
    }
}
