//
//  MBTSignalProcessingBridge.m
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

#import "MBTSignalProcessingBridge.h"
#import "MBTBridgeConstants.h"

#include <DataManipulation/MBT_Matrix.h>
#include <DataManipulation/MBT_ReadInputOrWriteOutput.h>
#include <Transformations/MBT_PWelchComputer.h>
#include <Algebra/MBT_Operations.h>
#include <Algebra/MBT_FindClosest.h>
#include <PreProcessing/MBT_BandPass_fftw3.h>
#include <PreProcessing/MBT_PreProcessing.h>

#include <NF_Melomind/MBT_ComputeCalibration.h>
#include <NF_Melomind/MBT_ComputeRelaxIndex.h>
#include <NF_Melomind/MBT_SmoothRelaxIndex.h>
#include <NF_Melomind/MBT_NormalizeRelaxIndex.h>
#include <NF_Melomind/MBT_RelaxIndexToVolum.h>
#include <NF_Melomind/MBT_ComputeIAFCalibration.h>
#include <NF_Melomind/MBT_ComputeRMS.h>
#include <NF_Melomind/MBT_ComputeIAF.h>
#include <NF_Melomind/Utils.h>
#include <NF_Melomind/MBT_NFConfig.h>
#include <NF_Melomind/MelomindAnalysisSingleton.h>
#include <SNR/MBT_SNR_Stats.h>
#include <QualityChecker/MBT_MainQC.h>

#include <mbtsdk-version.h>

#define SMOOTHINGDURATION 2

//==============================================================================
// MARK: - MBTSignalProcessingHelper
//==============================================================================

/// Signal Processing Bridge helper methods,
/// to help converting format between C++ and Obj-C++.
@interface MBTSignalProcessingHelper: NSObject
extern const float IAFinf;
extern const float IAFsup;

+ (NSArray *)fromVectorToNSArray:(std::vector<float>) vector;
+ (NSArray *)fromMatrixToNSArray:(MBT_Matrix<float>) matrix;
+ (MBT_Matrix<float>)fromNSArrayToMatrix:(NSArray*)array
                               andHeight:(int)height
                                andWidth:(int)width;
+ (std::vector<float>)fromNSArraytoVector:(NSArray *)array;
+ (void)setCalibrationParameters:
(std::map<std::string, std::vector<float>>) calibParameters;
+ (std::map<std::string, std::vector<float>>)getCalibrationParameters;

@end

@implementation MBTSignalProcessingHelper
static NSString* versionCPP = @MBT_SDK_VERSION;

static std::map<std::string, std::vector<float>> calibParams;

/// Converte *vector* to an Objective-C NSArray.
+ (NSArray*)fromVectorToNSArray:(std::vector<float>) vector {
  NSMutableArray * array = [[NSMutableArray alloc] init];
  for (int index = 0; index < int(vector.size()); index++) {
    NSNumber *data = [NSNumber numberWithFloat: vector[index]];
    [array addObject: data];
  }

  return (NSArray*) array;
}

/// Converte *MBT_Matrix* to an Objective-C NSArray.
+ (NSArray*)fromMatrixToNSArray:(MBT_Matrix<float>) matrix {
  NSMutableArray* array = [[NSMutableArray alloc] init];
  for (int index = 0; index < matrix.size().first; index++) {
    NSArray* vectorArray =
    [MBTSignalProcessingHelper fromVectorToNSArray: matrix.row(index)];
    [array addObject: vectorArray];
  }

  return (NSArray*)array;
}

/// Converte *NSArray* to *MBT_Matrix* format.
+ (MBT_Matrix<float>)fromNSArrayToMatrix:(NSArray*)array
                               andHeight:(int)height
                                andWidth:(int)width {
  auto matrix = MBT_Matrix<float>(height, width);

  for (int channelIndex = 0; channelIndex < height; channelIndex++) {
    for (int dataPoint = 0; dataPoint < width; dataPoint++) {
      const auto index = channelIndex * width + dataPoint;
      matrix(channelIndex, dataPoint) = [array[index] floatValue];
    }
  }

  return matrix;
}

