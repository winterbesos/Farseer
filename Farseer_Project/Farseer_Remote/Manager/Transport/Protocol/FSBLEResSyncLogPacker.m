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
    
    UInt32 logNum = [packageIn readUInt32];
    NSDate *logDate = [packageIn readDate];
    Byte logLevel = [packageIn readByte];
    NSString *content = [packageIn readString];
    NSString *fileName = [packageIn readString];
    NSString *functionName = [packageIn readString];
    UInt32 line = [packageIn readUInt32];
    
    [client recvSyncLogWithLogNumber:logNum logDate:logDate logLevel:logLevel content:content fileName:fileName functionName:functionName line:line peripheral:peripheral];
}

@end
