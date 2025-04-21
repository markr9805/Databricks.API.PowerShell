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
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }

  Function Remove-DatabricksAccountGroup {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }