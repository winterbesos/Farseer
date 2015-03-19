//
//  FSBLELog.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELog.h"
#import "FSBLEUtilities.h"
#import "FSDebugCentral.h"

static UInt32 logNumber = 0;

@implementation FSBLELog

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content {
    FSBLELog *log = [[FSBLELog alloc] init];
    log->_log_number = number;
    log->_log_date = date;
    log->_log_level = level;
    log->_log_content = content;
    return log;
}

+ (FSBLELog *)createLogWithLevel:(Byte)level content:(NSString *)content {
    @synchronized([FSDebugCentral getInstance]) {
        FSBLELog *log = [[FSBLELog alloc] init];
        log->_log_number = logNumber;
        log->_log_date = [NSDate date];
        log->_log_level = level;
        log->_log_content = content;
        
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
    
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u %@ %d %@", (unsigned int)self.log_number, self.log_date, self.log_level, self.log_content];
}

@end
