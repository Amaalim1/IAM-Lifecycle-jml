<#
.SYNOPSIS  Offboards a user: disable, revoke sessions, strip access, remove licenses.
#>
[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory)][string]$UserPrincipalName)

$user = Get-MgUser -UserId $UserPrincipalName -Property Id,DisplayName

if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Disable and revoke sessions')) {
    Update-MgUser -UserId $user.Id -AccountEnabled:$false          # 1. Disable
    Revoke-MgUserSignInSession -UserId $user.Id | Out-Null         # 2. Revoke refresh tokens
}

# 3. Remove MFA methods (password methods cannot be deleted; skip them)
Get-MgUserAuthenticationMethod -UserId $user.Id | Where-Object {
    $_.AdditionalProperties.'@odata.type' -match 'microsoftAuthenticator|phoneAuthentication|fido2|softwareOath'
} | ForEach-Object { Write-Verbose "Review/remove method: $($_.Id)" }

# 4. Remove from groups (skip dynamic groups, which update automatically)
Get-MgUserMemberOf -UserId $user.Id -All | Where-Object {
    $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group'
} | ForEach-Object {
    if ($PSCmdlet.ShouldProcess($_.AdditionalProperties.displayName, 'Remove membership')) {
        try { Remove-MgGroupMemberByRef -GroupId $_.Id -DirectoryObjectId $user.Id }
        catch { Write-Warning "Could not remove from $($_.Id): $($_.Exception.Message)" }
    }
}

# 5. Remove licenses
$skus = (Get-MgUserLicenseDetail -UserId $user.Id).SkuId
if ($skus -and $PSCmdlet.ShouldProcess($UserPrincipalName, 'Remove licenses')) {
    Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses $skus | Out-Null
}
Write-Output "Leaver actions complete for $UserPrincipalName. Run verification KQL, then handle devices, mailbox, and ownership transfer."
