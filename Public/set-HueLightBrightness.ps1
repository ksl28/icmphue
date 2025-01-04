function set-HueLightBrightness {
    <#
    .SYNOPSIS
    Sets the brightness level of a specified light in a Philips Hue bridge.

    .DESCRIPTION
    The set-HueLightBrightness function sends a command to the Philips Hue API to adjust the brightness 
    of a specific light identified by its ID. It requires the light's ID, desired brightness level, 
    the bridge's IP address, and an API key for authentication.

    .PARAMETER lightID
    The unique identifier for the light whose brightness you want to adjust. This is a string that corresponds 
    to the light ID in the Philips Hue system.

    .PARAMETER brightness
    The desired brightness level to be set for the light. This is an integer value between 0 and 254, where 0 
    is completely off and 254 is the maximum brightness.

    .PARAMETER hueBridge
    The IP address or hostname of the Philips Hue bridge. This is necessary to direct the API request to the correct device.

    .PARAMETER hueAPIKey
    The API key used for authentication with the Philips Hue bridge. This key must be valid and associated with the user account that has access to the light.

    .OUTPUTS
    This function does not return any output. It will throw an exception if there is an error during the API call.

    .EXAMPLE
    set-HueLightBrightness -lightID "1" -brightness 200 -hueBridge "192.168.1.100" -hueAPIKey "your-api-key-here"
    # This will set the brightness of the light with ID "1" to 200 on the specified Hue bridge.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $lightID,

        [Parameter(Mandatory = $true)]
        [int32]
        $brightness,

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

    $body = @{
        dimming = @{
            brightness = $brightness
        }
    } | ConvertTo-Json -Depth 3
    
    try {
        Invoke-RestMethod -Method PUT -Uri "https://$hueBridge/clip/v2/resource/light/$lightID" -Body $body -Headers $Header -ContentType "application/json" -SkipCertificateCheck  -ErrorAction stop | Out-Null    
    }
    catch {
        throw "Failed to set the brightness for the light with id $lightID - error: $($_.Exception.Message)"
    }
}
