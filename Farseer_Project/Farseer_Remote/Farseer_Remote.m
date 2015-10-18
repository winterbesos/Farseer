//
//  Farseer_Remote.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "Farseer_Remote.h"
#import "FSCentralLogManager.h"
#import "FSDebugCentral_Remote.h"
#import "FSBLECentralService.h"

void requestLog() {
    [[FSDebugCentral_Remote getInstance].logManager requestLog];
}

void saveLog(void(^callback)(float percentage)) {
    [[FSDebugCentral_Remote getInstance].logManager saveLogCallback:callback];
}

void makeCrash() {
    [[FSDebugCentral_Remote getInstance].centralClient makePeripheralCrash];
}

void getSandBoxInfo(NSString *path) {
    [[FSDebugCentral_Remote getInstance].centralClient getSandBoxInfoWithPath:path];
}

void getSandBoxFile(NSString *path) {
    [[FSDebugCentral_Remote getInstance].centralClient getSandBoxFileWithPath:path];
}

#pragma mark - BLE Operation

void setupBLEClient(id<FSCentralClientDelegate> delegate, void(^statusChangedCallback)(CBCentralManagerState state)) {
    [[FSDebugCentral_Remote getInstance].centralClient setupWithDelegate:delegate statusChangedCallback:statusChangedCallback];
}

void scanPeripheral(void(^callback)(CBPeripheral *peripheral, NSNumber *RSSI)) {
    [[FSDebugCentral_Remote getInstance].centralClient.service scanDidDisconvered:callback];
}

void stopScan() {
    [[FSDebugCentral_Remote getInstance].centralClient.service stopScan];
}

void connectToPeripheral(CBPeripheral *peripheral, void(^callback)(CBPeripheral *peripheral)) {
    [[FSDebugCentral_Remote getInstance].centralClient.service connectToPeripheral:peripheral callback:callback];
}

void disconnectPeripheral(CBPeripheral *peripheral) {
    [[FSDebugCentral_Remote getInstance].centralClient.service disconnectPeripheral:peripheral];
}

