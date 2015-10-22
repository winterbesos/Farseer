//
//  FSBLEReqSyncLogPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLEReqSyncLogPacker.h"

#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif
#import "FSBLEPeripheralPackerProtocol.h"

@implementation FSBLEReqSyncLogPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client {
    
    UInt32 logNum = [packageIn readUInt32];
    
    [client recvSyncLogWithLogNumber:logNum];
}

@end
