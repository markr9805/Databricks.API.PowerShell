Function Get-UnityCatalogConnection {
	<#
		.SYNOPSIS
		Gets list of connections. If a connection name is supplied, provide details on the specified connection.
		.DESCRIPTION
		Gets list of connections. If a connection name is supplied, provide details on the specified connection.
		Official API Documentation: https://docs.databricks.com/api/workspace/connections/list
		Official API Documentation: https://docs.databricks.com/api/workspace/connections/get
		.PARAMETER ConnectionName
		The name of the connection to retrieve. This field is optional and can be used as a filter on one particular connection.
		.EXAMPLE
		Get-UnityCatalogConnection -ConnectionName MyConnection
		.EXAMPLE
		Get-UnityCatalogConnection
	#>
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("name", "connection_name")] [string] $ConnectionName,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [switch] $Raw
	)
	begin {
		$requestMethod = "GET"
		$apiEndpoint = "/2.1/unity-catalog/connections"
	}
	process {
		If($PSBoundParameters.ContainsKey("ConnectionName")) {
			$apiEndpoint = "/2.1/unity-catalog/connections/$ConnectionName"
		}

		#Set parameters
		Write-Verbose "Building Body/Parameters for final API call ..."
		$parameters = @{ }

		$result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

		if ($PSBoundParameters.ContainsKey("ConnectionName") -or $Raw.IsPresent) {
			# if a ConnectionName was specified, we return the result as it is
			return $result
		}
		else {
			# if no ConnectionName was specified, we return the connections as an array
			return $result.connections
		}
	}
}
