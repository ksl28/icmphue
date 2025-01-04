function get-HueRoom {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $roomName
    )
    $allRooms = Invoke-RestMethod -Method GET -Uri "https://$global:hueBridge/clip/v2/resource/room" -Headers $global:Header -ContentType "application/json" -SkipCertificateCheck
    $roomObj = $allRooms.data | Where-Object {$_.metadata.name -eq $roomName}
    
    if ($roomObj) {
        return $roomObj
    }
}