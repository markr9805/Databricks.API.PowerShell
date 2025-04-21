Function Get-DatabricksAccountAssignableRole {
    <#
              .SYNOPSIS
              Returns all of the assignable roles for the current Account
              When Group or ServicePrincipal are passed, the result is the assignable roles for the reqeusted resource.
              Group uses the Group ID
              ServicePrincipal uses the Application ID of the Service Principal
              .DESCRIPTION
              Returns all of the assignable roles for a provided AccountID.
              Official API Documentation: https://docs.databricks.com/api/
              .PARAMETER Group
              Group ID (not group name), returns the list of Assignable Roles for the Group
              .PARAMETER ServicePrincipal
              Service Principal Application ID (not the "id"), returns the list of Assignable Roles for the Service Principal.
              .EXAMPLE
              Get-DatabricksAccountAssignableRole
              Get-DatabricksAccountAssignableRole -Group 1063038260212505
              Get-DatabricksAccountAssignableRole -ServicePrincipal "850420e3-3297-4e39-947a-9bb3a49a4bb5"
      #>
      [CmdletBinding(DefaultParameterSetName="NoParams")]
      param 
      (	
          [Parameter(ParameterSetName = "Group", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [string] $GroupID,
          [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("sp")] [string] $ServicePrincipalID
       )
        
    begin {
      $requestMethod = "GET"
      $apiEndpoint = "/2.0/preview/accounts/${script:dbAccountID}/access-control/assignable-roles"
    }
      
    process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }
  
      Write-Verbose "Building Body/Parameters for final API call ..."
      #Set parameters
      $resource = "accounts/${script:dbAccountID}"
      if ($PSCmdlet.ParameterSetName -eq "Group") {
        $resource = $resource + "/groups/$GroupID"
      }
      if ($PSCmdlet.ParameterSetName -eq "ServicePrincipal") {
        $resource = $resource + "/servicePrincipals/$ServicePrincipalID"
      }
  
      $parameters = @{
        "resource" = $resource
       }
          
      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters
  
      return $result.roles
    }
  }
  
  Function Get-DatabricksAccountRuleSet {
    <#
              .SYNOPSIS
              Returns all of the Rule Sets for the current Account
              When Group or ServicePrincipal are passed, the result is the Rule Sets for the reqeusted resource.
              Group uses the Group ID
              ServicePrincipal uses the Application ID of the Service Principal
              .DESCRIPTION
              Returns all of the Rule Sets for a provided AccountID.
              Official API Documentation: https://docs.databricks.com/api/
              .PARAMETER Group
              Group ID (not group name), returns the list of Rule Sets for the Group
              .PARAMETER ServicePrincipal
              Service Principal Application ID (not the "id"), returns the list of Rule Sets for the Service Principal.
              .PARAMETER etag
              Identifies the version of the rule set returned. If left blank, it will return the most current.
              .EXAMPLE
              Get-DatabricksAccountRuleSet
              Get-DatabricksAccountRuleSet -Group 1063038260212505
              Get-DatabricksAccountRuleSet -ServicePrincipal "850420e3-3297-4e39-947a-9bb3a49a4bb5"
      #>
      [CmdletBinding(DefaultParameterSetName="AccountOnly")]
      param 
      (	
          [Parameter(ParameterSetName = "Group", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [string] $GroupID,
          [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("sp")] [string] $ServicePrincipalID,
          [Parameter(ParameterSetName = "AccountOnly", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
          [Parameter(ParameterSetName = "Group", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
          [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [string] $etag
       )
        
    begin {
      $requestMethod = "GET"
      $apiEndpoint = "/2.0/preview/accounts/${script:dbAccountID}/access-control/rule-sets"
    }
      
    process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }
  
      Write-Verbose "Building Body/Parameters for final API call ..."
      #Set parameters
      $name = "accounts/${script:dbAccountID}"  # this is common parameeters for all calls
      switch ($PSCmdlet.ParameterSetName) {
        "Group" {
            $name = $name + "/groups/${GroupID}/ruleSets/default"
            break
        }
        "ServicePrincipal" {
            $name = $name + "/servicePrincipals/${ServicePrincipalID}/ruleSets/default"
            break
        }
        default {
            $name = $name + "/ruleSets/default"
        }
      }
  
      $parameters = @{
        "name" = $name
        "etag" = $etag
       }
          
      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters
  
      return $result
    }
  }

  Function Update-DatabricksAccountRuleSet {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }