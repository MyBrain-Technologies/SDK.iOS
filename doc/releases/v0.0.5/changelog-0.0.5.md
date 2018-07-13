# Changelog
All notable changes to this project will be documented in this file.

## [Released]

## [0.0.5] - 2018-06-01

### ADDED 
  #### Model
    - OAD : OADManager
    
 #### Manager 
    - BluetoothManager : Process OAD -> PrepareStartOAD / StartOAD / SendOADBuffer / Manager EventDelegate(OnReady/OnCompleted/DidOadFail/TimeOut)
    - MBTSignalAcquistionManager :  SignalProcessingBridge -> getVersion (CPP)

#### Client 
    - MelomindEngine : : param to sendEEGToBrain -> removeFile
    
### PATCH
  #### General
    - Bugfixes (patch crashes)

 #### Model
    - RecodInfo : spVersion update with CPPVersion
    
 #### Manager
    - BluetoothManager : Connection Bluetooth Bug (eventDelegate = nil so cant know when bleperipheral is connected)
    - ComputeRelaxIndex : With 4 eegpackets (before : 30)
    - AcquistionManager : correction error when recordInfo is modify during saveRecording

