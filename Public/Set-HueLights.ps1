function Set-HueLights {
    <#
    .SYNOPSIS
    Monitors the status of a specified target and adjusts the brightness of lights in a room accordingly.

    .DESCRIPTION
    The Set-HueLights function continuously checks the connectivity to a specified target. If the target is reachable
    (online), it sets the brightness of lights in a specified room to 1. If the target becomes unreachable (offline),
    it restores the lights to their previous brightness state.

    .PARAMETER roomName
    The name of the room where the lights are to be controlled. This should match the room name defined in the Philips Hue system.

    .PARAMETER hueAPIKey
    The API key used for authentication with the Philips Hue bridge. This key must be valid and associated with the user account that has access to the lights.

    .PARAMETER hueBridge
    The IP address or hostname of the Philips Hue bridge. This is necessary to direct the API request to the correct device.

    .PARAMETER monitorTarget
    The target to monitor for online/offline status. This can be an IP address or hostname.

    .OUTPUTS
    This function does not return any output. It runs indefinitely, monitoring the target's status and adjusting light brightness accordingly.

    .EXAMPLE
    Set-HueLights -roomName "Living Room" -hueAPIKey "your-api-key-here" -hueBridge "192.168.1.100" -monitorTarget "192.168.1.110"
    # This will monitor the connectivity to 192.168.1.110 and adjust the brightness of lights in the "Living Room" accordingly.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [string]
        $roomName,

        [Parameter(Mandatory = $true)]
        [string]
        $hueAPIKey,

        [Parameter(Mandatory = $true)]
        [string]
        $hueBridge,

        [Parameter(Mandatory = $true)]
        [string]
        $monitorTarget
    )

    Write-Output "Starting to  monitor $monitorTarget for online/offline status..."
    Write-Output "RoomName: $roomName -  HueBridge: $hueBridge"


    $roomObj = get-HueRoom -roomName $roomName -hueBridge $hueBridge -hueAPIKey $hueAPIKey
    $roomLights = get-HueRoomLights -roomObj $roomObj -hueAPIKey $hueAPIKey -hueBridge $hueBridge

    $varCounter = 0
    foreach ($roomLightID in $roomLights) {
        $lightState = get-huelightstate -lightID $roomLightID -hueAPIKey $hueAPIKey -hueBridge $hueBridge
        $varCounter++
        $lightVarName = "light$varCounter"
        Set-Variable -Name $lightVarName -Value $lightState
    }

    # Initialize $FirstOnline to $false
    $FirstOnline = $false

    while ($true) {
        Start-Sleep -Seconds 1
        $pingSuccess = Test-Connection -Ping -Count 1 -TargetName $monitorTarget

        if ($pingSuccess.Status -eq 'Success') {
            if (-not $FirstOnline) {
                
                # Update stored light states to reflect any manual changes
                for ($i = 1; $i -le $varCounter; $i++) {
                    $lightVarName = "light$i"
                    $currentLightState = get-huelightstate -lightID (Get-Variable -Name $lightVarName -ValueOnly).lightID -hueAPIKey $hueAPIKey -hueBridge $hueBridge
                    Set-Variable -Name $lightVarName -Value $currentLightState
                }
                
                # Transition to online state
                for ($i = 1; $i -le $varCounter; $i++) {
                    $lightVarName = "light$i"
                    $lightState = Get-Variable -Name $lightVarName -ValueOnly
                    $currentLightState = get-huelightstate -lightID $lightState.lightID -hueAPIKey $hueAPIKey -hueBridge $hueBridge
                    if ($currentLightState.lightOn -eq $true) {
                        Write-Host "Changing the brightness for $($currentLightState.lightID) to 1"
                        set-HueLightBrightness -lightID $currentLightState.lightID -brightness 1 -hueAPIKey $hueAPIKey -hueBridge $hueBridge
                    }
                }
                $FirstOnline = $true
            }
        }
        else {
            if ($FirstOnline) {
                # Transition to offline state
                for ($i = 1; $i -le $varCounter; $i++) {
                    $lightVarName = "light$i"
                    $lightState = Get-Variable -Name $lightVarName -ValueOnly
                    if ($lightState.lightOn -eq $true) {
                        Write-Host "Changing the brightness for $($currentLightState.lightID) to $($lightState.lightBrightness)"
                        set-HueLightBrightness -lightID $lightState.lightID -brightness $lightState.lightBrightness -hueAPIKey $hueAPIKey -hueBridge $hueBridge
                    }
                }
                $FirstOnline = $false
            }
        }
    }
}