+ (std::vector<float>) fromNSArraytoVector:(NSArray *)array {
  auto vector = std::vector<float>();
  const auto count = static_cast<int>(array.count);

  for (int i = 0; i < count; i++) {
    auto arrayValue = [array[i] floatValue];
    vector.push_back(arrayValue);
  }

  return vector;
}

+ (void) setCalibrationParameters:
(std::map<std::string, std::vector<float>>)calibParameters {
  calibParams = calibParameters;
}

+ (std::map<std::string, std::vector<float>>)getCalibrationParameters {
  return calibParams;
}

@end

//==============================================================================
// MARK: - MBTQualityCheckerBridge
//==============================================================================

@implementation MBTQualityCheckerBridge

/// Instance on *Main Quality Checker* to keep.
static MBT_MainQC *mainQC;

/// Initialize Main_QC, and save it.
+ (void)initializeMainQualityChecker:(float)sampRate accuracy:(float)accuracy {
  // Construction de kppv
  unsigned int kppv = 19;

  // Construction de costClass
  auto costClass = MBT_Matrix<float>(3, 3);
  for (int t = 0; t < costClass.size().first;t++) {
    for (int t1 = 0; t1 < costClass.size().second; t1++) {
      if (t == t1) {
        costClass(t, t1) = 0;
      } else {
        costClass(t, t1) = 1;
      }
    }
  }

  // Construction de costClassBad
  auto costClassBad = MBT_Matrix<float>(2, 2);
  for (int t = 0; t < costClassBad.size().first; t++) {
    for (int t1 = 0; t1 < costClassBad.size().second; t1++) {
      if (t == t1) {
        costClassBad(t, t1) = 0;
      } else {
        costClassBad(t, t1) = 1;
      }
    }
  }

  // Construction de potTrainingFeatures
  std::vector<std::vector<float>> potTrainingFeatures;

  // Construction de dataClean
  std::vector<std::vector<float>> dataClean;

  // Init of Main_QC.
  mainQC = new MBT_MainQC(sampRate,
                          trainingFeatures,
                          trainingClasses,
                          w,
                          mu,
                          sigma,
                          kppv,
                          costClass,
                          potTrainingFeatures,
                          dataClean,
                          spectrumClean,
                          cleanItakuraDistance,
                          accuracy,
                          trainingFeaturesBad,
                          trainingClassesBad,
                          wBad,
                          muBad,
                          sigmaBad,
                          costClassBad);
}

/// Dealloc MBT_MainQC instance when session is finished, for memory safety.
+ (void)deInitializeMainQualityChecker {
  delete mainQC;
}

/// Method to compute Quality for a EEGPacket, for each channel.
+ (NSArray*)computeQuality:(NSArray*)signal
                  sampRate:(NSInteger)sampRate
                nbChannels:(NSInteger)nbChannels
              packetLength:(NSInteger)packetLength {
  //    printf("Count Signal = %lu",[signal count]);
  // Transform EEG data into MBT_Matrix
  MBT_Matrix<float> signalMatrix =
  [MBTSignalProcessingHelper fromNSArrayToMatrix: signal
                                       andHeight:(int)nbChannels
                                        andWidth:(int)packetLength];

  // Compute Quality
  mainQC->MBT_ComputeQuality(signalMatrix);

  // Getting the qualities in a cpp format
  std::vector<float> qualities = mainQC->MBT_get_m_quality();

  // Converting the qualities to an Objective-C format.
  return [MBTSignalProcessingHelper fromVectorToNSArray: qualities];
}

/// Method to get the modified EEG Data, according to the quality value.
+ (NSArray*)getModifiedEEGData {
  MBT_Matrix<float> modifiedData = mainQC->MBT_get_m_inputData();

  return [MBTSignalProcessingHelper fromMatrixToNSArray: modifiedData];
}

