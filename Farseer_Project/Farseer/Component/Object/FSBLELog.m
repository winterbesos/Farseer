//
//  FSBLELog.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELog.h"
#import "FSBLEUtilities.h"

static UInt32 logNumber = 0;

@implementation FSBLELog

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line {
    FSBLELog *log = [[FSBLELog alloc] init];
    log->_log_number = number;
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
        log->_log_number = logNumber;
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

- (NSData *)dataValue {
    NSTimeInterval logTimeInterval = [_log_date timeIntervalSinceReferenceDate];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_log_number length:sizeof(_log_number)];
    [data appendBytes:&logTimeInterval length:sizeof(logTimeInterval)];
    [data appendBytes:&_log_level length:sizeof(_log_level)];
    [data appendData:[FSBLEUtilities getDataWithPkgString:_log_content]];
    [data appendData:[FSBLEUtilities getDataWithPkgString:_log_fileName]];
    [data appendData:[FSBLEUtilities getDataWithPkgString:_log_functionName]];
    [data appendBytes:&_log_line length:sizeof(_log_line)];
    
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u %@ %d %@", (unsigned int)self.log_number, self.log_date, self.log_level, self.log_content];
}

@end
