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

@interface MBTQualityCheckerBridge: NSObject 

+ (void)initializeMainQualityChecker:(float) sampRate
                             accuracy:(float) accuracy;
+ (void)deInitializeMainQualityChecker;
+ (NSArray*) computeQuality: (NSArray*) signal
                   sampRate: (NSInteger) sampRate
                 nbChannels: (NSInteger) nbChannels
               nbDataPoints: (NSInteger) nbDataPoints;
//+ (NSArray*) getModifiedEEGData;

@end


#endif /* MBTSignalProcessingBridge_h */
