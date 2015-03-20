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
#import <objc/runtime.h>

#define MAX_PACKAGE_SIZE 100
static char cacheAssociatedHandle;

static FSBLEPeripheralService *kBLEService = nil;

@interface FSBLEPeripheralService () <CBPeripheralManagerDelegate>

@end

@implementation FSBLEPeripheralService {
    CBPeripheralManager         *_manager;
    CBCentral                   *_central;
    
    CBMutableCharacteristic     *_infoCharacteristic;
    CBMutableCharacteristic     *_logCharacteristic;
    CBMutableCharacteristic     *_dataCharacteristic;
    CBMutableCharacteristic     *_cmdCharacteristic;
    
    __weak id                          _client;
    
    void(^installCallback)(CBMutableCharacteristic *peripheralInfoCharacteristic,
                           CBMutableCharacteristic *logCharacteristic,
                           CBMutableCharacteristic *dataCharacteristic,
                           CBMutableCharacteristic *cmdCharacteristic,
                           NSError *error);
}

+ (void)installWithClient:(id)client callback:(void(^)(CBMutableCharacteristic *peripheralInfoCharacteristic,
                                                       CBMutableCharacteristic *logCharacteristic,
                                                       CBMutableCharacteristic *dataCharacteristic,
                                                       CBMutableCharacteristic *cmdCharacteristic,
                                                       NSError *error))callback {
    if (!kBLEService) {
        kBLEService = [[FSBLEPeripheralService alloc] init];
        kBLEService->_manager = [[CBPeripheralManager alloc] initWithDelegate:kBLEService queue:nil];
        kBLEService->_client = client;
        kBLEService->installCallback = callback;
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
    [bService setCharacteristics:@[peripheralInfoCharacteristic, writeLogCharacteristic, writeDataCharacteristic]];
    [kBLEService->_manager addService:bService];
}

#pragma mark - Public Method

+ (void)updateCharacteristic:(CBMutableCharacteristic *)characteristic withData:(NSData *)data {
    [kBLEService->_manager updateValue:data forCharacteristic:characteristic onSubscribedCentrals:@[kBLEService->_central]];
}

#pragma mark - Private Method

- (NSArray *)dividePackage:(NSData *)data {
    NSMutableArray *packages = [NSMutableArray array];
    NSMutableData *originData = [data mutableCopy];
    
    NSUInteger loc = 0;
    while (loc < originData.length) {
        NSUInteger pkgSize = 0;
        if (originData.length > MAX_PACKAGE_SIZE) {
            pkgSize = MAX_PACKAGE_SIZE;
        } else {
            pkgSize = originData.length;
        }
        NSData *package = [originData subdataWithRange:NSMakeRange(loc, pkgSize)];
        loc += pkgSize;
        
        [packages addObject:package];
    }
    return packages;
}

- (BOOL)writeData:(NSData *)data toCharacteristic:(CBMutableCharacteristic *)characteristic {
    NSMutableArray *cachePackages = objc_getAssociatedObject(characteristic, &cacheAssociatedHandle);
    if (cachePackages) {
        cachePackages = [NSMutableArray array];
        objc_setAssociatedObject(characteristic, &cacheAssociatedHandle, cachePackages, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (cachePackages.count > 0) {
        return NO;
    }
    [cachePackages addObjectsFromArray:[self dividePackage:data]];
    [kBLEService->_manager updateValue:cachePackages.firstObject forCharacteristic:_dataCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
    
    return YES;
}

- (void)recvACK:(NSData *)ack {
    // TODO: 通过ACK获取相应的特征，然后写入新数据
    CBMutableCharacteristic *characteristic = nil;
    NSMutableArray *cachePackages = objc_getAssociatedObject(characteristic, &cacheAssociatedHandle);
    
    // TODO: varify packge sequence -> true remove false return
    [cachePackages removeObject:0];
    
    [kBLEService->_manager updateValue:cachePackages.firstObject forCharacteristic:_dataCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
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
            [[FSBLEPeripheralPackerFactory getObjectWithCMD:cmd request:request] unpack:packageIn client:_client];
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

@end
