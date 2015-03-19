//
//  FSBLEPeripheralPackerProtocol.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"

@class CBPeripheral;

@protocol FSPackerDelegate <NSObject>

@optional
- (void)unpack:(FSPackageIn *)packageIn client:(id)client;
- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral;

@end

@protocol FSBLEResDelegate <NSObject>

- (void)recvSyncLogWithLogNumber:(UInt32)logNum;

@end

@protocol FSBLEReqDelegate <NSObject>

@end