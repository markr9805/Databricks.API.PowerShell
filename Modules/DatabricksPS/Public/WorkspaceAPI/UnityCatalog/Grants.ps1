Function Get-UnityCatalogGrants {
	<#
		.SYNOPSIS
		Gets an array of grants (permissions) for a specified named securable item There is no guarantee of a specific ordering of the elements in the array.
		.DESCRIPTION
		Gets an array of catalogs in the metastore. If the caller is the metastore admin, all catalogs will be retrieved. Otherwise, only catalogs owned by the caller (or for which the caller has the USE_CATALOG privilege) will be retrieved. There is no guarantee of a specific ordering of the elements in the array. 
		Official API Documentation: https://docs.databricks.com/api-explorer/workspace/storage-credentials/list
		.PARAMETER SecurableType
		The type of the securable being queried (required). Valid type are CATALOG, SCHEMA, TABLE, STORAGE_CREDENTIAL, EXTERNAL_LOCATION, FUNCTION, SHARE, PROVIDER, RECIPIENT, CLEAN_ROOM, METASTORE, PIPELINE, VOLUME, CONNECTION, CREDENTIAL.
		.PARAMETER SecurableName
		The name of the securable being queried (required)
		.PARAMETER Principal
		The name of a specific Principal for which you are requesting permissions about (optional)
		.EXAMPLE
		Get-UnityCatalogGrants -SecurableType CATALOG -SecurableName my_catalog
		.EXAMPLE
		Get-UnityCatalogGrants -SecurableType CATALOG -SecurableName my_catalog -Principal my_user
	#>
	param 
	(	
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [ValidateSet("CATALOG", "SCHEMA", "TABLE", "STORAGE_CREDENTIAL", "EXTERNAL_LOCATION", "FUNCTION", "SHARE", "PROVIDER", "RECIPIENT", "CLEAN_ROOM", "METASTORE", "PIPELINE", "VOLUME", "CONNECTION", "CREDENTIAL")] [Alias("type", "securable_type")] [string] $SecurableType,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("name", "full_name")] [string] $FullName,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [string] $Principal
	)
	begin {
		$requestMethod = "GET"
	}
	process {
		$apiEndpoint = "/2.1/unity-catalog/permissions/$SecurableType/$FullName"

		#Set parameters
		Write-Verbose "Building Body/Parameters for final API call ..."

		If($PSBoundParameters.ContainsKey("Principal")) {
			$parameters = @{
			"principal" = $Principal
			}
		}

		$result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

		# if a CatalogName was specified, we return the result as it is
		return $result.privilege_assignments
	}
}
