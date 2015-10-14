//
//  FSBLEResSyncDataPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEResSyncDataPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSPackageIn.h"
#import "FSCentralClient.h"

@implementation FSBLEResSyncDataPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
//    UInt32 logNum = [packageIn readUInt32];
//    NSDate *logDate = [packageIn readDate];
//    Byte logLevel = [packageIn readByte];
//    NSString *content = [packageIn readString];
//    [client recvSyncLogWithLogNumber:logNum logDate:logDate logLevel:logLevel content:content peripheral:peripheral];
    // TODO: 重构
}

@end
