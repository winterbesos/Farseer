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

static FSBLEPerpheralService *kBLEService = nil;

@interface FSBLEPerpheralService () <CBPeripheralManagerDelegate>

@end

@implementation FSBLEPerpheralService {
    CBPeripheralManager         *_manager;
    FSPerpheralClient           *_client;
    CBCentral                   *_central;
    CBMutableCharacteristic     *_logCharacteristic;
    
    NSMutableDictionary         *_logDictionary;
    UInt32                      _waitingLogNumber;
}

+ (void)install {
    if (!kBLEService) {
        kBLEService = [[FSBLEPerpheralService alloc] init];
        kBLEService->_manager = [[CBPeripheralManager alloc] initWithDelegate:kBLEService queue:nil];
        kBLEService->_logDictionary = [NSMutableDictionary dictionary];
        kBLEService->_client = [[FSPerpheralClient alloc] init];
        kBLEService->_waitingLogNumber = -1;
    }
}

+ (void)uninstall {
    kBLEService = nil;
}

#pragma mark - Business Logic

- (void)recvSyncLogWithLogNumber:(UInt32)logNum {
    FSBLELog *log = _logDictionary[@(logNum)];
    if (log == nil) {
        _waitingLogNumber = logNum;
    }
    NSData *logData = [FSBLEUtilities getLogDataWithNumber:log.log_number date:log.log_date level:log.log_level content:log.log_content];
    [kBLEService->_manager updateValue:logData forCharacteristic:kBLEService->_logCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
}

+ (void)inputLogToCacheWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content {
    FSBLELog *log = [FSBLELog logWithNumber:number date:date level:level content:content];
    [kBLEService->_logDictionary setObject:log forKey:@(number)];
    
    [self updateLogCharacteristicWithLogNum:kBLEService->_waitingLogNumber];
}

+ (void)updateLogCharacteristicWithLogNum:(UInt32)logNum {
    if (kBLEService->_central) {
        FSBLELog *log = kBLEService->_logDictionary[@(logNum)];
        
        if (logNum == -1) {
            return;
        } else {
            kBLEService->_waitingLogNumber = -1;
        }
        
        if (!log) {
            kBLEService->_waitingLogNumber = logNum;
            return;
        } else {
            NSData *logData = [FSBLEUtilities getLogDataWithNumber:log.log_number date:log.log_date level:log.log_level content:log.log_content];
            [kBLEService->_manager updateValue:logData forCharacteristic:kBLEService->_logCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
        }
    }
}

- (void)statusMechine {
    
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
    NSLog(@"%s: %ld", __FUNCTION__, (long)peripheral.state);

    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self setupService];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    NSLog(@"%s: %@", __FUNCTION__, dict);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"%s: %@", __FUNCTION__, error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s: %@ %@", __FUNCTION__, service, error);
    
    if (!error) {
        [kBLEService->_manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SLFarseer",
                                    CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kServiceUUIDString]]}];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
    
    _central = central;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"%s: %@", __FUNCTION__, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"%s: %@", __FUNCTION__, requests);
    
    for (CBATTRequest *request in requests) {
        if (request.value) {
            Byte cmd;
            [request.value getBytes:&cmd length:sizeof(cmd)];
            
            FSPackageIn *packageIn = [FSPackageIn decode:request.value];
            [[FSPackerFactory getObjectWithCMD:cmd] unpack:packageIn client:_client];
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"%s", __FUNCTION__);
}

@end
