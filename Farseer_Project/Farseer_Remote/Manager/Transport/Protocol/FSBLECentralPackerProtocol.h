//
//  FSBLECentralPackerProtocol.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSPackageIn.h"
#import "FSDefine.h"

@class CBPeripheral;

@protocol FSPackerDelegate <NSObject>

@optional
- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral;

@end

@protocol FSBLEReqDelegate <NSObject>

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName peripheral:(CBPeripheral *)peripheral;
- (void)recvSyncLogWithLogNumber:(UInt32)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content fileName:(NSString *)fileName functionName:(NSString *)functionName line:(UInt32)line peripheral:(CBPeripheral *)peripheral;
- (void)recvSendBoxInfo:(NSDictionary *)sendBoxInfo;
- (void)recvSandBoxFile:(NSData *)sandBoxData;

@end