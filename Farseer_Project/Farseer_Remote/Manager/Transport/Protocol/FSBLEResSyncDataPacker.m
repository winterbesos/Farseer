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
#import "FSPackageIn.h"

@implementation FSBLEResSyncDataPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    [client recvSandBoxFile:[packageIn readFullData]];
}

@end
