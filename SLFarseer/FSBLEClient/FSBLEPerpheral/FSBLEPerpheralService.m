//
//  BTCentrelService.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSBLEPerpheralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSPackageIn.h"
#import "FSPackerFactory.h"
#import "FSPerpheralClient.h"
#import "FSBLEUtilities.h"
#import "FSBLELog.h"
#import "FSLogManager.h"

static FSBLEPerpheralService *kBLEService = nil;

@interface FSBLEPerpheralService () <CBPeripheralManagerDelegate>

@end

@implementation FSBLEPerpheralService {
    CBPeripheralManager         *_manager;
    CBCentral                   *_central;
    CBMutableCharacteristic     *_logCharacteristic;
    
    UInt32                      _waitingLogNumber;
    
    void(^installCallback)(NSError *error);
}

+ (void)install:(void(^)(NSError *error))callback {
    if (!kBLEService) {
        kBLEService = [[FSBLEPerpheralService alloc] init];
        kBLEService->_manager = [[CBPeripheralManager alloc] initWithDelegate:kBLEService queue:nil];
        kBLEService->_waitingLogNumber = -1;
        
        kBLEService->installCallback = callback;
    }
}

+ (void)uninstall {
    kBLEService->installCallback = nil;
    kBLEService = nil;
}

#pragma mark - Business Logic

- (void)recvSyncLogWithLogNumber:(UInt32)logNum {
    [self updateLogCharacteristicWithLogNum:logNum];
}

+ (void)inputLogToCacheWithLog:(FSBLELog *)log {
    if (kBLEService) {
        if (kBLEService->_waitingLogNumber == log.log_number) {
            [kBLEService updateLogCharacteristicWithLogNum:kBLEService->_waitingLogNumber];
        }
    }
}

- (void)updateLogCharacteristicWithLogNum:(UInt32)logNum {
    NSArray *logList = [FSLogManager logList];
    if (logList.count > logNum) {
        FSBLELog *log = logList[logNum];
        NSData *logData = [FSBLEUtilities getLogDataWithNumber:log.log_number date:log.log_date level:log.log_level content:log.log_content];
        [kBLEService->_manager updateValue:logData forCharacteristic:kBLEService->_logCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
        
        if (_waitingLogNumber != -1) {
            _waitingLogNumber = -1;
        }
    } else {
        _waitingLogNumber = logNum;
    }
}

- (void)setupService {
    // 主Log通信服务
    CBUUID *cUUID = [CBUUID UUIDWithString:kWriteLogCharacteristicUUIDString];
    CBCharacteristicProperties properties = CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyNotify; // CBCharacteristicPropertyBroadcast |
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:cUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *piCharacteristic = [CBUUID UUIDWithString:kPeripheralInfoCharacteristicUUIDString];
    
    CBMutableCharacteristic *peripheralInfoCharacteristic = [[CBMutableCharacteristic alloc] initWithType:piCharacteristic properties:CBCharacteristicPropertyRead value:[FSBLEUtilities getPeripheralInfoData] permissions:CBAttributePermissionsReadable];
    
    _logCharacteristic = characteristic;
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    CBMutableService *bService = [[CBMutableService alloc] initWithType:sUUID primary:true];
    [bService setCharacteristics:@[characteristic, peripheralInfoCharacteristic]];
    [kBLEService->_manager addService:bService];
    
}

#pragma mark - CBPerpheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s: %ld", __FUNCTION__, (long)peripheral.state);

    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self setupService];
    } else {
        installCallback([NSError errorWithDomain:@"Peripheral Status Error" code:999 userInfo:nil]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
//    NSLog(@"%s: %@", __FUNCTION__, dict);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
//    NSLog(@"%s: %@", __FUNCTION__, error);
    installCallback(error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
//    NSLog(@"%s: %@ %@", __FUNCTION__, service, error);
    
    if (!error) {
        [kBLEService->_manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SLFarseer",
                                    CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kServiceUUIDString]]}];
    } else {
        installCallback(error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
    
    _central = central;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//    NSLog(@"%s: %@", __FUNCTION__, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
//    NSLog(@"%s: %@", __FUNCTION__, requests);
    
    for (CBATTRequest *request in requests) {
        if (request.value) {
            Byte cmd;
            [request.value getBytes:&cmd length:sizeof(cmd)];
            FSPackageIn *packageIn = [FSPackageIn decode:request.value];
            [[FSPackerFactory getObjectWithCMD:cmd] unpack:packageIn client:self];
            
//            NSLog(@"%@", request.value);
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

@end
