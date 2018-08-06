# Changelog
Release notes - Melomind.iOS - Version 0.0.6

## [Released]

## [0.0.6] - 2018-08-03

### UPDATE RELEASE
    - Add event did require reboot bluetooth and user did reboot bluetooth
    - Add ownerdId In JSONEEG
    - Patch Get Info before test new version firmware version
    - Patch Send JSONEEG with the good URL (prod url for the Release)
    - Patch event onConnectionEstablished after discover all Characteristic
    
### PATCH
    #### Client
    - MelomindEngine : add IsNewVersionAvailable callback & SendEEGFile with baseURL ( prod or preprod ) 
    #### Model
    - RecodInfo : spVersion update with CPPVersion
    - Device : Correction JSONEEG
    #### Helper
    - BrainWebHelper : all functions need baseUrl to create APIRequest
    #### Manager
    - BluetoothManager : 
            - PrepareDeviceWithInfo (allows us to start a process with a minimum of device information)
            - Add didRequireToRebootBluetooth eventDelegate function to ask user to reboot the bluetooth after oad end and headset disconnect
            - Add process to detect 2 new function in the Delegate :  & didRebootBluetooth
    - AcquisitionManager : Add "context" : { "ownerId" : Int } to  JSONEEG