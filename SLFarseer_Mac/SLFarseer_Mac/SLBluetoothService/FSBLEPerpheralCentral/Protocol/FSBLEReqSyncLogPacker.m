//
//  FSBLEReqSyncLogPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLEReqSyncLogPacker.h"
#import "FSPackageIn.h"
#import "FSPackerProtocol.h"

@implementation FSBLEReqSyncLogPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client {
    
    UInt32 logNum = [packageIn readUInt32];
    
    [client recvSyncLogWithLogNumber:logNum];
}

@end
