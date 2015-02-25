//
//  FSBLELog.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELog.h"

@implementation FSBLELog

+ (FSBLELog *)logWithNumber:(Byte)number date:(NSDate *)date level:(Byte)level content:(NSString *)content {
    FSBLELog *log = [[FSBLELog alloc] init];
    log->_log_number = number;
    log->_log_date = date;
    log->_log_level = level;
    log->_log_content = content;
    return log;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d %@ %d %@", self.log_number, self.log_date, self.log_level, self.log_content];
}

@end
