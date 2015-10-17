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
    [client recvSandBoxFile:[packageIn readData]];
}

@end
