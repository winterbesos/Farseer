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
#import "FSBLEUtilities.h"

static FSBLECenteralService *service = nil;

@interface FSBLECenteralService () <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation FSBLECenteralService {
    CBCentralManager    *_manager;
    id                  _client;
    NSTimer             *_bleConnectTimer;
    
    void(^didDisconveredCallback)(CBPeripheral *perpheral, NSNumber *RSSI);
    void(^connectPeripheralCallback)(CBPeripheral *perpheral);
    void(^stateChangedCallback)(CBCentralManagerState state);
    
    CBPeripheral *_peripheral;
}

#pragma mark - Class Method

+ (void)install {
    if (!service) {
        service = [[FSBLECenteralService alloc] init];
        service->_manager = [[CBCentralManager alloc] initWithDelegate:service queue:nil];
        service->_client = [[FSCentralClient alloc] init];
    }
}

+ (void)installWithClient:(id)client stateChangedCallback:(void(^)(CBCentralManagerState state))callback {
    if (!service) {
        service = [[FSBLECenteralService alloc] init];
        service->stateChangedCallback = callback;
        service->_manager = [[CBCentralManager alloc] initWithDelegate:service queue:nil];
        service->_client = client;
    }
}

+ (void)uninstall {
    [service->_manager stopScan];
    service->_client = nil;
    service->stateChangedCallback = nil;
    service->connectPeripheralCallback = nil;
    service->didDisconveredCallback = nil;
    service = nil;
}

+ (void)scanDidDisconvered:(void(^)(CBPeripheral *perpheral, NSNumber *RSSI))callback {
    service->didDisconveredCallback = callback;
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316"];
    [service->_manager scanForPeripheralsWithServices:@[serviceUUID] options:@{}];
}

+ (void)stopScan {
    [service->_manager stopScan];
}

+ (void)setConnectPeripheralCallback:(void(^)(CBPeripheral *perpheral))callback {
    service->connectPeripheralCallback = callback;
}

+ (void)connectToPeripheral:(CBPeripheral *)peripheral {
    [service connectToPeripheral:peripheral];
}

#pragma mark - 

+ (void)requLogWithLogNumber:(Byte)logNum {
    NSData *reqLogData = [FSBLEUtilities getReqLogWithNumber:logNum];
    for (CBService *ser in [service->_peripheral services]) {
        if ([ser.UUID.UUIDString isEqualToString:@"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316"]) {
            for (CBCharacteristic *characteristic in ser.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:@"622C6B76-5A52-48F7-8595-468F7B8DD11D"]) {
                    [service->_peripheral writeValue:reqLogData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    break;
                }
            }
            
            break;
        }
    }
}

#pragma mark - Instance Method

- (void)connectToPeripheral:(CBPeripheral *)perpheral {
    if (perpheral.state == CBPeripheralStateConnecting) {
        [service->_manager cancelPeripheralConnection:perpheral];
        return;
    } else if (perpheral.state == CBPeripheralStateDisconnected) {
        service->_bleConnectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(connectTimeout:) userInfo:perpheral repeats:NO];
        [service->_manager connectPeripheral:perpheral options:nil];
    } else {
        NSLog(@"is connected");
        return;
    }
    connectPeripheralCallback(perpheral);
    NSLog(@"%s", __FUNCTION__);
}

- (void)connectTimeout:(NSTimer *)timer {
    NSLog(@"connect to peripheral timeout, retrying");
    [_manager cancelPeripheralConnection:timer.userInfo];
    [self performSelector:@selector(connectToPeripheral:) withObject:timer.userInfo afterDelay:1];
}

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
        
        for (CBService *service in [peripheral services]) {
            if ([service.UUID.UUIDString isEqualToString:@"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316"]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID.UUIDString isEqualToString:@"622C6B76-5A52-48F7-8595-468F7B8DD11D"]) {
                        [FSBLECenteralService requLogWithLogNumber:0];
                        break;
                    }
                }
                
                break;
            }
        }
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
            NSLog(@"discovered log characteristic");
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:@"838D0104-C9B7-4B34-97B9-8213E24D5493"]) {
            [peripheral readValueForCharacteristic:characteristic];
            NSLog(@"read value in char: %@", characteristic.UUID.UUIDString);
        }
    }
}

#pragma mark - CBCentralManager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%s: %ld", __FUNCTION__, (long)central.state);
    if (stateChangedCallback) {
        stateChangedCallback(central.state);
    }
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
    NSLog(@"%s: %@ %@ %@", __FUNCTION__, peripheral, advertisementData, RSSI);
    didDisconveredCallback(peripheral, RSSI);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripheral);
    [_bleConnectTimer invalidate];
    _peripheral = peripheral;
    connectPeripheralCallback(peripheral);
    
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    _peripheral = nil;
    connectPeripheralCallback(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    _peripheral = nil;
    connectPeripheralCallback(peripheral);
}

@end
