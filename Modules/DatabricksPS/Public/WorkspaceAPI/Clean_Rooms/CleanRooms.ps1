Function Get-DatabricksCleanRoom {
  <#
      .SYNOPSIS
      List all clean_rooms or retrieve the information for a clean_room, given its name.
      .DESCRIPTION
      List all clean_rooms or retrieve the information for a clean room, given its name.
      Official API Documentation: https://docs.databricks.com/api/workspace/cleanrooms/list
      Official API Documentation: https://docs.databricks.com/api/workspace/cleanrooms/get
      .PARAMETER CleanRoomName
      The clean room about which to retrieve information.
      .EXAMPLE
      Get-DatabricksCleanRoom
      Get-DatabricksCleanRoom -Name <clean_room_name>
  #>
  [CmdletBinding()]
  param(
      [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [Alias("name", "clean_room_name")] [string] $CleanRoomName,
      [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] [switch] $Raw
  )

  begin {
    $requestMethod = "GET"
    $apiEndpoint = "/2.0/clean-rooms"
  }

  process {
  	    If($PSBoundParameters.ContainsKey("CleanRoomName")) {
			$apiEndpoint = "/2.0/clean-rooms/$CleanRoomName"
        }
		#Set parameters
		Write-Verbose "Building Body/Parameters for final API call ..."
		$parameters = @{ }

		$result = Invoke-DatabricksApiRequest -Method $requestMethod -EndPoint $apiEndpoint -Body $parameters

          if ($PSBoundParameters.ContainsKey("CleanRoomName") -or $Raw.IsPresent) {
              # if a ConnectionName was specified, we return the result as it is
              return $result
          }
          else {
              # if no ConnectionName was specified, we return the connections as an array
              return $result.clean_rooms
          }
  }
}