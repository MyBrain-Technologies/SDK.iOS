//
//  MBTSignalProcessingBridge.m
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

#import "MBTSignalProcessingBridge.h"
#import "MBTBridgeConstants.h"

#include "MBT_Matrix.h" // use of the class MBT_Matrix
#include "MBT_MainQC.h" // use of the class MBT_Matrix
#include "MBT_ReadInputOrWriteOutput.h" // use of the class MBT_ReadInputOrWriteOutput

#include "MBT_PWelchComputer.h" // use of the class MBT_PWelchComputer
#include "MBT_Operations.h"

#include "MBT_BandPass_fftw3.h"

#include "MBT_FindClosest.h"
#include "MBT_ComputeCalibration.h"
#include "MBT_ComputeRelaxIndex.h"
#include "MBT_SmoothRelaxIndex.h"
#include "MBT_NormalizeRelaxIndex.h"
#include "MBT_RelaxIndexToVolum.h"
#include "MBT_PreProcessing.h"
#include "MBT_ComputeIAFCalibration.h"
#include "MBT_ComputeRMS.h"
#include "MBT_ComputeIAF.h"

#include "MBT_SNR_Stats.h"

#include "version.h"

#define SMOOTHINGDURATION 2


/// Signal Processing Bridge helper methods,
/// to help converting format between C++ and Obj-C++.
@interface MBTSignalProcessingHelper: NSObject
extern const float IAFinf;
extern const float IAFsup;


+ (NSArray *)fromVectorToNSArray:(std::vector<float>) vector;
+ (NSArray *)fromMatrixToNSArray:(MBT_Matrix<float>) matrix;
+ (MBT_Matrix<float>)fromNSArrayToMatrix:(NSArray *)array
                               andHeight:(int)height
                                andWidth:(int)width;
+ (std::vector<float>)fromNSArraytoVector:(NSArray *)array;

+ (void)setCalibrationParameters:(std::map<std::string, std::vector<float>>) calibParameters;
+ (std::map<std::string, std::vector<float>>)getCalibrationParameters;
@end

@implementation MBTSignalProcessingHelper
static NSString* versionCPP = @VERSION;

const float IAFinf = 6;
const float IAFsup = 13;

static std::map<std::string, std::vector<float>> calibParams;

/// Converte *vector* to an Objective-C NSArray.
+ (NSArray *)fromVectorToNSArray:(std::vector<float>) vector {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int index = 0; index < int(vector.size()); index++)
    {
        NSNumber *data = [NSNumber numberWithFloat:vector[index]];
        [array addObject:data];
    }

    return (NSArray*) array;
}

/// Converte *MBT_Matrix* to an Objective-C NSArray.
+ (NSArray *)fromMatrixToNSArray:(MBT_Matrix<float>) matrix {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int index = 0; index < matrix.size().first; index++)
    {
        NSArray *vectorArray = [MBTSignalProcessingHelper fromVectorToNSArray:matrix.row(index)];
        [array addObject:vectorArray];
    }

    return (NSArray*) array;
}

/// Converte *NSArray* to *MBT_Matrix* format.
+ (MBT_Matrix<float>)fromNSArrayToMatrix:(NSArray *)array andHeight:(int)height andWidth:(int)width {
    MBT_Matrix<float> matrix = MBT_Matrix<float>((int) height, (int) width);

    for (int channelIndex = 0; channelIndex < height; channelIndex++)
    {
        for (int dataPoint = 0; dataPoint < width; dataPoint++)
        {
            matrix(channelIndex, dataPoint) = [array[channelIndex * width + dataPoint] floatValue];
        }
    }

    return matrix;
}

+ (std::vector<float>)fromNSArraytoVector:(NSArray *)array {
    std::vector<float> vector;
    
    for (int i = 0; i < (int)array.count; i++) {
        float arrayValue = [array[i] floatValue];
        vector.push_back(arrayValue);
    }
    
    return vector;
}

+ (void)setCalibrationParameters:(std::map<std::string, std::vector<float>>) calibParameters {
    calibParams = calibParameters;
}

+ (std::map<std::string, std::vector<float>>)getCalibrationParameters {
    return calibParams;
}

@end



//MARK: -
/// Quality Checker Bridge methods, for use in Swift.
@implementation MBTQualityCheckerBridge

/// Instance on *Main Quality Checker* to keep.
static MBT_MainQC *mainQC;

