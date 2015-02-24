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

static NSString *kPeripheralInfoCharacteristicUUIDString = @"838D0104-C9B7-4B34-97B9-8213E24D5493";
static NSString *kWriteLogCharacteristicUUIDString = @"622C6B76-5A52-48F7-8595-468F7B8DD11D";
static NSString *kServiceUUIDString = @"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316";
static FSBLEPerpheralService *kBLEService = nil;

@interface FSBLEPerpheralService () <CBPeripheralManagerDelegate>

@end

@implementation FSBLEPerpheralService {
    CBPeripheralManager *_manager;
    FSPerpheralClient   *_client;
    CBCentral           *_central;
    CBMutableCharacteristic *_logCharacteristic;
}

+ (void)install {
    if (!kBLEService) {
        kBLEService = [[FSBLEPerpheralService alloc] init];
        kBLEService->_manager = [[CBPeripheralManager alloc] initWithDelegate:kBLEService queue:nil];
    }
}

#pragma mark - Business Logic

+ (void)updateLogCharacteristicWithNumber:(Byte)number date:(NSDate *)date level:(Byte)level content:(NSString *)content {
    if (kBLEService->_central) {
        NSData *logData = [FSBLEUtilities getLogDataWithNumber:number date:date level:level content:content];
        [kBLEService->_manager updateValue:logData forCharacteristic:kBLEService->_logCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
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
