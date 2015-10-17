//
//  FSDebugCentral.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSDebugCentral.h"

#import "FSLogManager.h"
#import "FSTransportManager.h"
#import "FSFileManager.h"
#import "FSOperationManager.h"

@implementation FSDebugCentral

+ (FSDebugCentral *)getInstance {
    static FSDebugCentral *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FSDebugCentral alloc] init];
        instance->_logManager = [[FSLogManager alloc] init];
        instance->_transportManager = [[FSTransportManager alloc] init];
        instance->_fileManager = [[FSFileManager alloc] init];
        instance->_operationManager = [[FSOperationManager alloc] init];
    });
    return instance;
}

#pragma mark - Public Method

+ (void)openBLEDebug:(void(^)(NSError *error))callback {
    [[FSDebugCentral getInstance].transportManager openBLEDebug:callback];
}

+ (void)closeBLEDebug {
    [[FSDebugCentral getInstance].transportManager closeBLEDebug];
}

@end
