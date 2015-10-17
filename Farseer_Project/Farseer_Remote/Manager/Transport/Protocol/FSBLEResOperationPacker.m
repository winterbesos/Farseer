//
//  FSBLEResOperationPacker.m
//  SLFarseer
//
//  Created by Salo on 15/10/15.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "FSBLEResOperationPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSPackageIn.h"
#import "FSCentralClient.h"

@implementation FSBLEResOperationPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    [client recvOperationInfo:[packageIn readData]];
}

@end