/// Initialize Main_QC, and save it.
+ (void)initializeMainQualityChecker:(float)sampRate
                             accuracy:(float)accuracy {
    // Construction de kppv
    unsigned int kppv = 19;

    // Construction de costClass
    MBT_Matrix<float> costClass(3,3);
    for (int t=0;t<costClass.size().first;t++)
    {
        for (int t1=0;t1<costClass.size().second;t1++)
        {
            if (t == t1)
            {
                costClass(t,t1) = 0;
            }
            else
            {
                costClass(t,t1) = 1;
            }
        }
    }
    
    // Construction de costClassBad
    MBT_Matrix<float> costClassBad(2,2);
    for (int t=0;t<costClass.size().first;t++)
    {
        for (int t1=0;t1<costClass.size().second;t1++)
        {
            if (t == t1)
            {
                costClass(t,t1) = 0;
            }
            else
            {
                costClass(t,t1) = 1;
            }
        }
    }

    // Construction de potTrainingFeatures
    std::vector< std::vector<float> > potTrainingFeatures;

    // Construction de dataClean
    std::vector< std::vector<float> > dataClean;

    // Init of Main_QC.
    mainQC = new MBT_MainQC(sampRate,
                            trainingFeatures,
                            trainingClasses,
                            w, mu, sigma, kppv,
                            costClass,
                            potTrainingFeatures,
                            dataClean,
                            spectrumClean,
                            cleanItakuraDistance,
                            accuracy,
                            trainingFeaturesBad,
                            trainingClassesBad,
                            wBad,muBad,sigmaBad,costClassBad);
    
}

/// Dealloc MBT_MainQC instance when session is finished, for memory safety.
+ (void)deInitializeMainQualityChecker {
    delete mainQC;
}

/// Method to compute Quality for a EEGPacket, for each channel.
+ (NSArray*) computeQuality: (NSArray*) signal
                   sampRate: (NSInteger) sampRate
                 nbChannels: (NSInteger) nbChannels
               nbDataPoints: (NSInteger) nbDataPoints
{

//    printf("Count Signal = %lu",[signal count]);
    // Transform EEG data into MBT_Matrix
    MBT_Matrix<float> signalMatrix = [MBTSignalProcessingHelper fromNSArrayToMatrix:signal
                                                                          andHeight:(int)nbChannels
                                                                           andWidth:(int)nbDataPoints];
    // Compute Quality
    mainQC->MBT_ComputeQuality(signalMatrix);
    // Getting the qualities in a cpp format
    std::vector<float> qualities = mainQC->MBT_get_m_quality();
    // Converting the qualities to an Objective-C format.
    return [MBTSignalProcessingHelper fromVectorToNSArray:qualities];
}

/// Method to get the modified EEG Data, according to the quality value.
+ (NSArray*) getModifiedEEGData {
    MBT_Matrix<float> modifiedData = mainQC->MBT_get_m_inputData();

    return [MBTSignalProcessingHelper fromMatrixToNSArray:modifiedData];
}

+ (NSString*) getVersion {
    return @VERSION;
}

@end

//MARK: -

/// Bridge methods for calibration calculation, for a group of
/// *MBTEEGPacket*.
@implementation MBTCalibrationBridge

/// Method to get the calibration dictionnary.
+ (NSDictionary *)computeCalibration: (NSArray *)modifiedChannelsData
                 qualities: (NSArray *)qualities
              packetLength: (NSInteger)packetLength
              packetsCount: (NSInteger)packetsCount
                  sampRate: (NSInteger)sampRate
{
    int height = (int)(qualities.count / packetsCount);
    
    // Put the modified EEG data in a matrix.
    MBT_Matrix<float> calibrationRecordings = [MBTSignalProcessingHelper fromNSArrayToMatrix:modifiedChannelsData
                                                                                   andHeight:height
                                                                                    andWidth:(int)(packetLength * packetsCount)];
    
    // Put the qualities in a matrix.
    MBT_Matrix<float> calibrationRecordingsQuality = [MBTSignalProcessingHelper fromNSArrayToMatrix:qualities
                                                                                          andHeight:height
                                                                                           andWidth:(int)packetsCount];
    
    // Getting the map.
    std::vector<float> iafMedian = MBT_ComputeIAFCalibration(calibrationRecordings,
                                                             calibrationRecordingsQuality,
                                                             sampRate,
                                                             packetLength,
                                                             IAFinf,
                                                             IAFsup);

    std::map<std::string, std::vector<float> > paramCalib = MBT_ComputeCalibration(calibrationRecordings,calibrationRecordingsQuality,
                                                                                   sampRate,
                                                                                   packetLength,
                                                                                   iafMedian[0],
                                                                                   iafMedian[1],
                                                                                   SMOOTHINGDURATION);
    paramCalib["iafCalib"] = iafMedian;

    // Save calibration parameters received.
    [MBTSignalProcessingHelper setCalibrationParameters:paramCalib];
    
    // Converting the parameters to an Obj-C format
    NSMutableDictionary * parametersDictionnary = [[NSMutableDictionary alloc] init];
    
    for (auto parameter: paramCalib)
    {
        NSString *parameterName = [NSString stringWithCString: parameter.first.c_str()
                                                     encoding:[NSString defaultCStringEncoding]];
        NSArray *parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray:parameter.second];
        [parametersDictionnary setObject:parameterValue forKey:parameterName];
    }
    
    return parametersDictionnary;
}
    

@end


//MARK: - RelaxIndex

/// Bridge method to get the Relax Index
@implementation MBTRelaxIndexBridge

static vector<float>pastRelaxIndex;
static vector<float>smoothedRelaxIndex;
static vector<float>volume;
static vector<float>histFreq;

