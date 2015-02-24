//
//  FSBLECenteralService.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/22/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLECenteralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSPackageIn.h"
#import "FSPackerFactory.h"
#import "FSCentralClient.h"

static FSBLECenteralService *service = nil;

@interface FSBLECenteralService () <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation FSBLECenteralService {
    CBCentralManager    *_manager;
    FSCentralClient     *_client;
    
    void(^didDisconveredCallback)(CBPeripheral *perpheral, NSNumber *RSSI);
    void(^connectPeripheralCallback)(CBPeripheral *perpheral, BOOL success);
}

#pragma mark - Class Method

+ (void)install {
    if (!service) {
        service = [[FSBLECenteralService alloc] init];
        service->_manager = [[CBCentralManager alloc] initWithDelegate:service queue:nil];
        service->_client = [[FSCentralClient alloc] init];
    }
}

+ (void)uninstall {
    [service->_manager stopScan];
    service->_client = nil;
    service->connectPeripheralCallback = nil;
    service->didDisconveredCallback = nil;
    service = nil;
}

+ (void)scanDidDisconvered:(void(^)(CBPeripheral *perpheral, NSNumber *RSSI))callback {
    service->didDisconveredCallback = callback;
    [service->_manager scanForPeripheralsWithServices:@[] options:@{}];
}

+ (void)setConnectPerpheralCallback:(void(^)(CBPeripheral *perpheral, BOOL success))callback {
    service->connectPeripheralCallback = callback;
}

+ (void)connectToPerpheral:(CBPeripheral *)perpheral {
    [service->_manager connectPeripheral:perpheral options:nil];
}

#pragma mark - Instance Method

- (void)statusMechine {
    
}

#pragma mark - CBPeripheral Delegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s value: %@", __FUNCTION__, characteristic.value);
    
    if ([characteristic.UUID.UUIDString isEqualToString:@"838D0104-C9B7-4B34-97B9-8213E24D5493"]) {
        Byte cmd;
        [characteristic.value getBytes:&cmd length:sizeof(cmd)];
        
        FSPackageIn *packageIn = [FSPackageIn decode:characteristic.value];
        [[FSPackerFactory getObjectWithCMD:cmd] unpack:packageIn client:_client];
    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:@"622C6B76-5A52-48F7-8595-468F7B8DD11D"]) {
        Byte cmd;
        [characteristic.value getBytes:&cmd length:sizeof(cmd)];
        
        FSPackageIn *packageIn = [FSPackageIn decode:characteristic.value];
        [[FSPackerFactory getObjectWithCMD:cmd] unpack:packageIn client:_client];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, [error localizedDescription]);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[] forService:service];
        NSLog(@"disconverd service: %@ discover characteristic ...", service.UUID);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"disconverd in service: %@ characteristic: %@", service.UUID, characteristic.UUID);
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:@"622C6B76-5A52-48F7-8595-468F7B8DD11D"]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scheduWrite:) userInfo:@{@"char" : characteristic, @"peri" : peripheral} repeats:YES];
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:@"838D0104-C9B7-4B34-97B9-8213E24D5493"]) {
            [peripheral readValueForCharacteristic:characteristic];
            NSLog(@"read value in char: %@", characteristic.UUID.UUIDString);
        }
    }
}

- (void)scheduWrite:(NSTimer *)timer {
    static int count = 1;
    count++;
    
    NSData *w = [NSData dataWithBytes:&count length:sizeof(count)];
    [timer.userInfo[@"peri"] writeValue:w forCharacteristic:timer.userInfo[@"char"] type:CBCharacteristicWriteWithoutResponse];
    
    if (count % 10 == 0) {
        [timer invalidate];
    }
}

#pragma mark - CBCentralManager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%s: %ld", __FUNCTION__, (long)central.state);
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, dict);
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripherals);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripherals);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
//    NSLog(@"%s: %@ %@ %@", __FUNCTION__, peripheral, advertisementData, RSSI);
    didDisconveredCallback(peripheral, RSSI);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripheral);
    connectPeripheralCallback(peripheral, YES);
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    connectPeripheralCallback(peripheral, NO);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    connectPeripheralCallback(peripheral, NO);
}

@end
