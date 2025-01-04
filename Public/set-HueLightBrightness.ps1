function set-HueLightBrightness {
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