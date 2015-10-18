//
//  FSDebugCentral_Remote.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSDebugCentral_Remote.h"
#import "FSCentralLogManager.h"

@implementation FSDebugCentral_Remote

+ (FSDebugCentral_Remote *)getInstance {
    static FSDebugCentral_Remote *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FSDebugCentral_Remote alloc] init];
        instance->_logManager = [[FSCentralLogManager alloc] init];
        instance->_centralClient = [[FSCentralClient alloc] init];
    });
    return instance;
}

@end
