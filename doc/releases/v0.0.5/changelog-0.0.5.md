# Changelog
All notable changes to this project will be documented in this file.

## [Released]

## [0.0.5] - 2018-07-13

### UPDATE RELEASE
    - Add the update of Melomind
    - Add the true version CPP in EEG json
    - Patch bug true recording type in EEG JSON (Source:FreeSession, RelaxProgram & Default / DataType: JOURNEY, SWITCH, STABILITY & Default / RecordType: ADJUSTEMENT, CALIBRATION, SESSION, RAWDATA & STUDY)
    - Patch bug connection bluetooth (when retry to connect paired device when before you try it and fail)
    - Patch bug relax index calculation with 30 eegpackets (now is 4)

### ADDED 
  #### Model
    - OAD : MBTOADManager
    
 #### Manager 
    - BluetoothManager : ProcessOAD -> PrepareStartOAD / StartOAD / SendOADBuffer / Manager EventDelegate(OnReady/OnCompleted/DidOadFail/TimeOut)
    - MBTSignalAcquistionManager :  SignalProcessingBridge -> getVersion (CPP)

#### Client 
    - MelomindEngine : param to sendEEGToBrain -> removeFile
    
### PATCH
  #### General
    - Bugfixes (patch crashes)

 #### Model
    - RecodInfo : spVersion update with CPPVersion
    
 #### Manager
    - BluetoothManager : Connection Bluetooth Bug (eventDelegate = nil so cant know when bleperipheral is connected)
    - ComputeRelaxIndex : With 4 eegpackets (before : 30)
    - AcquistionManager : correction error when recordInfo is modify during saveRecording

