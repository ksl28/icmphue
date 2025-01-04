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
    $allLights = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/light" -Headers $Header -ContentType "application/json" -SkipCertificateCheck

    $roomObjRids = $roomObj.children.rid
    $matchingLights = $allLights.data | Where-Object { $_.owner.rid -in $roomObjRids } | ForEach-Object { $_.id }
   
    return $matchingLights
}