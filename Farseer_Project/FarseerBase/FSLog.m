//
//  FSLog.m
//  SLFarseer
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 Qeekers. All rights reserved.
//

#import "FSLog.h"
#import "FSUtilities.h"
#import "FSPackageIn.h"

@implementation FSLog

+ (instancetype)createLogWithLevel:(Byte)level domain:(NSString *)domain info:(NSDictionary *)info file:(const char *)file function:(const char *)function line:(unsigned int)line {
    FSBLELog *log = [[FSBLELog alloc] init];
    log.log_date = [NSDate date];
    log.log_level = level;
    log.log_domain = domain;
    log.log_fileName = [NSString stringWithUTF8String:file].lastPathComponent;
    log.log_functionName = [NSString stringWithUTF8String:function];
    log.log_line = line;
    log.log_info = info;
    
    return log;
}

- (BOOL)checkObject:(id)object {
    
    NSMutableDictionary *checked = [NSMutableDictionary dictionary];
    
    static BOOL(^checkObject)(id object);
    checkObject = ^(id object) {

        NSValue *value = [NSValue valueWithNonretainedObject:object];
        if (checked[value]) {
            return NO;
        } else if ([object isKindOfClass:[NSDictionary class]]
                   ||
                   [object isKindOfClass:[NSArray class]]) {
            [checked setObject:object forKey:value];
        }
        
        
        if ([object isKindOfClass:[NSString class]]
            ||
            [object isKindOfClass:[NSNumber class]]
            ||
            [object isKindOfClass:[NSData class]]
            ||
            [object isKindOfClass:[NSDate class]]) {
            return YES;
        } else if ([object isKindOfClass:[NSArray class]]) {
            for (id item in object) {
                if (!checkObject(item)) {
                    return NO;
                }
            }
            return YES;
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in [object allKeys]) {
                if (![key isKindOfClass:[NSString class]]) {
                    return NO;
                }
                
                id item = object[key];
                if (!checkObject(item)) {
                    return NO;
                }
            }
            
            return YES;
        }
        
        return NO;
    };
    
    return checkObject(object);
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
        
        fprintf(fp, format, [kLogDateFormatter stringFromDate:self.log_date].UTF8String, self.log_domain.UTF8String);
        fclose(fp);
    }
}

#pragma mark - FSStorageLog Protocol

- (NSData *)storageEncode {
    NSTimeInterval logTimeInterval = [_log_date timeIntervalSinceReferenceDate];
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&logTimeInterval length:sizeof(logTimeInterval)];
    [data appendBytes:&_log_level length:sizeof(_log_level)];
    [data appendData:_log_domain.dataValue];
    [data appendData:_log_fileName.dataValue];
    [data appendData:_log_functionName.dataValue];
    [data appendBytes:&_log_line length:sizeof(_log_line)];
    
    if ([self checkObject:_log_info]) {
        [data appendData:[NSKeyedArchiver archivedDataWithRootObject:_log_info].streamData];
    } else {
        UInt32 len = 0;
        [data appendBytes:&len length:sizeof(UInt32)];
    }
    
    return data;
}

- (void)storageDecodeWithData:(NSData *)data {
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
    _log_date = [packageIn readDate];
    _log_level = [packageIn readByte];
    _log_domain = [packageIn readString];
    _log_fileName = [packageIn readString];
    _log_functionName = [packageIn readString];
    _log_line = [packageIn readUInt32];
    
    NSData *infoData = [packageIn readData];
    if (infoData.length) {
        _log_info = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
    }
}

@end
