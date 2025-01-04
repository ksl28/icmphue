function get-HueRoomLights {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $roomObj
    )

    $allLights = Invoke-RestMethod -Method GET -Uri "https://$global:hueBridge/clip/v2/resource/light" -Headers $global:Header -ContentType "application/json" -SkipCertificateCheck

    $roomObjRids = $roomObj.children.rid
    $matchingLights = $allLights.data | Where-Object { $_.owner.rid -in $roomObjRids } | ForEach-Object { $_.id }
   
    return $matchingLights
}