//
//  FSPeripheralClient.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPeripheralClient.h"
#import "FSBLEPeripheralService.h"
#import "FSLogManager+Peripheral.h"
#import "FSBLEUtilities.h"
#import "FSBLELog.h"
#import "FSDebugCentral.h"

@interface FSPeripheralClient ()

@property (nonatomic, readonly)CBMutableCharacteristic *infoCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *logCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *dataCharacteristic;
@property (nonatomic, readonly)CBMutableCharacteristic *cmdCharacteristic;

@end

@implementation FSPeripheralClient {
    UInt32                      _waitingLogNumber;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _waitingLogNumber = -1;
    }
    return self;
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
    NSArray *logList = [[FSDebugCentral getInstance].logManager logList];
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

- (void)writeLogToCharacteristicIfWaitingWithLog:(FSBLELog *)log {
    if (_waitingLogNumber == log.log_number) {
        NSData *logData = [FSBLEUtilities getLogDataWithNumber:log.log_number date:log.log_date level:log.log_level content:log.log_content];
        [FSBLEPeripheralService updateCharacteristic:_logCharacteristic withData:logData];
    }
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
