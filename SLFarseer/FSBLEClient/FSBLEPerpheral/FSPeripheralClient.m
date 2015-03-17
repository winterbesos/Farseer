//
//  FSPeripheralClient.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPeripheralClient.h"
#import "FSBLEPeripheralService.h"
#import "FSLogManager.h"
#import "FSBLEUtilities.h"
#import "FSBLELog.h"

@interface FSPeripheralClient ()

@property (nonatomic, readonly)CBMutableCharacteristic *infoCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *logCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *dataCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *cmdCharacteristic;

@end

@implementation FSPeripheralClient {
    UInt32                      _waitingLogNumber;
}

- (void)setPeripheralInfoCharacteristic:(CBMutableCharacteristic *)infoCharacteristic
                      logCharacteristic:(CBMutableCharacteristic *)logCharacteristic
                     dataCharacteristic:(CBMutableCharacteristic *)dataCharacteristic
                      cmdCharacteristic:(CBMutableCharacteristic *)cmdCharacteristic {
    _infoCharacteristic = infoCharacteristic;
    _logCharacteristic = logCharacteristic;
    _dataCharacteristic = dataCharacteristic;
    _cmdCharacteristic = cmdCharacteristic;
    _waitingLogNumber = -1;
}

#pragma mark - Business Logic

- (void)recvSyncLogWithLogNumber:(UInt32)logNum {
    NSArray *logList = [FSLogManager logList];
    if (logList.count > logNum) {
        FSBLELog *log = logList[logNum];
        NSData *logData = [FSBLEUtilities getLogDataWithNumber:log.log_number date:log.log_date level:log.log_level content:log.log_content];
        
        [FSBLEPeripheralService updateCharacteristic:_logCharacteristic withData:logData];
        
        if (_waitingLogNumber != -1) {
            _waitingLogNumber = -1;
        }
    } else {
        _waitingLogNumber = logNum;
    }
}

- (void)inputLogToCacheWithLog:(FSBLELog *)log {
//    if (kBLEService) {
//        if (kBLEService->_waitingLogNumber == log.log_number) {
//            [kBLEService updateLogCharacteristicWithLogNum:kBLEService->_waitingLogNumber];
//        }
//    }
}

- (void)uploadLogZipWithZipPath:(NSString *)zipPath {
//    NSError *err = nil;
//    NSData *data = [[NSData alloc] initWithContentsOfFile:zipPath options:NSDataReadingUncached error:&err];
//    NSAssert(err == nil, @"read file error: %@", err);
//    
//    NSData *subData = data;
//    [kBLEService->_manager updateValue:subData forCharacteristic:_dataCharacteristic onSubscribedCentrals:@[kBLEService->_central]];
}

@end
