function get-HueRoomLights {
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