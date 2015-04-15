//
//  FSLogManager.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSLogManager.h"
#import "FSBLELog.h"
#import "FSPackageIn.h"
#import "FSBLEPeripheralService.h"
#import <CoreBluetooth/CBPeripheral.h>
#import "FSDebugCentral.h"
#import "FSPeripheralClient.h"
#import "FSUtilities.h"
#import "FSTransportManager.h"

@implementation FSLogManager 

- (instancetype)init
{
    self = [super init];
    if (self) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    return self;
}

@end
