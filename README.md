# Powershell module for managing Philips Hue

## Description:
You finally had time to watch a movie, but realised that you forgot to change the lights brightness in the room.  
This script will monitor if your TV is turned on (responds to ICMP), and then turn down all the lights.  
Once the TV is turned of (stops responding to ICMP), the lights are then returned to its original state.

Its based on the Philips Hue API v2 (https://developers.meethue.com/develop/hue-api-v2/) and requires a Philips Hue Bridge to be present on the local network.
You will need to obtain an API key for the Hue bridge - a guide on how to to that, can be seen here. 
https://developers.meethue.com/develop/hue-api-v2/getting-started/



## Requirements:
Powershell 7 or higher.  

## Installation:
Import-module C:\path\to\file\icmphue.psm1 -force



## Examples:
**Set-HueLights**  
Set-HueLights -roomName "Stue" -hueAPIKey "your-hue-api-key-here" -hueBridge "192.168.5.50" -monitorTarget "192.168.20.51"