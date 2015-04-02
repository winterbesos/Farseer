//
//  FSBLECentralService.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/22/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBCentralManager.h>

@class CBPeripheral;

@interface FSBLECentralService : NSObject

+ (void)install;
+ (void)installWithClient:(id)client stateChangedCallback:(void(^)(CBCentralManagerState state))callback;
+ (void)uninstall;
+ (void)scanDidDisconvered:(void(^)(CBPeripheral *peripheral, NSNumber *RSSI))callback;
+ (void)stopScan;
+ (void)setConnectPeripheralCallback:(void(^)(CBPeripheral *peripheral))callback;
+ (void)connectToPeripheral:(CBPeripheral *)peripheral;
+ (void)getSandBoxInfoWithPath:(NSString *)path;
+ (void)getSandBoxFileWithPath:(NSString *)path;

+ (void)requLogWithLogNumber:(UInt32)logNum;

@end
