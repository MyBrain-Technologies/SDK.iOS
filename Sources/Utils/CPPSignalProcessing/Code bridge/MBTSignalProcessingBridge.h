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
               packetLength: (NSInteger) packetLength;

+ (NSArray*) getModifiedEEGData;

+ (NSString*) getVersion;

@end





@interface MBTCalibrationBridge: NSObject

+ (NSDictionary *)computeCalibration: (NSArray *)modifiedChannelsData
                 qualities: (NSArray *)qualities
              packetLength: (NSInteger)packetLength
              packetsCount: (NSInteger)packetsCount
                  sampRate: (NSInteger)sampRate;

@end




@interface MBTRelaxIndexBridge: NSObject

+ (float)computeRelaxIndex:(NSArray *)signal
                  sampRate:(NSInteger)sampRate
                nbChannels: (NSInteger) nbChannels
                lastPacketQualities:(NSArray*) lastPacketQualities;

@end


@interface MBTSNRStatisticsBridge: NSObject

+ (NSDictionary *)computeSessionStatistics:(NSArray *)inputDataSNR
                                 threshold:(float)threshold;

@end

@interface MBTMelomindAnalysis: NSObject

+ (void) resetSession;

+ (float) sessionMeanAlphaPower;
+ (float) sessionMeanRelativeAlphaPower;
+ (float) sessionConfidence;

+ (NSArray*) sessionAlphaPowers;
+ (NSArray*) sessionRelativeAlphaPowers;
+ (NSArray*) sessionQualities;

@end

#endif /* MBTSignalProcessingBridge_h */
