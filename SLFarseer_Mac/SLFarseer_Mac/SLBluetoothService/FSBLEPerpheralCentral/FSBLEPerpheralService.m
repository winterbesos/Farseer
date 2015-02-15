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

static NSString *kReadUUIDString = @"622C6B76-5A52-48F7-8595-468F7B8DD11D";
static NSString *kServiceUUIDString = @"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316";
static CBPeripheralManager *manager = nil;

@interface FSBLEPerpheralService () <CBPeripheralManagerDelegate>

@end

@implementation FSBLEPerpheralService {
    FSPerpheralClient *_client;
}

- (void)setup {
    _client = [[FSPerpheralClient alloc] init];
    
    CBPeripheralManager *perpheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        manager = perpheralManager;
    
}

- (void)setupStatusMechine {
    
}

- (void)setupService {
    
    // 主Log通信服务
    CBUUID *cUUID = [CBUUID UUIDWithString:kReadUUIDString];
    CBCharacteristicProperties properties = CBCharacteristicPropertyWriteWithoutResponse; // CBCharacteristicPropertyBroadcast |
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:cUUID properties:properties value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    CBMutableService *service = [[CBMutableService alloc] initWithType:sUUID primary:true];
    [service setCharacteristics:@[characteristic]];
    [manager addService:service];
    
}

- (void)printIsAdvertising {
    NSLog(manager.isAdvertising ? @"advertising: true" : @"advertising: false");
}

#pragma mark - CBPerpheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"%s: %ld", __FUNCTION__, peripheral.state);

    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self setupService];
    }
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(printIsAdvertising) userInfo:nil repeats:YES];
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
        [manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SL TEST",
                                    CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:kServiceUUIDString]]}];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, characteristic);
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
