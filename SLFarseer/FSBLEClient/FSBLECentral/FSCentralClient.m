//
//  FSCentralClient.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSCentralClient.h"

@implementation FSCentralClient

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName {
    NSLog(@"%s: %d %@ %@ %@ %@", __FUNCTION__, osType, osVersion, deviceType, deviceName, bundleName);
}

- (void)recvSyncLogWithLogNumber:(Byte)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content {
    NSLog(@"%d %@ %d %@", logNumber, logDate, logLevel, content);
}

@end