+ (NSString*)getVersion {
  return @MBT_SDK_VERSION;
}

@end

//==============================================================================
// MARK: - MBTCalibrationBridge
//==============================================================================

@implementation MBTCalibrationBridge

/// Method to get the calibration dictionnary.
+ (NSDictionary*)computeCalibration:(NSArray*)modifiedChannelsData
                          qualities:(NSArray*)qualities
                       packetLength:(NSInteger)packetLength
                       packetsCount:(NSInteger)packetCount
                           sampRate:(NSInteger)sampleRate {
  const auto height = static_cast<int>(qualities.count / packetCount);
  const auto width = static_cast<int>(packetLength * packetCount);

  // Put the modified EEG data in a matrix.
  MBT_Matrix<float> calibrationRecordings =
  [MBTSignalProcessingHelper fromNSArrayToMatrix: modifiedChannelsData
                                       andHeight: height
                                        andWidth: width];

  // Put the qualities in a matrix.
  auto calibrationRecordingsQuality =
  [MBTSignalProcessingHelper fromNSArrayToMatrix: qualities
                                       andHeight: height
                                        andWidth: static_cast<int>(packetCount)];

  // Getting the map.
  auto iafMedian = MBT_ComputeIAFCalibration(calibrationRecordings,
                                             calibrationRecordingsQuality,
                                             sampleRate,
                                             static_cast<int>(packetLength),
                                             IAFinf,
                                             IAFsup);

  auto paramCalib = MBT_ComputeCalibration(calibrationRecordings,
                                           calibrationRecordingsQuality,
                                           sampleRate,
                                           static_cast<int>(packetLength),
                                           iafMedian[0],
                                           iafMedian[1],
                                           SMOOTHINGDURATION);
  paramCalib["iafCalib"] = iafMedian;

  // Save calibration parameters received.
  [MBTSignalProcessingHelper setCalibrationParameters: paramCalib];

  // Converting the parameters to an Obj-C format
  NSMutableDictionary* parametersDictionnary =
  [[NSMutableDictionary alloc] init];

  for (auto parameter: paramCalib) {
    NSString *parameterName =
    [NSString stringWithCString: parameter.first.c_str()
                       encoding:[NSString defaultCStringEncoding]];
    NSArray *parameterValue =
    [MBTSignalProcessingHelper fromVectorToNSArray: parameter.second];
    [parametersDictionnary setObject: parameterValue forKey: parameterName];
  }

  return parametersDictionnary;
}

@end

//==============================================================================
// MARK: - MBTRelaxIndexBridge
//==============================================================================

@implementation MBTRelaxIndexBridge

static vector<float>pastRelaxIndex;
static vector<float>smoothedRelaxIndex;
static vector<float>volume;
static vector<float>histFreq;

+ (float)computeRelaxIndex:(NSArray*)signal
                  sampRate:(NSInteger)sampRate
                nbChannels:(NSInteger)nbChannels
       lastPacketQualities:(NSArray*)lastPacketQualities {
  const unsigned int packetLength = static_cast<int>(signal.count / nbChannels);

  auto signalMatrix =
  [MBTSignalProcessingHelper fromNSArrayToMatrix: signal
                                       andHeight: static_cast<int>(nbChannels)
                                        andWidth: packetLength];

  auto calibrationParams = [MBTSignalProcessingHelper getCalibrationParameters];

  if (histFreq.size() == 0) {
    histFreq = calibrationParams["histFrequencies"];
  }

  const auto sampleRate = static_cast<float>(sampRate);
  const auto smoothingDuration = SMOOTHINGDURATION;
  const auto bufferSize = 1;
  const auto configuration =
  MBT_NFConfig { sampleRate, packetLength, smoothingDuration, bufferSize };

  const auto minFactor = 0.9f;
  const auto maxFactor = 1.5f;
  const auto minMaxRmsCalibration = computeMinMax(calibrationParams["snrCalib"],
                                    minFactor,
                                    maxFactor);

  const auto lastPacketQualitiesVector =
  [MBTSignalProcessingHelper fromNSArraytoVector: lastPacketQualities];

  const auto newVolum = main_relaxIndex(configuration,
                                        calibrationParams,
                                        signalMatrix,
                                        pastRelaxIndex,
                                        smoothedRelaxIndex,
                                        volume,
                                        minMaxRmsCalibration,
                                        lastPacketQualitiesVector);
  return newVolum;
}

