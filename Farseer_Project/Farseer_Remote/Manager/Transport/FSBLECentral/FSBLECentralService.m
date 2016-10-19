//
//  FSBLECentralService.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/22/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLECentralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSBLECentralPackerFactory.h"
#import "FSCentralClient.h"
#import "FSBLEUtilities.h"
#import "FSPackageDecoder.h"
#import "FSPackageEncoder.h"

@interface FSBLECentralService () <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation FSBLECentralService {
    __weak FSPackageDecoder    *_packageDecoder;
    __weak FSPackageEncoder    *_packageEncoder;
    
    CBCentralManager    *_manager;
    NSTimer             *_bleConnectTimer;
    NSTimer             *_writeCMDTimer;
    
    void(^didDisconveredCallback)(CBPeripheral *peripheral, NSNumber *RSSI);
    void(^connectionStatusChangedCallback)(CBPeripheral *peripheral);
    void(^stateChangedCallback)(CBCentralManagerState state);
    
    CBPeripheral        *_peripheral;
    NSMutableArray      *_sendingPackageGroup;
    NSData              *_sendingData;
    
    CBCharacteristic    *_peripheralInfoCharacteristic;
    CBCharacteristic    *_writeCMDCharacteristic;
    NSMutableArray      *_activePeripherals;
}

- (instancetype)initWithEncoder:(FSPackageEncoder *)encoder decoder:(FSPackageDecoder *)decoder stateChangedCallback:(void(^)(CBCentralManagerState state))callback {
    self = [super init];
    if (self) {
        stateChangedCallback = callback;
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _packageDecoder = decoder;
        _packageEncoder = encoder;
        _activePeripherals = [NSMutableArray array];
    }
    return self;
}

- (void)uninstall {
    [_bleConnectTimer invalidate];
    [_writeCMDTimer invalidate];
    stateChangedCallback = nil;
    connectionStatusChangedCallback = nil;
    didDisconveredCallback = nil;
}

- (void)scanDidDisconvered:(void(^)(CBPeripheral *peripheral, NSNumber *RSSI))callback {
    didDisconveredCallback = callback;
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    [_manager scanForPeripheralsWithServices:@[serviceUUID] options:@{}];
}

- (void)stopScan {
    [_manager stopScan];
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral callback:(void(^)(CBPeripheral *peripheral))callback {
    connectionStatusChangedCallback = callback;
    if (peripheral.state == CBPeripheralStateConnecting) {
        [_manager cancelPeripheralConnection:peripheral];
        [_activePeripherals removeObject:peripheral];
        return;
    } else if (peripheral.state == CBPeripheralStateDisconnected) {
        _bleConnectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
        [_manager connectPeripheral:peripheral options:nil];
        [_activePeripherals addObject:peripheral];
    } else {
        return;
    }
    connectionStatusChangedCallback(peripheral);
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral) {
        [_manager cancelPeripheralConnection:peripheral];
        [_activePeripherals removeObject:peripheral];
    }
}

- (void)disconnectAllPeripherals {
    for (CBPeripheral *peripheral in _activePeripherals) {
        if (peripheral.state != CBPeripheralStateDisconnected) {
            [_activePeripherals removeObject:peripheral];
            [_manager cancelPeripheralConnection:peripheral];
        }
    }
}

- (void)connectTimeout:(NSTimer *)timer {
    [_manager cancelPeripheralConnection:timer.userInfo];
    [_activePeripherals removeObject:timer.userInfo];
}

- (void)writeValueTimeout:(NSTimer *)timer {
    [self clearBuffer];
}

- (void)writeValue:(NSData *)value toCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic) {
//        NSLog(@"C SEND: %@", value);
        _sendingData = value;
        [_peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        _writeCMDTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(writeValueTimeout:) userInfo:nil repeats:NO];
    }
}

- (void)writeACKWithHeader:(struct PKG_HEADER)header {
    NSMutableData *data = [NSMutableData dataWithBytes:&header length:sizeof(struct PKG_HEADER)];
    struct PROTOCOL_HEADER protocolHeader;
    protocolHeader.cmd = CMDAck;
    [data appendBytes:&protocolHeader length:sizeof(protocolHeader)];
    [self writeValue:data toCharacteristic:_writeCMDCharacteristic];
}

- (void)runSendLoop {
    if (!_sendingData) {
        if (!_sendingPackageGroup || _sendingPackageGroup.count == 0) {
            _sendingPackageGroup = [[_packageEncoder getTopPackageGroup] mutableCopy];
        }
        
        NSData *firstPackage = [_sendingPackageGroup firstObject];
        [_sendingPackageGroup removeObject:firstPackage];
        if (firstPackage) {
            [self writeValue:firstPackage toCharacteristic:_writeCMDCharacteristic];
        }
    }
}

- (void)clearBuffer {
    _sendingPackageGroup = nil;
    _sendingData = nil;
}

#pragma mark - CBPeripheral Delegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
//    NSLog(@"%s", __FUNCTION__);
    [_manager cancelPeripheralConnection:peripheral];
    [_activePeripherals removeObject:peripheral];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"C RECV: %@", characteristic.value);
    struct PKG_HEADER header;
    [characteristic.value getBytes:&header length:sizeof(struct PKG_HEADER)];
    if ([_packageDecoder pushReceiveData:characteristic.value fromPeripheral:peripheral]) {
        [self writeACKWithHeader:header];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"C SEND SUCCESS");
    [_writeCMDTimer invalidate];
    _sendingData = nil;
    [self runSendLoop];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s error: %@", __FUNCTION__, [error localizedDescription]);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[] forService:service];
//        NSLog(@"disconverd service: %@ discover characteristic ...", service.UUID);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kWriteLogCharacteristicUUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kWriteCMDCharacteristicUUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            _writeCMDCharacteristic = characteristic;
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kWriteDataCharacteristicUUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kPeripheralInfoCharacteristicUUIDString]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

#pragma mark - CBCentralManager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    NSLog(@"%s: %ld", __FUNCTION__, (long)central.state);
    if (stateChangedCallback) {
        stateChangedCallback((CBCentralManagerState)central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, dict);
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripherals);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripherals);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
//    NSLog(@"%s: %@ %@ %@", __FUNCTION__, peripheral, advertisementData, RSSI);
    didDisconveredCallback(peripheral, RSSI);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    NSLog(@"%s: %@ %@", __FUNCTION__, central, peripheral);
    [_bleConnectTimer invalidate];
    _peripheral = peripheral;
    connectionStatusChangedCallback(peripheral);
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    _peripheral = nil;
    [self clearBuffer];
    connectionStatusChangedCallback(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    _peripheral = nil;
    [self clearBuffer];
    connectionStatusChangedCallback(peripheral);
    [_packageDecoder clearCache];
}

@end
