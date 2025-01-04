function get-HueRoomLights {
    <#
    .SYNOPSIS
    Retrieves a list of light IDs associated with a specific room in a Philips Hue bridge.

    .DESCRIPTION
    The get-HueRoomLights function queries the Philips Hue API to obtain the IDs of all lights 
    that are associated with a given room object, using the bridge's IP address and an API key for authentication.

    .PARAMETER roomObj
    A PSCustomObject representing the room for which you want to retrieve associated light IDs. This object should contain the room's ID (rid) in its children property.

    .PARAMETER hueBridge
    The IP address or hostname of the Philips Hue bridge. This is necessary to direct the API request to the correct device.

    .PARAMETER hueAPIKey
    The API key used for authentication with the Philips Hue bridge. This key must be valid and associated with the user account that has access to the lights.

    .OUTPUTS
    Returns an array of light IDs associated with the specified room if any are found. If an error occurs during the API call, it throws an exception.

    .EXAMPLE
    $roomDetails = get-HueRoom -roomName "Living Room" -hueBridge "192.168.1.100" -hueAPIKey "your-api-key-here"
    $lightIds = get-HueRoomLights -roomObj $roomDetails -hueBridge "192.168.1.100" -hueAPIKey "your-api-key-here"
    #>

    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $roomObj,

        [Parameter(Mandatory=$true)]
        [string]
        $hueBridge,

        [Parameter(Mandatory=$true)]
        [string]
        $hueAPIKey
    )

    $Header = @{
        'hue-application-key' = $hueAPIKey
    }
    try {
        $allLights = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/light" -Headers $Header -ContentType "application/json" -SkipCertificateCheck -ErrorAction stop    
    }
    catch {
        throw "Failed to call the API to get a list of lights - error: $($_.Exception.Message)"
    }
   
    $roomObjRids = $roomObj.children.rid
    $matchingLights = $allLights.data | Where-Object { $_.owner.rid -in $roomObjRids } | ForEach-Object { $_.id }

    if ($matchingLights) {
        return $matchingLights
    }
}
