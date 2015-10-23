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
        log->_log_date = [NSDate date];
        log->_log_level = level;
        log->_log_content = content;
        log->_log_fileName = [NSString stringWithUTF8String:file].lastPathComponent;
        log->_log_functionName = [NSString stringWithUTF8String:function];
        log->_log_line = line;
        
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
    [data appendBytes:&_sequence length:sizeof(typeof(self.sequence))];
    [data appendBytes:&logTimeInterval length:sizeof(logTimeInterval)];
    [data appendBytes:&_log_level length:sizeof(_log_level)];
    [data appendData:_log_content.dataValue];
    [data appendData:_log_fileName.dataValue];
    [data appendData:_log_functionName.dataValue];
    [data appendBytes:&_log_line length:sizeof(_log_line)];
    
    return data;
}

- (void)BLETransferDecodeWithData:(NSData *)data {
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
    _sequence = [packageIn readUInt32];
    _log_date = [packageIn readDate];
    _log_level = [packageIn readByte];
    _log_content = [packageIn readString];
    _log_fileName = [packageIn readString];
    _log_functionName = [packageIn readString];
    _log_line = [packageIn readUInt32];
}

- (void)log_printToConsole {
    NSString *currentPath = nil;
    FILE    *fp = NULL;
    if (!currentPath) {
        currentPath = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:@"current.log"];
        fp = fopen(currentPath.UTF8String, "w");
        fprintf(fp, "\33[2J");
        fclose(fp);
    }
    
    fp = fopen(currentPath.UTF8String, "a");
    if (fp != NULL) {
        char *format = NULL;
        switch (self.log_level) {
            case 0:
                format = "\033[37m%s %s \033[0m\n";
                break;
            case 1:
                format = "\033[32m%s %s \033[0m\n";
                break;
            case 2:
                format = "\033[33m%s %s \033[0m\n";
                break;
            case 3:
                format = "\033[31m%s %s \033[0m\n";
                break;
            case 4:
                format = "\033[41;37m%s %s \033[0m\n";
                break;
        }
        
        static NSDateFormatter *kLogDateFormatter = nil;
        if (!kLogDateFormatter) {
            kLogDateFormatter = [[NSDateFormatter alloc] init];
            [kLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [kLogDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        }
        
        fprintf(fp, format, [kLogDateFormatter stringFromDate:self.log_date].UTF8String, self.log_content.UTF8String);
        fclose(fp);
    }
}

@end
