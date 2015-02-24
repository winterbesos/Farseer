//
//  FSBLESyncLogPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/24/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLESyncLogPacker.h"
#import "FSPackerProtocol.h"
#import "FSPackageIn.h"
#import "FSCentralClient.h"

@implementation FSBLESyncLogPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client {
    
    Byte logNum = [packageIn readByte];
    NSDate *logDate = [packageIn readDate];
    Byte logLevel = [packageIn readByte];
    NSString *content = [packageIn readString];
    
    [client recvSyncLogWithLogNumber:logNum logDate:logDate logLevel:logLevel content:content];
}

@end
