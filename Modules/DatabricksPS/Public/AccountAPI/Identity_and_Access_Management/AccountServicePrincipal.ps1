Function Get-DatabricksAccountServicePrincipal {
    <#
              .SYNOPSIS
              Returns all of the Service Principals for the current Account
              .DESCRIPTION
              Returns all of the Service Principals for a current AccountID.
              Official API Documentation: https://docs.databricks.com/api/
              .PARAMETER ServicePrincipal
              Service Principal ID, returns the Service Principal Details for the Service Principal
              .EXAMPLE
              Get-DatabricksAccountServicePrincipal
              Get-DatabricksAccountServicePrincipal -ServicePrincipal 1063038260212505
    #>
    [CmdletBinding(DefaultParameterSetName="NoParams")]
    param 
    (	
      [Parameter(ParameterSetName = "ServicePrincipal", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("sp")] [string] $ServicePrincipalID
    )

    begin {
      $requestMethod = "GET"
      $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/ServicePrincipals"
    }
      
    process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }
  
      Write-Verbose "Building Body/Parameters for final API call ..."
      #Set parameters
      if ($PSCmdlet.ParameterSetName -eq "ServicePrincipal") {
        $apiEndpoint = $apiEndpoint + "/$ServicePrincipalID"
      }  

      $parameters = @{}
          
      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters
  
      if ($PSCmdlet.ParameterSetName -eq "ServicePrincipal") {
        return $result
      }
      else {
        return $result.Resources
      }
    }
  }
  
  Function New-DatabricksAccountServicePrincipal {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }

  Function Remove-DatabricksAccountServicePrincipal {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }