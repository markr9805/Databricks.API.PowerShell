Function Get-DatabricksAccountUser {
    <#
              .SYNOPSIS
              Returns all of the Users for the current Account
              .DESCRIPTION
              Returns all of the Users for a current AccountID.
              Official API Documentation: https://docs.databricks.com/api/
              .PARAMETER User
              User ID, returns the User Details for the User
              .EXAMPLE
              Get-DatabricksAccountUser
              Get-DatabricksAccountUser -User 1063038260212505
    #>
    [CmdletBinding(DefaultParameterSetName="NoParams")]
    param 
    (	
      [Parameter(ParameterSetName = "User", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [string] $UserID
    )

    begin {
      $requestMethod = "GET"
      $apiEndpoint = "/2.0/accounts/${script:dbAccountID}/scim/v2/Users"
    }
      
    process {
      if ($script:dbApiType -ne [ApiTypes]::ACCOUNT) {
        Write-Error -Message "ACCOUNT functions cannot be used when logged in with $dbApiType authentication."
        return
      }
  
      Write-Verbose "Building Body/Parameters for final API call ..."
      #Set parameters
      if ($PSCmdlet.ParameterSetName -eq "User") {
        $apiEndpoint = $apiEndpoint + "/$UserID"
      }  

      $parameters = @{}
          
      $result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters
  
      if ($PSCmdlet.ParameterSetName -eq "User") {
        return $result
      }
      else {
        return $result.Resources
      }
    }
  }
  
  Function New-DatabricksAccountUser {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }

  Function Remove-DatabricksAccountUser {
    # Placeholder function - implementation to be added later
    Write-Host "Not Implemented: This is a placeholder function."
  }