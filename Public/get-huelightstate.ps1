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

    try {
        $lightObj = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/light/$lightID" -Headers $Header -ContentType "application/json" -SkipCertificateCheck  -ErrorAction Stop

    }
    catch {
        throw "Failed to invoke the  Rest API or getting the light state. - error : $($_.Exception.Message)"
    }
    
        
    $obj = [PSCustomObject]@{
        lightID         = $lightObj.data.id
        lightOn         = $lightObj.data.on.on
        lightBrightness = $lightObj.data.dimming.brightness
    }
    if ($obj) {
        return     $obj
    }
}