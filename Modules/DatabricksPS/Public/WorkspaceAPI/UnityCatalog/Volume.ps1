Function Get-UnityCatalogVolume {
	<#
		.SYNOPSIS
		Gets list of volumes. If a volume name is supplied, provide details on the specified volume.
		.DESCRIPTION
		Gets list of volumes. If a volume name is supplied, provide details on the specified volume.
		Official API Documentation: https://docs.databricks.com/api/workspace/volumes/list
		Official API Documentation: https://docs.databricks.com/api/workspace/volumes/get
		.PARAMETER CatalogName
		.PARAMETER SchemaName
		.PARAMETER VolumeName
		.PARAMETER IncludeBrowse
		The three-level (fully qualified) name of the volume to retrieve. This field is optional and can be used as a filter on one particular volume.
		.EXAMPLE
		Get-UnityCatalogVolume -VolumeName MyVolume
		.EXAMPLE
		Get-UnityCatalogVolume
	#>
	param
	(
		[Parameter(ParameterSetName = "List",Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("catalog", "catalog_name")] [string] $CatalogName,
		[Parameter(ParameterSetName = "List",Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("schema", "schema_name")] [string] $SchemaName,
		[Parameter(ParameterSetName = "Get",Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [Alias("vol_name", "volume_name")] [string] $VolumeName,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [string] $IncludeBrowse,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [switch] $Raw
	)
	begin {
		$requestMethod = "GET"
		$apiEndpoint = "/2.1/unity-catalog/volumes"
	}
	process {
		If($PSBoundParameters.ContainsKey("VolumeName")) {
			$apiEndpoint = "/2.1/unity-catalog/volumes/$VolumeName"
		}

		#Set parameters
		Write-Verbose "Building Body/Parameters for final API call ..."
		$parameters = @{ }

		if ($PSCmdlet.ParameterSetName -eq "List")
		{
		  $parameters | Add-Property -Name "catalog_name" -Value $CatalogName
		  $parameters | Add-Property -Name "schema_name" -Value $SchemaName
		}

		if ($PSCmdlet.ParameterSetName -eq "Get")
		{
		  $parameters | Add-Property -Name "name" -Value $VolumeName
		}

		$result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

		if ($PSBoundParameters.ContainsKey("VolumeName") -or $Raw.IsPresent) {
			# if a VolumeName was specified, we return the result as it is
			return $result
		}
		else {
			# if no VolumeName was specified, we return the volumes as an array
			return $result.volumes
		}
	}
}
