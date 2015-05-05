//
//  FSBLEReqMakeCrashPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/5/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEReqMakeCrashPacker.h"
#import "FSPackageIn.h"
#import "FSBLEPeripheralPackerProtocol.h"

@implementation FSBLEReqMakeCrashPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id<FSBLEResDelegate>)client {
    exit(0);
}

@end
