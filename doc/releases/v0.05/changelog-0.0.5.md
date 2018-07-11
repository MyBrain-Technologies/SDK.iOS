# Changelog
All notable changes to this project will be documented in this file.

## [Released]

## [0.0.5] - 2018-06-01

### ADDED 
  #### Model
  	- OAD : OADManager
  #### BluetoothManager
  	- OAD : Process OAD : PrepareStartOAD / StartOAD / SendOADBuffer / Manager EventDelegate(OnReady/OnCompleted/DidOadFail/TimeOut)

### PATCH
  #### General
  - Bugfixes (patch crashes)
  
  #### BluetoothManager
  - Connection Bluetooth Bug (eventDelegate = nil so cant know when bleperipheral is connected)

  #### DeviceAcquisitionManager
  - ComputeRelaxIndex : With 4 eegpackets (before : 30)

