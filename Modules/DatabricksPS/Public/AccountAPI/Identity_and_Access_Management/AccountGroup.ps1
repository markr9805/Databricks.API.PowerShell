Function Get-DatabricksAccountGroup {
    <#
              .SYNOPSIS
              Returns all of the Groups for the current Account
              .DESCRIPTION
              Returns all of the Groups for a current AccountID.
              Official API Documentation: https://docs.databricks.com/api/
              .PARAMETER Group
              Group ID (not group name), returns the Group Details for the Group
              .EXAMPLE
              Get-DatabricksAccountGroup
              Get-DatabricksAccountGroup -Group 1063038260212505
    #>
    [CmdletBinding(DefaultParameterSetName="NoParams")]
    param 
    (	
      [Parameter(ParameterSetName = "Group", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [string] $GroupID
    )

    begin {
      $requestMethod = "GET"
      $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/Groups"
    }
      
    process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }
  
      Write-Verbose "Building Body/Parameters for final API call ..."
      #Set parameters
      if ($PSCmdlet.ParameterSetName -eq "Group") {
        $apiEndpoint = $apiEndpoint + "/$GroupID"
      }  

      $parameters = @{}
          
      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters
  
      if ($PSCmdlet.ParameterSetName -eq "Group") {
        return $result
      }
      else {
        return $result.Resources
      }
    }
  }


  Function New-DatabricksAccountGroup {
  <#
      .SYNOPSIS
      Admin users: Create a group in Databricks.
      .DESCRIPTION
      Admin users: Create a group in Databricks.
      Official API Documentation: https://docs.databricks.com/api/account/accountgroups/create
      .PARAMETER GroupName
      The name of the group to add.
      .PARAMETER Members
      An optional list of existing Databricks user IDs to be added to the group
      .PARAMETER Entitlements
      A list of Entitlements/Permissions the user should be assigned
      .EXAMPLE
      Add-DatabricksSCIMGroup -GroupName 'Data Scientists'
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $True)] [Alias("group_name")] [string] $GroupName,
    [Parameter(Mandatory = $False)] [string[]] $MemberUserIDs,
    [Parameter(Mandatory = $False)] [ValidateSet('allow-instance-pool-create', 'allow-cluster-create', 'workspace-access', 'databricks-sql-access')] [string[]] $Entitlements
  )

  begin {
    $requestMethod = "POST"
    $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/Groups"
  }

  process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }

        #Set parameters
        Write-Verbose "Building Body/Parameters for final API call ..."
        $parameters = @{ }

        if ($MemberUserIDs) {
          $groupMembers = @($MemberUserIDs | ForEach-Object { @{value = $_ } })
        }

        if ($Entitlements) {
          $entitlementValues = @($Entitlements | ForEach-Object { @{value = $_ } })
        }

    #    $parameters | Add-Property -Name "schemas" -Value @("urn:ietf:params:scim:schemas:core:2.0:Group") -Force
        $parameters | Add-Property -Name "displayName" -Value $GroupName -Force
        $parameters | Add-Property -Name "members" -Value $groupMembers -Force
        $parameters | Add-Property -Name "entitlements" -Value $entitlementValues -Force

        $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters -ContentType 'application/scim+json'

        return $result
  }
}

Function Update-DatabricksAccountGroup {
  <#
      .SYNOPSIS
      Admin users: Update a group in Azure Databricks by adding or removing members. Can add and remove individual members or groups within the group.
      .DESCRIPTION
      Admin users: Update a group in Azure Databricks by adding or removing members. Can add and remove individual members or groups within the group.
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/scim/scim-groups.html#update-group
      .PARAMETER GroupID
      The id of the group you want to update
      .PARAMETER AddIDs
      A list of existing Databricks user or group IDs which you want to add to the groups members
      .PARAMETER RemoveIDs
      A list of existing Databricks user or group IDs which you want to remove from the groups members
      .EXAMPLE
      Update-DatabricksSCIMGroup -GroupID 123456 -AddIDs 456789 -RemoveIDs 987654
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $True)] [Alias("group_id", "id")] [long] $GroupID,
    [Parameter(Mandatory = $false)] [long[]] $AddIDs,
    [Parameter(Mandatory = $false)] [long[]] $RemoveIDs,
    [Parameter(Mandatory = $false)] [ValidateSet('allow-cluster-create', 'workspace-access', 'databricks-sql-access')] [string[]] $AddEntitlements,
    [Parameter(Mandatory = $false)] [ValidateSet('allow-cluster-create', 'workspace-access', 'databricks-sql-access')] [string[]] $RemoveEntitlements
  )
  begin {
    $requestMethod = "PATCH"
  }

  process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }

    $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/Groups/$GroupID"

    #Set parameters
    Write-Verbose "Building Body/Parameters for final API call ..."
    $parameters = @{ }

    $parameters | Add-Property -Name "schemas" -Value @("urn:ietf:params:scim:api:messages:2.0:PatchOp") -Force

    $operations = @()

    if ($AddIDs) {
      $AddIDs | ForEach-Object { $operations += @{"op" = "add"; "value" = @{"members" = @(@{"value" = $_.ToString() }) } } }
    }
    if ($RemoveIDs) {
      $RemoveIDs | ForEach-Object { $operations += @{"op" = "remove"; "path" = 'members[value eq "' + $_.ToString() + '"]' } }
    }
    if ($AddEntitlements) {
      $AddEntitlements | ForEach-Object { $operations += @{"op" = "add"; "value" = @{"entitlements" = @(@{"value" = $_.ToString() }) } } }
    }
    if ($RemoveEntitlements) {
      $RemoveEntitlements | ForEach-Object { $operations += @{"op" = "remove"; "path" = 'entitlements[value eq "' + $_.ToString() + '"]' } }
    }

    $parameters | Add-Property -Name "Operations" -Value $operations -Force

    $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters -ContentType 'application/scim+json'

    return $result
  }
}

  Function Remove-DatabricksAccountGroup {
  <#
      .SYNOPSIS
      Admin users: Remove a group from Databricks. Users in the group are not removed.
      .DESCRIPTION
      Admin users: Remove a group from Databricks. Users in the group are not removed.
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/scim.html#delete-group-by-id
      .PARAMETER UserID
      The ID of the GroupID to remove
      .EXAMPLE
      Remove-DatabricksSCIMGroup -GroupID 123456
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] [Alias("group_id", "id")] [string] $GroupID
  )
  begin {
    $requestMethod = "DELETE"
  }

  process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }

      $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/Groups/$GroupID"

      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -ContentType 'application/scim+json'

      return $result

  }}
