//
//  FSBLESyncLogPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/24/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLEResSyncLogPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSCentralClient.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif

@implementation FSBLEResSyncLogPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    
    NSString *className = [packageIn readString];
    UInt32 logLength = [packageIn readUInt32];
    NSData *logData = [packageIn readDataWithLength:logLength];
    Class cls = NSClassFromString(className);
    if (cls) {
        id log = [[cls alloc] init];
        [log BLETransferDecodeWithData:logData];
        [client recvLog:log];
    }
}

@end
