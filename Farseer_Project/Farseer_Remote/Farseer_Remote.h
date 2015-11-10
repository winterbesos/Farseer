//
//  Farseer_Remote.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSCentralClientDelegate.h"

void requestLog();
void saveLog();
void makeCrash();
void getSandBoxInfo(NSString *path);
void getSandBoxFile(NSString *path);

#pragma mark - BLE Operation

void setupBLEClient(id<FSCentralClientDelegate> delegate, void(^statusChangedCallback)(CBCentralManagerState state));void disconnectPeripheral(CBPeripheral *peripheral);
void setupBLEClient(id<FSCentralClientDelegate> delegate, void(^statusChangedCallback)(CBCentralManagerState state));
void scanPeripheral(void(^callback)(CBPeripheral *peripheral, NSNumber *RSSI));
void stopScan();
void connectToPeripheral(CBPeripheral *peripheral, void(^callback)(CBPeripheral *peripheral));
void disconnectPeripheral(CBPeripheral *peripheral);
void disconnectAllPeripheral();