function Set-HueLights {
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
