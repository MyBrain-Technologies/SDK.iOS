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
