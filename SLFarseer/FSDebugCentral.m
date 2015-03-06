//
//  FSDebugCentral.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSDebugCentral.h"

#import "FSBLEPerpheralService.h"
#import "FSLogManager.h"
#import "FSLog.h"

static FSDebugCentral *instance = nil;

@implementation FSDebugCentral {
    void(^openBLEDebugCallback)(NSError *error);
}

+ (void)setup {
    if (!instance) {
        instance = [[FSDebugCentral alloc] init];
    }
}

+ (FSDebugCentral *)getInstance {
    [self setup];
    return instance;
}

#pragma mark - BLE Debug

+ (void)openBLEDebug:(void(^)(NSError *error))callback {
    NSParameterAssert(callback != nil);
#if TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR
    callback([NSError errorWithDomain:@"You can't open BLE Debug on iPhone Simulator" code:999 userInfo:nil]);
#else
    instance->openBLEDebugCallback = callback;
    [FSBLEPerpheralService install:^(NSError *error) {
        if (error) {
            callback(error);
        } else {
            BOOL installed = [FSLogManager installLogFile];
            callback(installed ? nil : [NSError errorWithDomain:@"FSLogManager has installed" code:999 userInfo:nil]);
        }
    }];
#endif
}

+ (void)closeBLEDebug {
    [FSLogManager uninstallLogFile];
    [FSBLEPerpheralService uninstall];
}

@end
