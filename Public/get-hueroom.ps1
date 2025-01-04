function get-HueRoom {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $roomName,

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
    $allRooms = Invoke-RestMethod -Method GET -Uri "https://$hueBridge/clip/v2/resource/room" -Headers $Header -ContentType "application/json" -SkipCertificateCheck
    $roomObj = $allRooms.data | Where-Object {$_.metadata.name -eq $roomName}
    
    if ($roomObj) {
        return $roomObj
    }
}