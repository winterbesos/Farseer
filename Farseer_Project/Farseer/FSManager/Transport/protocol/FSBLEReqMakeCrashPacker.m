//
//  FSBLEReqMakeCrashPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/5/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEReqMakeCrashPacker.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif
#import "FSBLEPeripheralPackerProtocol.h"

@implementation FSBLEReqMakeCrashPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id<FSBLEResDelegate>)client {
    exit(0);
}

@end
