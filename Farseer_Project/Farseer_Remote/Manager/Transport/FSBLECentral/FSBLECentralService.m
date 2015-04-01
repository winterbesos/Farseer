//
//  FSBLECentralService.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/22/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLECentralService.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "FSPackageIn.h"
#import "FSBLECentralPackerFactory.h"
#import "FSCentralClient.h"
#import "FSBLEUtilities.h"
#import "FSPackageDecoder.h"

static FSBLECentralService *service = nil;

@interface FSBLECentralService () <CBCentralManagerDelegate, CBPeripheralDelegate, FSPackageDecoderDelegate>

@end

@implementation FSBLECentralService {
    CBCentralManager    *_manager;
    id                  _client;
    NSTimer             *_bleConnectTimer;
    
    void(^didDisconveredCallback)(CBPeripheral *peripheral, NSNumber *RSSI);
    void(^connectionStatusChangedCallback)(CBPeripheral *peripheral);
    void(^stateChangedCallback)(CBCentralManagerState state);
    
    CBPeripheral *_peripheral;
    FSPackageDecoder *_packageDecoder;
}

#pragma mark - Class Method

+ (void)install {
    if (!service) {
        service = [[FSBLECentralService alloc] init];
        service->_manager = [[CBCentralManager alloc] initWithDelegate:service queue:nil];
        service->_client = [[FSCentralClient alloc] init];
        service->_packageDecoder = [[FSPackageDecoder alloc] initWithDelegate:service];
    }
}

+ (void)installWithClient:(id)client stateChangedCallback:(void(^)(CBCentralManagerState state))callback {
    if (!service) {
        service = [[FSBLECentralService alloc] init];
        service->stateChangedCallback = callback;
        service->_manager = [[CBCentralManager alloc] initWithDelegate:service queue:nil];
        service->_client = client;
        service->_packageDecoder = [[FSPackageDecoder alloc] initWithDelegate:service];
    }
}

+ (void)uninstall {
    [service->_manager stopScan];
    service->_client = nil;
    service->stateChangedCallback = nil;
    service->connectionStatusChangedCallback = nil;
    service->didDisconveredCallback = nil;
    service = nil;
}

+ (void)scanDidDisconvered:(void(^)(CBPeripheral *peripheral, NSNumber *RSSI))callback {
    service->didDisconveredCallback = callback;
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUIDString];
    [service->_manager scanForPeripheralsWithServices:@[serviceUUID] options:@{}];
}

+ (void)stopScan {
    [service->_manager stopScan];
}

+ (void)setConnectPeripheralCallback:(void(^)(CBPeripheral *peripheral))callback {
    service->connectionStatusChangedCallback = callback;
}

+ (void)connectToPeripheral:(CBPeripheral *)peripheral {
    [service connectToPeripheral:peripheral];
}

+ (void)getSendBoxInfoWithPath:(NSString *)path {
    NSData *reqSendBoxInfoData = [FSBLEUtilities getReqSendBoxInfoWithData:[FSBLEUtilities getDataWithPkgString:path]];
    for (CBService *ser in [service->_peripheral services]) {
        if ([ser.UUID.UUIDString isEqualToString:kServiceUUIDString]) {
            for (CBCharacteristic *characteristic in ser.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:kWriteCMDCharacteristicUUIDString]) {
                    [service->_peripheral writeValue:reqSendBoxInfoData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
//                    NSLog(@"C SEND: %@", reqLogData);
                    break;
                }
            }
            
            break;
        }
    }
}

#pragma mark - 

+ (void)requLogWithLogNumber:(UInt32)logNum {
    NSData *reqLogData = [FSBLEUtilities getReqLogWithNumber:logNum];
    for (CBService *ser in [service->_peripheral services]) {
        if ([ser.UUID.UUIDString isEqualToString:kServiceUUIDString]) {
            for (CBCharacteristic *characteristic in ser.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:kWriteLogCharacteristicUUIDString]) {
                    [service->_peripheral writeValue:reqLogData forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
//                    NSLog(@"C SEND: %@", reqLogData);
                    break;
                }
            }
            
            break;
        }
    }
}

- (void)writeACKWithHeader:(struct PKG_HEADER)header {
    header.cmd = CMDAck;
    
    for (CBService *ser in [service->_peripheral services]) {
        if ([ser.UUID.UUIDString isEqualToString:kServiceUUIDString]) {
            for (CBCharacteristic *characteristic in ser.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:kWriteLogCharacteristicUUIDString]) {

                    NSData *data = [NSData dataWithBytes:&header length:sizeof(struct PKG_HEADER)];
                    [_peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
//                    NSLog(@"C SEND ACK: %@", data);
                    break;
                }
            }
            
            break;
        }
    }
    
}

#pragma mark - Instance Method

- (void)connectToPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state == CBPeripheralStateConnecting) {
        [service->_manager cancelPeripheralConnection:peripheral];
        return;
    } else if (peripheral.state == CBPeripheralStateDisconnected) {
        service->_bleConnectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
        [service->_manager connectPeripheral:peripheral options:nil];
    } else {
        return;
    }
    connectionStatusChangedCallback(peripheral);
}

- (void)connectTimeout:(NSTimer *)timer {
    [_manager cancelPeripheralConnection:timer.userInfo];
    [self performSelector:@selector(connectToPeripheral:) withObject:timer.userInfo afterDelay:1];
}

#pragma mark - Package Decoder Delegate

- (void)packageDecoder:(FSPackageDecoder *)packageDecoder didDecodePackageData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral cmd:(CMD)cmd {
    
    FSPackageIn *packageIn = [FSPackageIn decode:data];
    [[FSBLECentralPackerFactory getObjectWithCMD:cmd] unpack:packageIn client:_client peripheral:peripheral];
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
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s value: %@", __FUNCTION__, characteristic.value);
    
//    NSLog(@"C RECV: %@", characteristic.value);
    struct PKG_HEADER header;
    [characteristic.value getBytes:&header length:sizeof(struct PKG_HEADER)];
    
    if (header.cmd != CMDCPInit) {
        [self writeACKWithHeader:header];
    }
    [_packageDecoder pushReceiveData:characteristic.value fromPeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
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
//        NSLog(@"disconverd in service: %@ characteristic: %@", service.UUID, characteristic.UUID);
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kWriteLogCharacteristicUUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            NSLog(@"discovered log characteristic");
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kWriteCMDCharacteristicUUIDString]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            NSLog(@"discovered cmd characteristic");
        }
        
        if ([[characteristic.UUID.UUIDString uppercaseString] isEqualToString:kPeripheralInfoCharacteristicUUIDString]) {
            [peripheral readValueForCharacteristic:characteristic];
//            NSLog(@"read value in char: %@", characteristic.UUID.UUIDString);
        }
    }
}

#pragma mark - CBCentralManager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    NSLog(@"%s: %ld", __FUNCTION__, (long)central.state);
    if (stateChangedCallback) {
        stateChangedCallback(central.state);
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
    connectionStatusChangedCallback(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    NSLog(@"%s: %@ %@ %@", __FUNCTION__, central, peripheral, error);
    _peripheral = nil;
    connectionStatusChangedCallback(peripheral);
    [_packageDecoder clearCache];
}

@end
