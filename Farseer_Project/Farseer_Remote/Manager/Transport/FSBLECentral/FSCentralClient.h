//
//  FSCentralClient.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSDefine.h>
#import <Farseer_Remote_iOS/FSCentralClientDelegate.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSDefine.h>
#import <Farseer_Remote_Mac/FSCentralClientDelegate.h>
#endif

@class FSBLECentralService;
@class CBPeripheral;
@class FSBLELog;

@interface FSCentralClient : NSObject

@property (nonatomic, readonly)FSBLECentralService *service;

- (void)setupWithDelegate:(id<FSCentralClientDelegate>)delegate statusChangedCallback:(void(^)(CBCentralManagerState state))callback;
- (void)requestLog;
- (void)getSandBoxInfoWithPath:(NSString *)path;
- (void)getSandBoxFileWithPath:(NSString *)path;
- (void)makePeripheralCrash;

@end
