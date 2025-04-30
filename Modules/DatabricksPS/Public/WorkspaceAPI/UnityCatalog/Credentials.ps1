Function Get-UnityCatalogCredential {
	<#
		.SYNOPSIS
		Gets an array of credentials. If a credential name is supplied, provide details on the specified credential.
		.DESCRIPTION
		Gets list of credentials. If a credential name is supplied, provide details on the specified credential.
		Official API Documentation: https://docs.databricks.com/api/workspace/credentials/listcredentials
		Official API Documentation: https://docs.databricks.com/api/workspace/credentials/getcredential
		.PARAMETER CredentialName
		The name of the credential to retrieve. This field is optional and can be used as a filter on one particular credential.
		.EXAMPLE
		Get-UnityCatalogCredential -CredentialName MyCredential
		.EXAMPLE
		Get-UnityCatalogCredential
	#>
	param
	(
		[Parameter(ParameterSetName = "get", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("name", "credential_name")] [string] $CredentialName,
		[Parameter(ParameterSetName = "list", Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [ValidateSet("STORAGE","SERVICE")] [string] $Purpose,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [switch] $Raw
	)
	begin {
		$requestMethod = "GET"
		$apiEndpoint = "/2.1/unity-catalog/credentials"
	}
	process {
		#Set parameters
		Write-Verbose "Building Body/Parameters for final API call ..."
		If($PSBoundParameters.ContainsKey("CredentialName")) {
			$apiEndpoint = "/2.1/unity-catalog/credentials/$CredentialName"
			$parameters = @{ }
		}
		else {
			if($PSBoundParameters.ContainsKey("Purpose")) {
				$parameters = @{
					"purpose" = $Purpose
				}
			}
			else {
				$parameters = @{ }

			}
		}

		$result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

		if ($PSBoundParameters.ContainsKey("CredentialName") -or $Raw.IsPresent) {
			# if a CredentialName was specified, we return the result as it is
			return $result
		}
		else {
			# if no CredentialName was specified, we return the credentials as an array
			return $result.credentials
		}
	}
}
