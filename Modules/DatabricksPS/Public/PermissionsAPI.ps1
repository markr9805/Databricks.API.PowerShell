Function Get-DatabricksPermissions {
  <#
      .SYNOPSIS
      Get permission for the objects inside the Databricks workspace.
      .DESCRIPTION
      Get permission for the objects inside the Databricks workspace.
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/permissions.html
      .PARAMETER ObjectType 
      The type of the object for which you want to retrieve the permission(s). e.g. Cluster, Job, Directory, ...
      .PARAMETER ObjectID 
      The unique ID of the object for which you want to retrieve the permission(s). e.g. a cluster_id if ObjectType = Cluster
      .PARAMETER ClusterID 
      The unique ID of the cluster for which you want to retrieve the permission(s). 
      .PARAMETER JobID 
      The unique ID of the job for which you want to retrieve the permission(s). 
      .PARAMETER InstancePoolID 
      The unique ID of the instance pool for which you want to retrieve the permission(s). 
      .PARAMETER WorkspaceObjectType 
      The type of the workspace item for which you want to retrieve the permission(s). The workspace item itself is specified using -ObjectID.
      .PARAMETER SQLEndpointID 
      The unique ID of the SQL endponit for which you want to retrieve the permission(s). 
      .PARAMETER Raw
      Can be used to retrieve the raw output of the API call. Otherwise an object with all the permissions is returned.
      .EXAMPLE
      Get-DatabricksPermissions -ObjectType "CLUSTERS" -ObjectID "1202-211320-brick1"
      .EXAMPLE
      Get-DatabricksPermissions -ObjectType "JOBS" -ObjectID "1" -Raw
      .EXAMPLE
      #AUTOMATED_TEST:List Cluster Permissions
      (Get-DatabricksCluster)[0] | Get-DatabricksPermissions
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] 
    [Parameter(ParameterSetName = "Generic", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("object_id")] [string] $ObjectID,

    [Parameter(ParameterSetName = "Generic", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('CLUSTERS', 'JOBS', 'INSTANCE-POOLS', 'NOTEBOOKS', 'DIRECTORIES', 'REGISTERED-MODELS', 'TOKENS', 'PASSWORDS')] [string] $ObjectType,
    
    [Parameter(ParameterSetName = "Cluster", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("cluster_id")] [string] $ClusterID,

    [Parameter(ParameterSetName = "Job", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("job_id")] [string] $JobID,

    [Parameter(ParameterSetName = "InstancePool", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("instance_pool_id")] [string] $InstancePoolID,

    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('NOTEBOOK', 'DIRECTORY', 'LIBRARY')] [Alias("object_type")] [string] $WorkspaceObjectType,

    [Parameter(ParameterSetName = "SQLEndpoint", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("sql_endpoint_id", "id", "SQLWarehouseID", "sql_warehouse_id")] [string] $SQLEndpointID,

    [Parameter(Mandatory = $false)] [switch] $Raw
  )
  begin {
    $requestMethod = "GET"
    $apiEndpoint = "/2.0/permissions"
  }
	
  process {
    Write-Verbose "Building Body/Parameters for final API call ..."

    if ($PSCmdlet.ParameterSetName -eq "Generic") {
      if ($ObjectType -in @('TOKENS', 'PASSWORDS')) {
        $apiEndpoint += "/authorization/$($ObjectType.ToLower())"
      }
      else {
        if (-not $ObjectID) {
          Write-Error "Parameter -ObjectID is mandatory for this API call!"
        }
        $apiEndpoint += "/$($ObjectType.ToLower())/$ObjectID"
      }
      
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Cluster") {
      $apiEndpoint += "/clusters/$ClusterID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Job") {
      $apiEndpoint += "/jobs/$JobID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "InstancePool") {
      $apiEndpoint += "/instance-pools/$InstancePoolID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "WorkspaceItem") {
      if ($WorkspaceObjectType -eq "DIRECTORY") {
        $apiEndpoint += "/directories/$ObjectID"
      }
      elseif ($WorkspaceObjectType -eq "NOTEBOOK") {
        $apiEndpoint += "/notebooks/$ObjectID"
      }
      else {
        Write-Warning "ObjectType '$WorkspaceObjectType' does not support permissions"
        return
      }
    }
    elseif ($PSCmdlet.ParameterSetName -eq "SQLEndpoint") {
      $apiEndpoint += "/sql/endpoints/$SQLEndpointID"
    }

    #Set parameters
    $parameters = @{}

    $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

    if ($Raw) { return $result }
    else {
      return $result.access_control_list
    }
  }
}


Function Get-DatabricksPermissionLevels {
  <#
      .SYNOPSIS
      Get permission levels for the objects inside the Databricks workspace.
      .DESCRIPTION
      Get permission levels for the objects inside the Databricks workspace.
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/permissions.html
      .PARAMETER ObjectType 
      The type of the object for which you want to retrieve the permission levels. e.g. Cluster, Job, Directory, ...
      .PARAMETER ObjectID 
      The unique ID of the object for which you want to retrieve the permission levels. e.g. a cluster_id if ObjectType = Cluster
      .PARAMETER ClusterID 
      The unique ID of the cluster for which you want to retrieve the permission levels. 
      .PARAMETER JobID 
      The unique ID of the job for which you want to retrieve the permission levels. 
      .PARAMETER InstancePoolID 
      The unique ID of the instance pool for which you want to retrieve the permission levels. 
      .PARAMETER WorkspaceObjectType 
      The type of the workspace item for which you want to retrieve the permission levels. The workspace item itself is specified using -ObjectID.
      .PARAMETER SQLEndpointID 
      The unique ID of the SQL endponit for which you want to retrieve the permission levels. 
      .PARAMETER Raw
      Can be used to retrieve the raw output of the API call. Otherwise an object with all the permissions is returned.
      .EXAMPLE
      Get-DatabricksPermissionLevels -ObjectType "CLUSTERS" -ObjectID "1202-211320-brick1"
      .EXAMPLE
      Get-DatabricksPermissionLevels -ObjectType "JOBS" -ObjectID "1" -Raw
      .EXAMPLE
      #AUTOMATED_TEST:List Databricks Permission Levels
      (Get-DatabricksCluster)[0] | Get-DatabricksPermissionLevels
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] 
    [Parameter(ParameterSetName = "Generic", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("object_id")] [string] $ObjectID,

    [Parameter(ParameterSetName = "Generic", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('CLUSTERS', 'JOBS', 'INSTANCE-POOLS', 'NOTEBOOKS', 'DIRECTORIES', 'REGISTERED-MODELS', 'TOKENS', 'PASSWORDS', 'SQL-ENDPOINTS')] [string] $ObjectType,
    
    [Parameter(ParameterSetName = "Cluster", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("cluster_id")] [string] $ClusterID,

    [Parameter(ParameterSetName = "Job", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("job_id")] [string] $JobID,

    [Parameter(ParameterSetName = "InstancePool", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("instance_pool_id")] [string] $InstancePoolID,

    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('NOTEBOOK', 'DIRECTORY', 'LIBRARY')] [Alias("object_type")] [string] $WorkspaceObjectType,

    [Parameter(ParameterSetName = "SQLEndpoint", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("sql_endpoint_id", "id", "SQLWarehouseID", "sql_warehouse_id")] [string] $SQLEndpointID,

    [Parameter(Mandatory = $false)] [switch] $Raw
  )
  begin {
    $requestMethod = "GET"
    $apiEndpoint = "/2.0/permissions"
  }
	
  process {
    Write-Verbose "Building Body/Parameters for final API call ..."

    if ($PSCmdlet.ParameterSetName -eq "Generic") {
      if ($ObjectType -in @('TOKENS', 'PASSWORDS')) {
        $apiEndpoint += "/authorization/$($ObjectType.ToLower())"
      }
      else {
        if (-not $ObjectID) {
          Write-Error "Parameter -ObjectID is mandatory for this API call!"
        }
        $apiEndpoint += "/$($ObjectType.ToLower())/$ObjectID"
      }
      
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Cluster") {
      $apiEndpoint += "/clusters/$ClusterID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Job") {
      $apiEndpoint += "/jobs/$JobID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "InstancePool") {
      $apiEndpoint += "/instance-pools/$InstancePoolID"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "WorkspaceItem") {
      if ($WorkspaceObjectType -eq "DIRECTORY") {
        $apiEndpoint += "/directories/$ObjectID"
      }
      elseif ($WorkspaceObjectType -eq "NOTEBOOK") {
        $apiEndpoint += "/notebooks/$ObjectID"
      }
      else {
        Write-Warning "ObjectType '$WorkspaceObjectType' does not support permissions"
        return
      }
    }
    elseif ($PSCmdlet.ParameterSetName -eq "SQLEndpoint") {
      $apiEndpoint += "/sql/endpoints/$SQLEndpointID"
    }

    $apiEndpoint += "/permissionLevels"

    #Set parameters
    $parameters = @{}

    $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

    if ($Raw) { return $result }
    else {
      return $result.permission_levels
    }
  }
}


Function Set-DatabricksPermissions {
  <#
      .SYNOPSIS
      Sets permissions for the objects inside the Databricks workspace.
      .DESCRIPTION
      Sets permission for the objects inside the Databricks workspace.
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/permissions.html
      .PARAMETER ObjectType 
      The type of the object for which you want to set the permission(s). e.g. Cluster, Job, Directory, ...
      .PARAMETER ObjectID 
      The unique ID of the object for which you want to set the permission(s). e.g. a cluster_id if ObjectType = Cluster
      .PARAMETER ClusterID 
      The unique ID of the cluster for which you want to set the permission(s). 
      .PARAMETER JobID 
      The unique ID of the job for which you want to set the permission(s). 
      .PARAMETER InstancePoolID 
      The unique ID of the instance pool for which you want to set the permission(s). 
      .PARAMETER WorkspaceObjectType 
      The type of the workspace item for which you want to set the permission(s). The workspace item itself is specified using -ObjectID.
      .PARAMETER SQLWarehouseID 
      The unique ID of the SQL endponit for which you want to set the permission(s). 
      .PARAMETER Raw
      Can be used to retrieve the raw output of the API call. Otherwise an object with all the permissions is returned.
      .PARAMETER Overwrite
      If sepcified, the existing permissions will be overwritten by the ones specified in this call, otherwise they will be added.
      .EXAMPLE
      $acl = @(
          @{
            user_name        = "user1@domain.com"
            permission_level = "CAN_RESTART"        
          }
        )

      Set-DatabricksPermissions -ClusterID "0712-123003-rail519" -AccessControlList $acl
      .EXAMPLE
      .EXAMPLE
      $acl = @(
          @{
            user_name        = "user1@domain.com"
            permission_level = "IS_OWNER"        
          },
          @{
            user_name        = "user2@domain.com"
            permission_level = "CAN_VIEW"        
          }
        )

      Set-DatabricksPermissions -JobID 123 -AccessControlList $acl -Overwrite
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] 
    [Parameter(ParameterSetName = "Generic", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("object_id")] [string] $ObjectID,

    [Parameter(ParameterSetName = "Generic", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('CLUSTERS', 'JOBS', 'INSTANCE-POOLS', 'NOTEBOOKS', 'DIRECTORIES', 'REGISTERED-MODELS', 'TOKENS', 'PASSWORDS')] [string] $ObjectType,
    
    [Parameter(ParameterSetName = "Cluster", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("cluster_id")] [string] $ClusterID,

    [Parameter(ParameterSetName = "Job", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("job_id")] [string] $JobID,

    [Parameter(ParameterSetName = "InstancePool", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("instance_pool_id")] [string] $InstancePoolID,

    [Parameter(ParameterSetName = "WorkspaceItem", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet('NOTEBOOK', 'DIRECTORY', 'LIBRARY')] [Alias("object_type")] [string] $WorkspaceObjectType,

    [Parameter(ParameterSetName = "SQLEndpoint", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("sql_endpoint_id", "id", "SQLWarehouseID", "sql_warehouse_id")] [string] $SQLEndpointID,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)] [Alias("ACL")][object[]] $AccessControlList,
    [Parameter(Mandatory = $false)] [switch] $Overwrite,
    [Parameter(Mandatory = $false)] [switch] $Raw
  )
  begin {
    # PATCH to add/set permissions, PUT to replace/overwrite them
    if ($Overwrite) { $requestMethod = "PUT" }
    else { $requestMethod = "PATCH" }
    
    $apiEndpoint = "/2.0/permissions"
  }
	
  process {
    Write-Verbose "Building Body/Parameters for final API call ..."

    if ($PSCmdlet.ParameterSetName -eq "Cluster") {
      $ObjectType = "CLUSTERS"
      $ObjectID = $ClusterID
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Job") {
      $ObjectType = "JOBS"
      $ObjectID = $JobID
    }
    elseif ($PSCmdlet.ParameterSetName -eq "InstancePool") {
      $ObjectType = "INSTANCE-POOLS"
      $ObjectID = $InstancePoolID
    }
    elseif ($PSCmdlet.ParameterSetName -eq "WorkspaceItem") {
      if ($WorkspaceObjectType -eq "DIRECTORY") {
        $ObjectType = "DIRECTORIES"
      }
      elseif ($WorkspaceObjectType -eq "NOTEBOOK") {
        $ObjectType = "NOTEBOOKS"
      }
      else {
        Write-Warning "ObjectType '$WorkspaceObjectType' does not support permissions"
        return
      }
    }
    elseif ($PSCmdlet.ParameterSetName -eq "SQLEndpoint") {
      $apiEndpoint += "/sql/warehouses/$SQLEndpointID"
    }
    elseif ($ObjectType -in @('TOKENS', 'PASSWORDS')) {
      $apiEndpoint += "/authorization/$($ObjectType.ToLower())"
    }
    else {
      if (-not $ObjectID) {
        Write-Error "Parameter -ObjectID is mandatory for this API call!"
      }
      $apiEndpoint += "/$($ObjectType.ToLower())/$ObjectID"
    }

    if ($UpdateType -eq "OVERWRITE" -and -not $Overwrite) {
      Write-Error "You are about to OVERWRITE all existing permissions on $($ObjectType.ToLower())/$($ObjectID). If you want to proceed please also specify -Overwrite."
    }

    #Set parameters
    $body = @{
      access_control_list = $AccessControlList
    }

    $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $body

    if ($Raw) { return $result }
    else {
      return $result.access_control_list
    }
  }
}


Function ConvertTo-DatabricksACL {
  <#
      .SYNOPSIS
      Takes the output from Get-DatabricksPermissions or Set-DatabricksPermissions and converts it to an array of permissions which can be used again with the Set-DatabricksPermissions cmdlet
      .DESCRIPTION
      Takes the output from Get-DatabricksPermissions or Set-DatabricksPermissions and converts it to an array of permissions which can be used again with the Set-DatabricksPermissions cmdlet
      Official API Documentation: https://docs.databricks.com/dev-tools/api/latest/permissions.html
      .PARAMETER AccessControlList 
      The ACL object returned from Get-DatabricksPermissions or Set-DatabricksPermissions.
      .EXAMPLE
      Get-DatabricksPermissions -ObjectType "CLUSTERS" -ObjectID "1202-211320-brick1" | ConvertTo-DatabricksACL
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)] [object[]] $AccessControlList
  )
  process {
    $newACL = @()
    ForEach ($perm in $AccessControlList) {
      $objPermissions = $perm.all_permissions | Where-Object { -not $_.inherited } 
      # the $perm object is generic an contains either user_name, group_name or service_principal AND the all_permissions property
      # so we take the one that is not all_permissions
      $permType = $perm.psobject.properties | Where-Object { $_.Name -ne "all_permissions" }

      foreach ($objPerm in $objPermissions) {
        $newACL += @{
          $permType.Name   = $perm.$($permType.Name)
          permission_level = $objPerm.permission_level
        }
      }
    }
    return $newACL
  }
}
