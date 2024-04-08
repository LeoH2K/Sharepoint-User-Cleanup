# Connection Functions
function Connect-Tenant {
    param(
        [string]$TenantAdminURL,
        [string]$ClientID,
        [string]$ThumbPrint,
        [string]$Tenant,
        [string]$TenantID
    )
    Connect-PnPOnline -Url $TenantAdminURL -ClientId $ClientID -Thumbprint $ThumbPrint -Tenant $Tenant
    Connect-MgGraph -ClientId $ClientID -CertificateThumbprint $ThumbPrint -TenantId $TenantID
}

function Set-TenantAdminURL {
    param(
        [string]$TenantURL
    )
    return $TenantURL.Insert($TenantURL.IndexOf("."),"-admin")
}

# Data Retrieval Functions
function Get-Sites {
    param(
        [string]$TenantURL
    )
    return Get-PnPTenantSite -Filter "Url -like $TenantURL"
}

function Get-DisabledUsers {
    $Users = @(Get-MgUser -all -Property DisplayName,mail,accountenabled,JobTitle,ID,UserPrincipalName)
    $UserIDs = $Users | where {
        $_.AccountEnabled -eq $false -and $_.JobTitle -ne $null -and $_.Mail -ne $null
    }
    return $UserIDs | ForEach-Object { 
        "i:0#.f|membership|" + $_.UserPrincipalName
    }
}

function Get-UnifiedGroups {
    $Groups = @(Get-MgGroup -all -Property DisplayName,ID,Grouptypes,Members)
    return $Groups | where {
        $_.GroupTypes -eq 'Unified' -and $_.ID -ne '99d40beb-35f9-4f50-9349-b53a65f58dc6'
    }
}

# User Cleanup Functions
function Remove-DisabledUsersFromSites {
    param(
        [object]$Sites,
        [object]$ShareUserIDs,
        [string]$ClientID,
        [string]$ThumbPrint,
        [string]$Tenant
    )
    $Sites | ForEach-Object {
        Write-host "Searching in Site Collection:"$_.URL -f Yellow
        Connect-PnPOnline -Url $_.URL -ClientId $ClientID -Thumbprint $ThumbPrint -Tenant $Tenant
        $SiteUsers = Get-PnPUser
        foreach ($ShareUserID in $ShareUserIDs) {
            foreach ($SiteUser in $SiteUsers) {
                if ($SiteUser.LoginName -eq $ShareUserID) {
                    Remove-PnPUser -Identity $ShareUserID -Confirm:$false
                    Write-host $ShareUserID "was removed from the site" -f Green
                }
            }
        }
    }
}

function Remove-DisabledUsersFromUnifiedGroups {
    param(
        [object]$UnifiedGroups,
        [object]$UserIDs
    )
    foreach ($UnifiedGroup in $UnifiedGroups) {
        Write-host "Searching for users in:"$UnifiedGroup.DisplayName -f Yellow
        $Members = Get-MgGroupMember -GroupId $UnifiedGroup.Id
        foreach ($UserID in $UserIDs) {
            foreach ($Member in $Members) {
                if ($Member.Id -eq $UserID.Id) {
                    Remove-MgGroupMemberByRef -GroupId $UnifiedGroup.Id -DirectoryObjectId $UserID.Id -Confirm:$false
                    Write-host $UserID.DisplayName "was removed from:"$UnifiedGroup.DisplayName -f Green
                }
            }
        }
    }
}

# Example Usage
$TenantURL = "your_tenant_url"
$ClientID = "your_client_id"
$ThumbPrint = "your_thumbprint"
$Tenant = "your_tenant_name"
$TenantID = "your_tenant_id"

$TenantAdminURL = Set-TenantAdminURL -TenantURL $TenantURL
Connect-Tenant -TenantAdminURL $TenantAdminURL -ClientID $ClientID -ThumbPrint $ThumbPrint -Tenant $Tenant -TenantID $TenantID

$Sites = Get-Sites -TenantURL $TenantURL
$ShareUserIDs = Get-DisabledUsers
$UnifiedGroups = Get-UnifiedGroups

Remove-DisabledUsersFromSites -Sites $Sites -ShareUserIDs $ShareUserIDs -ClientID $ClientID -ThumbPrint $ThumbPrint -Tenant $Tenant
Remove-DisabledUsersFromUnifiedGroups -UnifiedGroups $UnifiedGroups -UserIDs $UserIDs
