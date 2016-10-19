//
//  FSCentralClient.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSDefine.h"
#import "FSCentralClientDelegate.h"

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
