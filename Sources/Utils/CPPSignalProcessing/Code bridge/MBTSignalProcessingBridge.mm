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
#include "MBT_ComputeSNR.h"
#include "MBT_ComputeCalibration.h"
#include "MBT_ComputeRelaxIndex.h"
#include "MBT_SmoothRelaxIndex.h"
#include "MBT_NormalizeRelaxIndex.h"
#include "MBT_RelaxIndexToVolum.h"
#include "MBT_PreProcessing.h"


/// Signal Processing Bridge helper methods.
@interface MBTSignalProcessingHelper: NSObject
+ (NSArray *)fromVectorToNSArray:(std::vector<float>) vector;
+ (NSArray *)fromMatrixToNSArray:(MBT_Matrix<float>) matrix;
+ (MBT_Matrix<float>)fromNSArrayToMatrix:(NSArray *)array
                               andHeight:(int)height
                                andWidth:(int)width;
@end

@implementation MBTSignalProcessingHelper

/// Converte vector to an Objective-C NSArray.
+ (NSArray *)fromVectorToNSArray:(std::vector<float>) vector {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int index = 0; index < int(vector.size()); index++)
    {
        NSNumber *data = [NSNumber numberWithFloat:vector[index]];
        [array addObject:data];
    }

    return (NSArray*) array;
}

/// Converte MBT_Matrix to an Objective-C NSArray.
+ (NSArray *)fromMatrixToNSArray:(MBT_Matrix<float>) matrix {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int index = 0; index < matrix.size().first; index++)
    {
        NSArray *vectorArray = [MBTSignalProcessingHelper fromVectorToNSArray:matrix.row(index)];
        [array addObject:vectorArray];
    }

    return (NSArray*) array;
}

/// Converte NSArray to MBT_Matrix format.
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
@end



//MARK: -
/// Quality Checker Bridge methods, for use in Swift.
@implementation MBTQualityCheckerBridge

static MBT_MainQC *mainQC;


+ (void)initializeMainQualityChecker:(float)sampRate
                             accuracy:(float)accuracy {
    // Construction de kppv
    unsigned int kppv = 10;

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

    // Construction de potTrainingFeatures
    std::vector< std::vector<float> > potTrainingFeatures;

    // Construction de dataClean
    std::vector< std::vector<float> > dataClean;

    // Init of Main_QC.
    mainQC = new MBT_MainQC(sampRate, trainingFeatures, trainingClasses, w, mu, sigma, kppv, costClass, potTrainingFeatures, dataClean, spectrumClean, cleanItakuraDistance, accuracy);
}

/// Dealloc MBT_MainQC instance, for memory safety.
+ (void)deInitializeMainQualityChecker {
    delete mainQC;
}

///
+ (NSArray*) computeQuality: (NSArray*) signal
                   sampRate: (NSInteger) sampRate
                 nbChannels: (NSInteger) nbChannels
               nbDataPoints: (NSInteger) nbDataPoints
{
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

///
+ (NSArray*) getModifiedEEGData {
    MBT_Matrix<float> modifiedData = mainQC->MBT_get_m_inputData();

    return [MBTSignalProcessingHelper fromMatrixToNSArray:modifiedData];
}

@end

//MARK: -

@implementation MBTCalibrationBridge

+ (NSDictionary *)computeCalibration: (NSArray *)modifiedChannelsData
                 qualities: (NSArray *)qualities
              packetLength: (NSInteger)packetLength
              packetsCount: (NSInteger)packetsCount
                  sampRate: (NSInteger)sampRate
{
    float IAFinf = 7;
    float IAFsup = 13;

    int height = (int)(qualities.count / packetsCount);
    
    // Put the modified EEG data in a matrix.
    MBT_Matrix<float> calibrationRecordings = [MBTSignalProcessingHelper fromNSArrayToMatrix:modifiedChannelsData
                                                                                   andHeight:height
                                                                                    andWidth:(int)(packetLength * packetsCount)];
    
    // Put the qualities in a matrix.
    MBT_Matrix<float> calibrationRecordingsQuality = [MBTSignalProcessingHelper fromNSArrayToMatrix:modifiedChannelsData
                                                                                          andHeight:height
                                                                                           andWidth:(int)packetsCount];
    
    // Set the thresholds for the outliers
    // -----------------------------------
    MBT_Matrix<float> Bounds(calibrationRecordings.size().first,2);
    MBT_Matrix<float> Test(calibrationRecordings.size().first, calibrationRecordings.size().second);
    
    for (int ch=0; ch<calibrationRecordings.size().first; ch++)
    {
        vector<float> signal_ch = calibrationRecordings.row(ch);
        
        if (all_of(signal_ch.begin(), signal_ch.end(), [](double testNaN){return isnan(testNaN);}) )
        {
            errno = EINVAL;
            perror("ERROR: BAD CALIBRATION - WE HAVE ONLY NAN VALUES");
        }
        
        // skip the NaN values in order to calculate the Bounds
        vector<float>tmp_signal_ch = SkipNaN(signal_ch);
        
        // find the bounds
        vector<float> tmp_Bounds = CalculateBounds(tmp_signal_ch); // Set the thresholds for outliers
        Bounds(ch,0) = tmp_Bounds[0];
        Bounds(ch,1) = tmp_Bounds[1];
        
        // basically, we convert from vector<float> to vector<double>
        vector<double> CopySignal_ch(signal_ch.begin(), signal_ch.end());
        vector<double> Copytmp_Bounds(tmp_Bounds.begin(), tmp_Bounds.end());
        
        // set outliers to nan
        vector<double> InterCopySignal_ch = MBT_OutliersToNan(CopySignal_ch, Copytmp_Bounds);
        for (unsigned int t = 0 ; t < InterCopySignal_ch.size(); t++)
            Test(ch,t) = (float) InterCopySignal_ch[t];
    }
    
    // interpolate the nan values between the channels
    MBT_Matrix<float> FullyInterpolatedTest = MBT_InterpolateBetweenChannels(Test);
    // interpolate the nan values across each channel
    MBT_Matrix<float> InterpolatedAcrossChannels = MBT_InterpolateAcrossChannels(FullyInterpolatedTest);
    
    // Getting the map.
    std::map<std::string, std::vector<float> > paramCalib = MBT_ComputeCalibration(calibrationRecordings,
                                                                                   calibrationRecordingsQuality,
                                                                                   (int)sampRate,
                                                                                   (int)packetLength,
                                                                                   IAFinf,
                                                                                   IAFsup,
                                                                                   Bounds);
    
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


//MARK: -

/// Bridge method to get the Relax Index
@implementation MBTRelaxIndexBridge

+ (float)computeRelaxIndex {
   
    return 0.6f;
}

@end
