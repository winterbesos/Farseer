//
//  FSCentralClient.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSCentralClient.h"
#import "FSBLEUtilities.h"
#import "FSBLECentralService.h"
#import "FSBLELogInfo.h"
#import "FSBLELog.h"
#import "FSPackageEncoder.h"

@implementation FSCentralClient {
    id<FSCentralClientDelegate> _delegate;
    FSPackageEncoder *_encoder;
}

- (instancetype)initWithDelegate:(id<FSCentralClientDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _encoder = [[FSPackageEncoder alloc] init];
    }
    return self;
}

- (void)requestLogFromLogSequence:(UInt32)sequence callback:(void(^)(FSBLELog *log))callback {

    struct PKG_HEADER header;
    header.cmd = CMDReqLogging;
    header.currentPackageNumber = 1;
    header.lastPackageNumber = 1;
    header.sequId = 0;
    
    NSMutableData *requestData = [NSMutableData dataWithBytes:&header length:sizeof(struct PKG_HEADER)];
    [requestData appendBytes:&sequence length:sizeof(sequence)];
    
    [FSBLECentralService writeToLogCharacteristicWithValue:requestData];
}




- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName peripheral:(CBPeripheral *)peripheral deviceUUID:(NSString *)deviceUUID {
    FSBLELogInfo *logInfo = [FSBLELogInfo infoWithType:osType osVersion:osVersion deviceType:deviceType deviceName:deviceName bundleName:bundleName deviceUUID:deviceUUID];
    [_delegate client:self didReceiveLogInfo:logInfo];
}

- (void)recvSyncLogWithLogNumber:(UInt32)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content fileName:(NSString *)fileName functionName:(NSString *)functionName line:(UInt32)line peripheral:(CBPeripheral *)peripheral {
    FSBLELog *log = [FSBLELog logWithNumber:logNumber date:logDate level:logLevel content:content file:fileName function:functionName line:line];
    [_delegate client:self didReceiveLog:log];
    [FSBLECentralService requLogWithLogNumber:(logNumber + 1)];
}
- (void)recvSendBoxInfo:(NSDictionary *)sandBoxInfo {
    [_delegate client:self didReceiveSandBoxInfo:sandBoxInfo];
}

- (void)recvSandBoxFile:(NSData *)sandBoxData {
//    [_remoteDirVC recvSandBoxFile:sandBoxData];
}

- (void)recvOperationInfo:(NSData *)operationInfo {
    [_delegate client:self didReceiveOperation:operationInfo];
}

@end
