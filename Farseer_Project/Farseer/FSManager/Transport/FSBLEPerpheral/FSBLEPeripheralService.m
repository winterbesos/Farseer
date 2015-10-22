//
//  BTCentrelService.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSBLEPeripheralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#import <FarseerBase_iOS/FSBLELog.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#import <FarseerBase_OSX/FSBLELog.h>
#endif
#import "FSBLEPeripheralPackerFactory.h"
#import "FSPeripheralClient.h"
#import "FSBLEUtilities.h"
#import "FSLogManager.h"
#import "FSPackageCoder.h"
#import <objc/runtime.h>

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

#pragma mark - BLE Control

- (void)setupService {
    // main log service
    
    // device info characteristic
    CBUUID *peripheralInfoCharacteristicUUID = [CBUUID UUIDWithString:kPeripheralInfoCharacteristicUUIDString];
    CBMutableCharacteristic *peripheralInfoCharacteristic = [[CBMutableCharacteristic alloc] initWithType:peripheralInfoCharacteristicUUID properties:CBCharacteristicPropertyRead value:[FSBLEUtilities getPeripheralInfoData] permissions:CBAttributePermissionsReadable];
    _infoCharacteristic = peripheralInfoCharacteristic;
    
    // log transfer characteristic
    CBUUID *writeLogCharacteristicUUID = [CBUUID UUIDWithString:kWriteLogCharacteristicUUIDString];
    CBMutableCharacteristic *writeLogCharacteristic = [[CBMutableCharacteristic alloc] initWithType:writeLogCharacteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    _logCharacteristic = writeLogCharacteristic;
    
    // data transfer characteristic
    CBUUID *dataCharacteristicUUID = [CBUUID UUIDWithString:kWriteDataCharacteristicUUIDString];
    CBMutableCharacteristic *writeDataCharacteristic = [[CBMutableCharacteristic alloc] initWithType:dataCharacteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    _dataCharacteristic = writeDataCharacteristic;
    
    // CMD transfer characteristic
    CBCharacteristicProperties properties = CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify;
    CBUUID *cmdCharacteristicUUID = [CBUUID UUIDWithString:kWriteCMDCharacteristicUUIDString];
    CBMutableCharacteristic *cmdCharacteristic = [[CBMutableCharacteristic alloc] initWithType:cmdCharacteristicUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    _cmdCharacteristic = cmdCharacteristic;
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    CBMutableService *bService = [[CBMutableService alloc] initWithType:sUUID primary:true];
    [bService setCharacteristics:@[peripheralInfoCharacteristic, writeLogCharacteristic, writeDataCharacteristic, cmdCharacteristic]];
    [kBLEService->_manager addService:bService];
}

- (void)startAdvertising {
    [kBLEService->_manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SLFarseer",
                                              CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kServiceUUIDString]]}];
}

- (void)stopAdvertising {
    [_manager stopAdvertising];
}

#pragma mark - Public Method

+ (void)updateCharacteristic:(CBMutableCharacteristic *)characteristic withData:(NSData *)data cmd:(CMD)cmd {
    dispatch_async(kBLEService->_bleQueue, ^{
        [kBLEService->_packageCoder pushDataToSendQueue:data characteristic:characteristic cmd:cmd];
    });
}

#pragma mark - Private Method

- (void)runSendLoop {
    [_packageCoder getPackageToSendWithBlock:^(NSData *data, CBMutableCharacteristic *characteristic) {
//        NSLog(@"P SEND: %@", data);
        [_manager updateValue:data forCharacteristic:characteristic onSubscribedCentrals:@[_central]];
    }];
}

#pragma mark - Package Coder Delegate

- (void)didPushPackageToEmptyPackageLoopPackageCoder:(FSPackageCoder *)packageCoder {
    [self runSendLoop];
}

#pragma mark - CBPeripheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
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
        [self startAdvertising];
    } else {
        installCallback(_infoCharacteristic, _logCharacteristic, _dataCharacteristic, _cmdCharacteristic, error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    _central = central;
    [self stopAdvertising];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    _central = nil;
    [_packageCoder clearCache];
    [self startAdvertising];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//    NSLog(@"%s: %@", __FUNCTION__, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    
    for (CBATTRequest *request in requests) {
        if (request.value) {
//            NSLog(@"P RECV: %@", request.value);
            [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
            
            struct PKG_HEADER header;
            struct PROTOCOL_HEADER protocolHeader;
            [request.value getBytes:&header length:sizeof(struct PKG_HEADER)];
            [request.value getBytes:&protocolHeader range:NSMakeRange(sizeof(struct PKG_HEADER), sizeof(struct PROTOCOL_HEADER))];

            NSData *recvData = [request.value subdataWithRange:NSMakeRange(sizeof(struct PKG_HEADER) + sizeof(struct PROTOCOL_HEADER), request.value.length - sizeof(struct PKG_HEADER) - sizeof(struct PROTOCOL_HEADER))];
            
            // distribute cmd
            switch (protocolHeader.cmd) {
                case CMDAck:
                    [_packageCoder removeSendedPackage];
                    [self runSendLoop];
                    break;
                case CMDCancel:
                    [_packageCoder clearCache];
                    [self runSendLoop];
                    break;
                default: {
                    FSPackageIn *packageIn = [FSPackageIn decode:recvData];
                    [[FSBLEPeripheralPackerFactory getObjectWithCMD:protocolHeader.cmd request:request] unpack:packageIn client:_client];
                }
                    break;
            }
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

@end
