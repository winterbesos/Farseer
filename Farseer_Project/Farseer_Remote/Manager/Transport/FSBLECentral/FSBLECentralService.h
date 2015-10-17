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
@protocol FSCentralClientDelegate;

@interface FSBLECentralService : NSObject

+ (void)installWithDelegate:(id<FSCentralClientDelegate>)delegate stateChangedCallback:(void(^)(CBCentralManagerState state))callback;
+ (void)uninstall;
+ (void)scanDidDisconvered:(void(^)(CBPeripheral *peripheral, NSNumber *RSSI))callback;
+ (void)stopScan;
+ (void)setConnectPeripheralCallback:(void(^)(CBPeripheral *peripheral))callback;
+ (void)connectToPeripheral:(CBPeripheral *)peripheral;
+ (void)disconnectPeripheral:(CBPeripheral *)peripheral;

+ (void)writeToLogCharacteristicWithValue:(NSData *)value;

@end
