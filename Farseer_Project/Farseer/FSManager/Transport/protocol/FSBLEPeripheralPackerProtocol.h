//
//  FSBLEPeripheralPackerProtocol.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif

@class CBPeripheral;

@protocol FSPackerDelegate <NSObject>

@optional
- (void)unpack:(FSPackageIn *)packageIn client:(id)client;
- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral;

@end

@protocol FSBLEResDelegate <NSObject>

- (void)recvSyncLogWithLogNumber:(UInt32)logNum;
- (void)recvGetSendBoxInfoWithPath:(NSString *)path;
- (void)recvGetFileWithPath:(NSString *)path;

@end
