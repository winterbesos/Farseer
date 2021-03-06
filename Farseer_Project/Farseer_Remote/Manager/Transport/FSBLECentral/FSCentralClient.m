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
#import "FSPackageEncoder.h"
#import "FSPackageDecoder.h"
#import "FSBLELogInfo.h"
#import "FSBLELog.h"
#import "NSString+FSBLECatetory.h"

@interface FSCentralClient () <FSPackageEncoderDelegate, FSPackageDecoderDelegate>

@end

@implementation FSCentralClient {
    id<FSCentralClientDelegate> _delegate;
    FSPackageEncoder *_encoder;
    FSPackageDecoder *_decoder;
    FSBLECentralService *_service;
}

- (void)setupWithDelegate:(id<FSCentralClientDelegate>)delegate statusChangedCallback:(void(^)(CBCentralManagerState state))callback {
    _delegate = delegate;
    _encoder = [[FSPackageEncoder alloc] initWithDelegate:self];
    _decoder = [[FSPackageDecoder alloc] initWithDelegate:self];
    _service = [[FSBLECentralService alloc] initWithEncoder:_encoder decoder:_decoder stateChangedCallback:callback];
}

- (void)requestLog {
    [_encoder pushDataToSendQueue:nil cmd:CMDReqLogging];
}

- (void)makePeripheralCrash {
    [_encoder pushDataToSendQueue:nil cmd:CMDReqMakeCrash];
}

- (void)getSandBoxInfoWithPath:(NSString *)path {
    [_encoder pushDataToSendQueue:path.SLEncodeData cmd:CMDReqSandBoxInfo];
}

- (void)getSandBoxFileWithPath:(NSString *)path {
    [_encoder pushDataToSendQueue:path.SLEncodeData cmd:CMDReqData];
}

#pragma mark - Callback

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName peripheral:(CBPeripheral *)peripheral deviceUUID:(NSString *)deviceUUID {
    FSBLELogInfo *logInfo = [FSBLELogInfo infoWithType:osType osVersion:osVersion deviceType:deviceType deviceName:deviceName bundleName:bundleName deviceUUID:deviceUUID];
    [_delegate client:self didReceiveLogInfo:logInfo];
}

- (void)recvLog:(id<FSBLELogProtocol>)log {
    [_delegate client:self didReceiveLog:log];
    
    UInt32 nextSequence = log.sequence + 1;
    NSMutableData *logData = [NSMutableData dataWithBytes:&nextSequence length:sizeof(nextSequence)];
    [_encoder pushDataToSendQueue:logData cmd:CMDReqLogging];
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

#pragma mark - PackageDecoder Delegate

#pragma mark - PackageEncoder Delegate

- (void)packageEncoderDidPushData:(FSPackageEncoder *)encoder {
    [_service runSendLoop];
}

@end
