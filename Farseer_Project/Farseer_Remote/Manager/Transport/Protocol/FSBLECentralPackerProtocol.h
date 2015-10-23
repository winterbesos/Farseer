//
//  FSBLECentralPackerProtocol.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSDefine.h>
#import <FarseerBase_iOS/FSPackageIn.h>
#import <FarseerBase_iOS/FSBLELogProtocol.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSDefine.h>
#import <FarseerBase_OSX/FSPackageIn.h>
#import <FarseerBase_OSX/FSBLELogProtocol.h>
#endif

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