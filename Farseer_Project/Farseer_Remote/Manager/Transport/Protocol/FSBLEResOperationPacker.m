//
//  FSBLEResOperationPacker.m
//  SLFarseer
//
//  Created by Salo on 15/10/15.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "FSBLEResOperationPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSCentralClient.h"
#import "FSPackageIn.h"

@implementation FSBLEResOperationPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    [client recvOperationInfo:[packageIn readFullData]];
}

@end
