# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.0.3] - 2018-04-20

### PATCH
  #### Client : MelomindEngine
  - Work with a singleton (before Object with Class Methods)
  - SetEEGDelegate
  - SaveRecording (CallBack non-blocking process)
  
  #### BluetoothManager
  - Patch for found nil exception

  #### DeviceAcquisitionManager
  - Saturation & DC offset Notification

  #### EEGAcquisitionManager
  - re-implement StreamEEG & recording ( with Buffer and handle dynamically the number of octet send by the Melomind )
  - MBTJSONHelper : Save all json recording in "eegPacketJSONRecordings" 
  
  #### SyncServer
  - MBTBrainWebHelper : Method To send All JSON File

  #### Models
  - getArrayEEGPackets -> get reference of EEGPackets ( to remove them after saving )
  - removePackets(_ packets:[MBTEEGPacket]) -> Remove array which referencing EEGPackets
  - createNewEEGPacket(arrayData:[[Float]],nbChannels: Int) -> MBTEEGPacket -> Create a EEGPackets with ArrayData of [[Float]]