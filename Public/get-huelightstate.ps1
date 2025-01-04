function get-huelightstate {
    <#
    .SYNOPSIS
    Retrieves the current state of a specific light from a Philips Hue bridge.

    .DESCRIPTION
    The get-huelightstate function queries the Philips Hue API to obtain the current state of a specified light
    using the light's ID, the bridge's IP address, and an API key for authentication.

    .PARAMETER lightID
    The unique identifier of the light whose state you want to retrieve. This is a string corresponding to the light's ID in the Philips Hue system.

    .PARAMETER hueBridge
    The IP address or hostname of the Philips Hue bridge. This is necessary to direct the API request to the correct device.

    .PARAMETER hueAPIKey
    The API key used for authentication with the Philips Hue bridge. This key must be valid and associated with the user account that has access to the lights.

    .OUTPUTS
    Returns a custom object containing the light's ID, its on/off state, and brightness level. If an error occurs during the API call, it throws an exception.

    .EXAMPLE
    $lightState = get-huelightstate -lightID "1" -hueBridge "192.168.1.100" -hueAPIKey "your-api-key-here"
    Write-Output "Light ID: $($lightState.lightID), On: $($lightState.lightOn), Brightness: $($lightState.lightBrightness)"
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $lightID,

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
        $lightObj = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/light/$lightID" -Headers $Header -ContentType "application/json" -SkipCertificateCheck -ErrorAction Stop

    }
    catch {
        throw "Failed to invoke the Rest API or getting the light state. - error : $($_.Exception.Message)"
    }

    $obj = [PSCustomObject]@{
        lightID         = $lightObj.data.id
        lightOn         = $lightObj.data.on.on
        lightBrightness = $lightObj.data.dimming.brightness
    }
    if ($obj) {
        return $obj
    }
}