+ (NSDictionary*)getSessionMetadata {
  NSMutableDictionary* dicoMetadata = [[NSMutableDictionary alloc]init];

  NSArray *parameterValue =
  [MBTSignalProcessingHelper fromVectorToNSArray: pastRelaxIndex];
  [dicoMetadata setObject: parameterValue forKey:@"rawRelaxIndexes"];

  parameterValue =
  [MBTSignalProcessingHelper fromVectorToNSArray: smoothedRelaxIndex];
  [dicoMetadata setObject: parameterValue forKey:@"smoothedRelaxIndex"];

  parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray: histFreq];
  [dicoMetadata setObject: parameterValue forKey:@"histFrequencies"];

  return dicoMetadata;
}

+(void) reinitRelaxIndex {
  pastRelaxIndex.clear();
  smoothedRelaxIndex.clear();
  volume.clear();
  histFreq.clear();
}

@end

//==============================================================================
// MARK: - MBTSNRStatisticsBridge
//==============================================================================

@implementation MBTSNRStatisticsBridge

+ (NSDictionary*)computeSessionStatistics:(NSArray *)inputDataSNR
                                threshold:(float)threshold {
  auto inputDataVector =
  [MBTSignalProcessingHelper fromNSArraytoVector: inputDataSNR];

  auto statisticsObj = SNR_Statistics(inputDataVector);
  auto statisticsResults = statisticsObj.CalculateSNRStatistics(inputDataVector,
                                                                threshold);

  // Converting the parameters to a NSDictionnary
  NSMutableDictionary * resultsDictionnary = [[NSMutableDictionary alloc] init];
  for (auto parameter: statisticsResults) {
    NSString *parameterName =
    [NSString stringWithCString: parameter.first.c_str()
                       encoding:[NSString defaultCStringEncoding]];
    NSNumber *parameterValue = [NSNumber numberWithFloat: parameter.second];
    [resultsDictionnary setObject: parameterValue forKey: parameterName];
  }

  return resultsDictionnary;
}

@end

//==============================================================================
// MARK: - MBTMelomindAnalysis
//==============================================================================

@implementation MBTMelomindAnalysis

+ (void)resetSession {
  MelomindAnalysisSingleton::getInstance().resetSession();
}

+ (float)sessionMeanAlphaPower {
  return MelomindAnalysisSingleton::getInstance().getSessionMeanAlphaPower();
}

+ (float)sessionMeanRelativeAlphaPower {
  return
  MelomindAnalysisSingleton::getInstance().getSessionMeanRelativeAlphaPower();
}

+ (float)sessionConfidence {
  return MelomindAnalysisSingleton::getInstance().getSessionConfidence();
}

+ (NSArray*)sessionAlphaPowers {
  auto alphaPowers =
  MelomindAnalysisSingleton::getInstance().getSessionAlphaPowers();
  return [MBTSignalProcessingHelper fromVectorToNSArray: alphaPowers];
}

+ (NSArray*)sessionRelativeAlphaPowers {
  auto relativeAlphaPowers =
  MelomindAnalysisSingleton::getInstance().getSessionRelativeAlphaPowers();
  return [MBTSignalProcessingHelper fromVectorToNSArray: relativeAlphaPowers];
}

+ (NSArray*)sessionQualities {
  auto qualities =
  MelomindAnalysisSingleton::getInstance().getSessionQualities();
  return [MBTSignalProcessingHelper fromVectorToNSArray: qualities];
}

@end
