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
#import "NSString+FSBLECatetory.h"
#import "FSDebugCentral.h"
#import "FSFileManager.h"

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
        id<FSBLELogProtocol> log = logList[logNum];
        NSData *classNameData = NSStringFromClass(log.class).SLEncodeData;
        NSData *dataValue = [log BLETransferEncode];
        UInt32 length = (UInt32)dataValue.length;
        
        NSMutableData *writeData = [NSMutableData dataWithData:classNameData];
        [writeData appendBytes:&length length:sizeof(length)];
        [writeData appendData:dataValue];
        [FSBLEPeripheralService updateCharacteristic:_logCharacteristic withData:writeData cmd:CMDResLogging];
        
        if (_waitingLogNumber != -1) {
            _waitingLogNumber = -1;
        }
    } else {
        _waitingLogNumber = logNum;
    }
}

- (void)writeLogToCharacteristic:(id<FSBLELogProtocol>)log {
    if (_waitingLogNumber == log.sequence) {
        NSData *classNameData = NSStringFromClass(log.class).SLEncodeData;
        NSData *dataValue = [log BLETransferEncode];
        UInt32 length = (UInt32)dataValue.length;
        
        NSMutableData *writeData = [NSMutableData dataWithData:classNameData];
        [writeData appendBytes:&length length:sizeof(length)];
        [writeData appendData:dataValue];
        [FSBLEPeripheralService updateCharacteristic:_logCharacteristic withData:writeData cmd:CMDResLogging];
    }
}

- (void)recvGetSendBoxInfoWithPath:(NSString *)path {
    NSData *JSONData = [[FSDebugCentral getInstance].fileManager getDirectoryContentsWithPath:path];
    [FSBLEPeripheralService updateCharacteristic:_cmdCharacteristic withData:JSONData cmd:CMDResSandBoxInfo];
}

- (void)recvGetFileWithPath:(NSString *)path {
    NSData *fileData = [[FSDebugCentral getInstance].fileManager getFileWithPath:path];
    [FSBLEPeripheralService updateCharacteristic:_dataCharacteristic withData:fileData cmd:CMDResData];
}

@end
