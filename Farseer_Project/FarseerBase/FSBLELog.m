//
//  FSBLELog.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELog.h"
#import "FSUtilities.h"
#import "FSPackageIn.h"

@implementation FSBLELog

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line {
    FSBLELog *log = [[FSBLELog alloc] init];
    log.sequence = number;
    log.log_date = date;
    log.log_level = level;
    log.log_domain = content;
    log.log_fileName = file;
    log.log_functionName = function;
    log.log_line = line;
    return log;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u %@ %d %@", (unsigned int)self.sequence, self.log_date, self.log_level, self.log_domain];
}

#pragma mark - FSBLELog Protocol

- (NSData *)BLETransferEncode {
    NSTimeInterval logTimeInterval = [self.log_date timeIntervalSinceReferenceDate];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_sequence length:sizeof(typeof(self.sequence))];
    [data appendBytes:&logTimeInterval length:sizeof(logTimeInterval)];
    
    FSLogLevel level = self.log_level;
    [data appendBytes:&level length:sizeof(level)];
    [data appendData:self.log_domain.dataValue];
    [data appendData:self.log_fileName.dataValue];
    [data appendData:self.log_functionName.dataValue];
    
    UInt32 line = self.log_line;
    [data appendBytes:&line length:sizeof(line)];
    
    return data;
}

- (void)BLETransferDecodeWithData:(NSData *)data {
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
//    _sequence = [packageIn readUInt32];
    self.log_date = [packageIn readDate];
    self.log_level = [packageIn readByte];
    self.log_domain = [packageIn readString];
    self.log_fileName = [packageIn readString];
    self.log_functionName = [packageIn readString];
    self.log_line = [packageIn readUInt32];
}

@end