+ (float)computeRelaxIndex:(NSArray *)signal
                  sampRate:(NSInteger)sampRate
                nbChannels: (NSInteger) nbChannels
{
    int width = (int)(signal.count / nbChannels);
    MBT_Matrix<float> signalMatrix = [MBTSignalProcessingHelper fromNSArrayToMatrix:signal
                                                                          andHeight:(int)nbChannels
                                                                           andWidth:width];
    
    std::map<std::string, std::vector<float>> calibrationParams = [MBTSignalProcessingHelper getCalibrationParameters];
    
    if (histFreq.size() == 0) {
        histFreq = calibrationParams["histFrequencies"];
    }
    
    float newVolum = main_relaxIndex(sampRate, calibrationParams, signalMatrix, histFreq, pastRelaxIndex, smoothedRelaxIndex, volume);

    return newVolum;
}
    
static float main_relaxIndex(const float sampRate, std::map<std::string, std::vector<float> > paramCalib,
                             const MBT_Matrix<float> &sessionPacket, std::vector<float> &histFreq, std::vector<float> &pastRelaxIndex, std::vector<float> &resultSmoothedRMS, std::vector<float> &resultVolum)
{
    
    std::vector<float> errorMsg = paramCalib["errorMsg"];
    std::vector<float> snrCalib = paramCalib["snrCalib"];
    std::vector<float> iafMedian = paramCalib["iafCalib"];
    
    // Session-----------------------------------
    float rmsValue = MBT_ComputeRelaxIndex(sessionPacket,
                                           errorMsg,
                                           sampRate, iafMedian[0], iafMedian[1], histFreq);
    
    pastRelaxIndex.push_back(rmsValue); // incrementation of pastRelaxIndex
    float smoothedRelaxIndex = MBT_SmoothRelaxIndex(pastRelaxIndex, SMOOTHINGDURATION);
    
    float sum = 0.0;
    float avg = 0.0;
    long indMax = 0.0;
    long indMin = 0.0;
    float minVal = 0.0;
    float maxVal = 0.0;
    
    std::vector<float>::iterator result;
    result = std::max_element(snrCalib.begin(), snrCalib.end());
    indMax = std::distance(snrCalib.begin(), result);
    result = std::min_element(snrCalib.begin(), snrCalib.end());
    indMin = std::distance(snrCalib.begin(), result);
    
    for(int i = 0; i < snrCalib.size(); i++){
        sum += snrCalib[i];
    }
    avg = sum / snrCalib.size();
    
    maxVal = avg*1.5f;
    
    minVal = snrCalib[indMin]*0.9f;
    
    float volum = MBT_RelaxIndexToVolum(smoothedRelaxIndex, minVal, maxVal); // warning it's not the same inputs than previously
    
    resultSmoothedRMS.push_back(smoothedRelaxIndex);
    
    resultVolum.push_back(volum);
    
    return volum;
}

+ (NSDictionary *) getSessionMetadata {
    NSMutableDictionary* dicoMetadata = [[NSMutableDictionary alloc]init];
    

    NSArray *parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray:pastRelaxIndex];
    [dicoMetadata setObject:parameterValue forKey:@"rawRelaxIndexes"];
    
    parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray:smoothedRelaxIndex];
    [dicoMetadata setObject:parameterValue forKey:@"smoothedRelaxIndex"];

//    parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray:volume];
//    [dicoMetadata setObject:parameterValue forKey:@"volume"];
    
    parameterValue = [MBTSignalProcessingHelper fromVectorToNSArray:histFreq];
    [dicoMetadata setObject:parameterValue forKey:@"histFrequencies"];
    
    return dicoMetadata;
}

+(void) reinitRelaxIndex {
    pastRelaxIndex.clear();
    smoothedRelaxIndex.clear();
    volume.clear();
    histFreq.clear();
}

@end


//MARK: -

/// Bridge method for SNR Statistics
@implementation MBTSNRStatisticsBridge

+ (NSDictionary *)computeSessionStatistics:(NSArray *)inputDataSNR
                                 threshold:(float)threshold
{
    std::vector<float> inputDataVector = [MBTSignalProcessingHelper fromNSArraytoVector:inputDataSNR];
    SNR_Statistics statisticsObj = SNR_Statistics(inputDataVector);
    std::map<string, float> statisticsResults = statisticsObj.CalculateSNRStatistics(inputDataVector, threshold);
    
    // Converting the parameters to a NSDictionnary
    NSMutableDictionary * resultsDictionnary = [[NSMutableDictionary alloc] init];
    for (auto parameter: statisticsResults)
    {
        NSString *parameterName = [NSString stringWithCString: parameter.first.c_str()
                                                     encoding:[NSString defaultCStringEncoding]];
        NSNumber *parameterValue = [NSNumber numberWithFloat:parameter.second];
        [resultsDictionnary setObject:parameterValue forKey:parameterName];
    }
    
    return resultsDictionnary;
}

@end
