//
//  MBTSignalProcessingBridge.h
//  MyBrainTechnologiesSDK
//
//  Created by Baptiste Rasschaert on 15/09/2017.
//  Copyright © 2017 MyBrainTechnologies. All rights reserved.
//

#ifndef MBTSignalProcessingBridge_h
#define MBTSignalProcessingBridge_h

#import <Foundation/Foundation.h>

#include "MBT_Matrix.h" // use of the class MBT_Matrix
#include "MBT_MainQC.h" // use of the class MBT_Matrix
#include "MBT_ReadInputOrWriteOutput.h" // use of the class MBT_ReadInputOrWriteOutput

#include "MBT_PWelchComputer.h" // use of the class MBT_PWelchComputer
#include "MBT_Operations.h"

#include "MBT_BandPass_fftw3.h"

@interface MBTQualityCheckerBridge: NSObject

+ (MBT_MainQC)initializeMainQualityChecker;

@end


#endif /* MBTSignalProcessingBridge_h */
