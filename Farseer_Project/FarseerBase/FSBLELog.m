//
//  FSBLELog.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELog.h"
#import "FSUtilities.h"

static UInt32 logNumber = 0;

@implementation FSBLELog

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line {
    FSBLELog *log = [[FSBLELog alloc] init];
    log->_sequence = number;
    log->_log_date = date;
    log->_log_level = level;
    log->_log_content = content;
    log->_log_fileName = file;
    log->_log_functionName = function;
    log->_log_line = line;
    return log;
}

+ (FSBLELog *)createLogWithLevel:(Byte)level content:(NSString *)content file:(const char *)file function:(const char *)function line:(unsigned int)line {
    static dispatch_once_t token;
    static NSObject *handleObject = nil;
    dispatch_once(&token, ^{
        handleObject = [[NSObject alloc] init];
    });
    @synchronized(handleObject) {
        FSBLELog *log = [[FSBLELog alloc] init];
        log->_sequence = logNumber;
        log->_log_date = [NSDate date];
        log->_log_level = level;
        log->_log_content = content;
        log->_log_fileName = [NSString stringWithUTF8String:file].lastPathComponent;
        log->_log_functionName = [NSString stringWithUTF8String:function];
        log->_log_line = line;
        
        logNumber ++;
        
        return log;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u %@ %d %@", (unsigned int)self.sequence, self.log_date, self.log_level, self.log_content];
}

#pragma mark - FSBLELog Protocol

- (NSData *)BLETransferEncode {
    NSTimeInterval logTimeInterval = [_log_date timeIntervalSinceReferenceDate];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_sequence length:sizeof(logNumber)];
    [data appendBytes:&logTimeInterval length:sizeof(logTimeInterval)];
    [data appendBytes:&_log_level length:sizeof(_log_level)];
    [data appendData:_log_content.dataValue];
    [data appendData:_log_fileName.dataValue];
    [data appendData:_log_functionName.dataValue];
    [data appendBytes:&_log_line length:sizeof(_log_line)];
    
    return data;
}

- (void)BLETransferDecodeWithData:(NSData *)data {
    
}

- (BOOL)supportPrint {
    return YES;
}

- (NSString *)saveFileExtension {
    return @"fsl";
}

@end
