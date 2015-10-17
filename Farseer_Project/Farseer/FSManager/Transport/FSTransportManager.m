//
//  FSTransportManager.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSTransportManager.h"
#import "FSPeripheralClient.h"
#import "FSBLEPeripheralService.h"
#import "FSLogManager.h"
#import "FSDebugCentral.h"

@implementation FSTransportManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripheralClient = [[FSPeripheralClient alloc] init];
    }
    return self;
}

- (void)openBLEDebug:(void(^)(NSError *error))callback {
    NSParameterAssert(callback != nil);
#if TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR
    callback([NSError errorWithDomain:@"You can't open BLE Debug on iPhone Simulator" code:999 userInfo:nil]);
#else
    [FSBLEPeripheralService installWithClient:self.peripheralClient callback:^(CBMutableCharacteristic *peripheralInfoCharacteristic, CBMutableCharacteristic *logCharacteristic, CBMutableCharacteristic *dataCharacteristic, CBMutableCharacteristic *cmdCharacteristic, NSError *error) {
        
        if (error) {
            callback(error);
        } else {
            [self.peripheralClient setPeripheralInfoCharacteristic:peripheralInfoCharacteristic logCharacteristic:logCharacteristic dataCharacteristic:dataCharacteristic cmdCharacteristic:cmdCharacteristic];
            BOOL installed = [[FSDebugCentral getInstance].logManager installLogFile];
            callback(installed ? nil : [NSError errorWithDomain:@"FSLogManager has installed" code:999 userInfo:nil]);
        }
    }];
#endif
}

- (void)closeBLEDebug {
    [[FSDebugCentral getInstance].logManager uninstallLogFile];
    [FSBLEPeripheralService uninstall];
}

@end
