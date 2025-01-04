function get-huelightstate {
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

    $lightObj = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/light/$lightID" -Headers $Header -ContentType "application/json" -SkipCertificateCheck        
        
    $obj = [PSCustomObject]@{
        lightID         = $lightObj.data.id
        lightOn         = $lightObj.data.on.on
        lightBrightness = $lightObj.data.dimming.brightness
    }
    return     $obj
}