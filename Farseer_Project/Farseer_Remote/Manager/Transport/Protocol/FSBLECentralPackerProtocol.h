//
//  FSBLECentralPackerProtocol.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSDefine.h"
#import "FSPackageIn.h"
#import "FSBLELogProtocol.h"

@class CBPeripheral;

@protocol FSPackerDelegate <NSObject>

@optional
- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral;

@end

@protocol FSBLEReqDelegate <NSObject>

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName peripheral:(CBPeripheral *)peripheral deviceUUID:(NSString *)deviceUUID;
- (void)recvLog:(id<FSBLELogProtocol>)log;
- (void)recvSendBoxInfo:(NSDictionary *)sendBoxInfo;
- (void)recvSandBoxFile:(NSData *)sandBoxData;
- (void)recvOperationInfo:(NSData *)operationInfo;

@end
