//
//  FSBLEResSyncDataPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEResSyncDataPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSCentralClient.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif

@implementation FSBLEResSyncDataPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    [client recvSandBoxFile:[packageIn readData]];
}

@end
