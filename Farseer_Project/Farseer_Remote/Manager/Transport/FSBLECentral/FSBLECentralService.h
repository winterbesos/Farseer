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
@class FSPackageEncoder;
@class FSPackageDecoder;

@interface FSBLECentralService : NSObject

- (instancetype)initWithEncoder:(FSPackageEncoder *)encoder decoder:(FSPackageDecoder *)decoder stateChangedCallback:(void(^)(CBCentralManagerState state))callback;
- (void)uninstall;
- (void)scanDidDisconvered:(void(^)(CBPeripheral *peripheral, NSNumber *RSSI))callback;
- (void)connectToPeripheral:(CBPeripheral *)peripheral callback:(void(^)(CBPeripheral *peripheral))callback;
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;
- (void)stopScan;

- (void)runSendLoop;

@end
