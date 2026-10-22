<#
.SYNOPSIS  Handles role changes: snapshot, remove old-role groups, add new-role groups.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$UserPrincipalName,
    [Parameter(Mandatory)][string]$NewRoleGroup,
    [string]$NewDepartment,
    [string]$NewJobTitle,
    [string]$SnapshotPath = ".\snapshots"
)

$user = Get-MgUser -UserId $UserPrincipalName -Property Id,DisplayName,Department,JobTitle
New-Item -ItemType Directory -Path $SnapshotPath -Force | Out-Null

# 1. Before-state snapshot
$memberships = Get-MgUserMemberOf -UserId $user.Id -All
$memberships | ForEach-Object { $_.AdditionalProperties.displayName } |
    Out-File (Join-Path $SnapshotPath "$($user.Id)-before-$(Get-Date -f yyyyMMdd-HHmm).txt")

# 2. Remove old ROLE-/REQ- groups FIRST
foreach ($m in $memberships) {
    $name = $m.AdditionalProperties.displayName
    if ($name -like 'ROLE-*' -or $name -like 'REQ-*') {
        if ($PSCmdlet.ShouldProcess($name, "Remove $UserPrincipalName")) {
            Remove-MgGroupMemberByRef -GroupId $m.Id -DirectoryObjectId $user.Id
        }
    }
}

# 3. Add new role
$g = Get-MgGroup -Filter "displayName eq '$NewRoleGroup'"
if ($g -and $PSCmdlet.ShouldProcess($NewRoleGroup, "Add $UserPrincipalName")) {
    New-MgGroupMember -GroupId $g.Id -DirectoryObjectId $user.Id
}

# 4. Update attributes
if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Update department/title')) {
    Update-MgUser -UserId $user.Id -Department $NewDepartment -JobTitle $NewJobTitle
}
Write-Output "Mover complete. Request manager attestation and retain the snapshot."
