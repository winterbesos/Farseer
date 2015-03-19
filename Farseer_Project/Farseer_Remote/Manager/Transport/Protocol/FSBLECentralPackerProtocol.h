//
//  FSBLECentralPackerProtocol.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSPackageIn.h"

@class CBPeripheral;

@protocol FSPackerDelegate <NSObject>

@optional
- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral;

@end

@protocol FSBLEResDelegate <NSObject>

- (void)recvSyncLogWithLogNumber:(UInt32)logNum;

@end

@protocol FSBLEReqDelegate <NSObject>

@end