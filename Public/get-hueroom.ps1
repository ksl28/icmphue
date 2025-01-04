function get-HueRoom {
    <#
    .SYNOPSIS
    Retrieves details about a specific room from a Philips Hue bridge.

    .DESCRIPTION
    The get-HueRoom function queries the Philips Hue API to obtain information about a specified room 
    using the room's name, the bridge's IP address, and an API key for authentication.

    .PARAMETER roomName
    The name of the room whose details you want to retrieve. This is a string corresponding to the room's name in the Philips Hue system.

    .PARAMETER hueBridge
    The IP address or hostname of the Philips Hue bridge. This is necessary to direct the API request to the correct device.

    .PARAMETER hueAPIKey
    The API key used for authentication with the Philips Hue bridge. This key must be valid and associated with the user account that has access to the rooms.

    .OUTPUTS
    Returns an object containing the details of the specified room if found. If an error occurs during the API call, it throws an exception.

    .EXAMPLE
    $roomDetails = get-HueRoom -roomName "Living Room" -hueBridge "192.168.1.100" -hueAPIKey "your-api-key-here"
    Write-Output "Room Name: $($roomDetails.metadata.name), Room ID: $($roomDetails.id)"

    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $roomName,

        [Parameter(Mandatory = $true)]
        [string]
        $hueBridge,

        [Parameter(Mandatory = $true)]
        [string]
        $hueAPIKey
    )

    $Header = @{
        'hue-application-key' = $hueAPIKey
    }
    try {
        $allRooms = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/room" -Headers $Header -ContentType "application/json" -SkipCertificateCheck -ErrorAction Stop    
    }
    catch {
        throw "Failed to call the API for getting the list of rooms - error : $($_.Exception.Message)"
    }
    
    $roomObj = $allRooms.data | Where-Object { $_.metadata.name -eq $roomName }
    
    if ($roomObj) {
        return $roomObj
    }
}
