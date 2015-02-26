//
//  FSPerpheralClient.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPerpheralClient.h"
#import "FSBLEPerpheralService.h"

@implementation FSPerpheralClient

- (void)recvSyncLogWithLogNumber:(UInt32)logNum {
    [FSBLEPerpheralService updateLogCharacteristicWithLogNum:logNum];
}

@end
