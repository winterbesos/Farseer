//
//  BTCentrelService.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSBLEPeripheralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSPackageIn.h"
#import "FSBLEPeripheralPackerFactory.h"
#import "FSPeripheralClient.h"
#import "FSBLEUtilities.h"
#import "FSBLELog.h"
#import "FSLogManager.h"
#import "FSPackageCoder.h"
#import <objc/runtime.h>

#define MAX_PACKAGE_SIZE 100

static FSBLEPeripheralService *kBLEService = nil;

@interface FSBLEPeripheralService () <CBPeripheralManagerDelegate, FSPackageCoderDelegate>

@end

@implementation FSBLEPeripheralService {
    CBPeripheralManager         *_manager;
    CBCentral                   *_central;
    
    CBMutableCharacteristic     *_infoCharacteristic;
    CBMutableCharacteristic     *_logCharacteristic;
    CBMutableCharacteristic     *_dataCharacteristic;
    CBMutableCharacteristic     *_cmdCharacteristic;
    
    __weak id                   _client;
    
    void(^installCallback)(CBMutableCharacteristic *peripheralInfoCharacteristic,
                           CBMutableCharacteristic *logCharacteristic,
                           CBMutableCharacteristic *dataCharacteristic,
                           CBMutableCharacteristic *cmdCharacteristic,
                           NSError *error);
    
    FSPackageCoder *    _packageCoder;
    dispatch_queue_t    _bleQueue;
}

+ (void)installWithClient:(id)client callback:(void(^)(CBMutableCharacteristic *peripheralInfoCharacteristic,
                                                       CBMutableCharacteristic *logCharacteristic,
                                                       CBMutableCharacteristic *dataCharacteristic,
                                                       CBMutableCharacteristic *cmdCharacteristic,
                                                       NSError *error))callback {
    if (!kBLEService) {
        kBLEService = [[FSBLEPeripheralService alloc] init];
        dispatch_queue_t bleQueue = dispatch_queue_create("FSBLEQueue", NULL);
        kBLEService->_bleQueue = bleQueue;
        kBLEService->_manager = [[CBPeripheralManager alloc] initWithDelegate:kBLEService queue:bleQueue];
        kBLEService->_client = client;
        kBLEService->installCallback = callback;
        kBLEService->_packageCoder = [[FSPackageCoder alloc] initWithDelegate:kBLEService];
    }
}

+ (void)uninstall {
    if (kBLEService) {
        kBLEService->installCallback = nil;
        kBLEService->_client = nil;
        kBLEService = nil;        
    }
}

- (void)setupService {
    // main log service
    
    // device info characteristic
    CBUUID *peripheralInfoCharacteristicUUID = [CBUUID UUIDWithString:kPeripheralInfoCharacteristicUUIDString];
    CBMutableCharacteristic *peripheralInfoCharacteristic = [[CBMutableCharacteristic alloc] initWithType:peripheralInfoCharacteristicUUID properties:CBCharacteristicPropertyRead value:[FSBLEUtilities getPeripheralInfoData] permissions:CBAttributePermissionsReadable];
    _infoCharacteristic = peripheralInfoCharacteristic;
    
    // log transfer characteristic
    CBUUID *writeLogCharacteristicUUID = [CBUUID UUIDWithString:kWriteLogCharacteristicUUIDString];
    CBCharacteristicProperties properties = CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyNotify;
    CBMutableCharacteristic *writeLogCharacteristic = [[CBMutableCharacteristic alloc] initWithType:writeLogCharacteristicUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    _logCharacteristic = writeLogCharacteristic;
    
    // data transfer characteristic
    CBUUID *dataCharacteristicUUID = [CBUUID UUIDWithString:kWriteDataCharacteristicUUIDString];
    CBMutableCharacteristic *writeDataCharacteristic = [[CBMutableCharacteristic alloc] initWithType:dataCharacteristicUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    _dataCharacteristic = writeDataCharacteristic;
    
    // CMD transfer characteristic
    CBUUID *cmdCharacteristicUUID = [CBUUID UUIDWithString:kWriteCMDCharacteristicUUIDString];
    CBMutableCharacteristic *cmdCharacteristic = [[CBMutableCharacteristic alloc] initWithType:cmdCharacteristicUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    _cmdCharacteristic = cmdCharacteristic;
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    CBMutableService *bService = [[CBMutableService alloc] initWithType:sUUID primary:true];
    [bService setCharacteristics:@[peripheralInfoCharacteristic, writeLogCharacteristic, writeDataCharacteristic, cmdCharacteristic]];
    [kBLEService->_manager addService:bService];
}

#pragma mark - Public Method

+ (void)updateCharacteristic:(CBMutableCharacteristic *)characteristic withData:(NSData *)data {
    dispatch_async(kBLEService->_bleQueue, ^{
        [kBLEService->_packageCoder pushDataToSendQueue:data characteristic:characteristic];        
    });
}

#pragma mark - Private Method

- (void)runSendLoop {
    [_packageCoder getPackageToSendWithBlock:^(NSData *data, CBMutableCharacteristic *characteristic) {
        NSLog(@"P SEND: %@", data);
        [_manager updateValue:data forCharacteristic:characteristic onSubscribedCentrals:@[_central]];
    }];
}

#pragma mark - Package Coder Delegate

- (void)didPushPackageToEmptyPackageLoopPackageCoder:(FSPackageCoder *)packageCoder {
    [self runSendLoop];
}

#pragma mark - CBPeripheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s: %ld", __FUNCTION__, (long)peripheral.state);

    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self setupService];
    } else {
        installCallback(nil, nil, nil, nil, [NSError errorWithDomain:@"Peripheral Status Error" code:999 userInfo:nil]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
//    NSLog(@"%s: %@", __FUNCTION__, dict);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
//    NSLog(@"%s: %@", __FUNCTION__, error);
    installCallback(_infoCharacteristic, _logCharacteristic, _dataCharacteristic, _cmdCharacteristic, error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
//    NSLog(@"%s: %@ %@", __FUNCTION__, service, error);
    
    if (!error) {
        [kBLEService->_manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SLFarseer",
                                    CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kServiceUUIDString]]}];
    } else {
        installCallback(_infoCharacteristic, _logCharacteristic, _dataCharacteristic, _cmdCharacteristic, error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
    
    _central = central;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
    
    _central = nil;
    [_packageCoder clearCache];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//    NSLog(@"%s: %@", __FUNCTION__, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
//    NSLog(@"%s: %@", __FUNCTION__, requests);
    
    for (CBATTRequest *request in requests) {
        if (request.value) {
            
            NSLog(@"P RECV: %@", request.value);
            Byte cmd;
            [request.value getBytes:&cmd length:1];
            
            // REFECTOR:
            if (cmd == CMDAck) {
                [_packageCoder removeSendedPackage];
                [self runSendLoop];
            } else {
                [request.value getBytes:&cmd length:sizeof(cmd)];
                
                NSData *recvData = [request.value subdataWithRange:NSMakeRange(sizeof(struct PKG_HEADER), request.value.length - sizeof(struct PKG_HEADER))];
                
                FSPackageIn *packageIn = [FSPackageIn decode:recvData];
                [[FSBLEPeripheralPackerFactory getObjectWithCMD:cmd request:request] unpack:packageIn client:_client];
            }
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

@end
