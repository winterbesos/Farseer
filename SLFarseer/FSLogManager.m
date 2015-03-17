//
//  FSLogManager.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSLogManager.h"
#import "FSBLELog.h"
#import "FSPackageIn.h"
#import "FSBLEPerpheralService.h"
#import <CoreBluetooth/CBPeripheral.h>
#import "FSDebugCentral.h"

#define OUTPUT_CONSOLE

static dispatch_queue_t logFileOperationQueue;
static NSMutableArray   *cacheLogs;
static NSString         *kLifeCircleLogPath; // 当前生命周期log文件路径

@implementation FSLogManager

#pragma mark - Get Path

+ (NSString *)FS_Path {
#if TARGET_OS_IPHONE
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [pathList objectAtIndex:0];
#elif TARGET_OS_MAC
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *dataPath = [path stringByAppendingPathComponent:bundleId]; // 相当于IOS的 documentpath
    #ifndef IMO_CONNECT_OFFICIAL_SERVER
        dataPath = [dataPath stringByAppendingString:@"DEV"];
    #endif
#endif
    return [dataPath stringByAppendingPathComponent:@"Farseer"];
}

+ (NSString *)FS_LogPath {
    return [[self FS_Path] stringByAppendingPathComponent:@"Log"];
}

+ (NSString *)FS_LogBundleNamePath:(NSString *)bundleName {
    return [[self FS_LogPath] stringByAppendingPathComponent:bundleName];
}

+ (NSString *)FS_LogPeripheralPath:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName {
    return [[self FS_LogBundleNamePath:bundleName] stringByAppendingPathComponent:peripheral.identifier.UUIDString];
}

+ (NSString *)FS_LogFilePathWithFileName:(NSString *)fileName peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName {
    return [[self FS_LogPeripheralPath:peripheral bundleName:bundleName] stringByAppendingPathComponent:fileName];
}

#pragma mark - Judge Path

+ (BOOL)filePathExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL];
}

#pragma mark - Create

+ (void)FS_CreatePathIfNeed:(NSString *)path {
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
}

+ (void)FS_CreateLogFileIfNeed:(NSString *)path {
    struct LOG_HEADER header;
    header.createTime = [NSDate timeIntervalSinceReferenceDate];
    NSData *contentData = [NSData dataWithBytes:&header length:sizeof(header)];
    NSError *err = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    [[NSFileManager defaultManager] createFileAtPath:path contents:contentData attributes:nil];
}

#pragma mark - Central

+ (NSString *)FS_CreateLogFileIfNeedWithPeripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *filePath = [self FS_LogFilePathWithFileName:fileName peripheral:peripheral bundleName:bundleName];
    if (![self filePathExists:filePath]) {
        [self FS_CreatePathIfNeed:[self FS_LogPeripheralPath:peripheral bundleName:bundleName]];
        [self FS_CreateLogFileIfNeed:filePath];
    }
    
    return filePath;
}

+ (void)inputLog:(FSBLELog *)log peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *fileFullPath = [self FS_CreateLogFileIfNeedWithPeripheral:peripheral bundleName:bundleName fileName:fileName];
    [self writeLog:log ToFile:[fileFullPath UTF8String]];
}

+ (void)saveLog:(NSArray *)logs peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName callback:(void(^)(float percentage))callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fileName = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        for (FSBLELog *log in logs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUInteger index = [logs indexOfObject:log];
                if (index % 50 == 0) {
                    callback(1.0 * index / logs.count);
                }
            });
            
            [self inputLog:log peripheral:peripheral bundleName:bundleName fileName:fileName];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(1);
        });
    });
}

#pragma mark - Peripheral

+ (NSString *)FS_CreateLogFileIfNeed {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            
        NSString *fileName = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        NSString *filePath = [[self FS_LogPath] stringByAppendingPathComponent:fileName];
        if (![self filePathExists:filePath]) {
            [self FS_CreateLogFileIfNeed:filePath];
        }
        kLifeCircleLogPath = filePath;
        
    });
    return kLifeCircleLogPath;
}

+ (void)inputLog:(FSBLELog *)log {
    [self FS_CreateLogFileIfNeed];

    if (!logFileOperationQueue) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    
    dispatch_async(logFileOperationQueue, ^{
        const char *filePath = [kLifeCircleLogPath cStringUsingEncoding:NSUTF8StringEncoding];
        [self writeLog:log ToFile:filePath];
        [self cacheLogIfNeed:log];
        [FSBLEPerpheralService inputLogToCacheWithLog:log];
    });
}

#pragma mark - Log Operation

// File

+ (void)writeLog:(FSBLELog *)log ToFile:(const char *)filePath {
    FILE    *fp = fopen(filePath, "a");
    if (!fp)
    {
        assert(false);
    }
    
    NSData *dataValue = [log dataValue];
    const void *bytes = [dataValue bytes];
    fwrite(bytes, sizeof(Byte), dataValue.length, fp);
    fclose(fp);

#ifdef OUTPUT_CONSOLE
    static NSString *currentPath = nil;
    if (!currentPath) {
        currentPath = [[FSLogManager FS_LogPath] stringByAppendingPathComponent:@"current.log"];
        
        fp = fopen(currentPath.UTF8String, "w");
        fprintf(fp, "\33[2J");
        fclose(fp);
    }
    
    fp = fopen(currentPath.UTF8String, "a");
    if (fp != NULL) {
        char *format = NULL;
        switch (log.log_level) {
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
        
        fprintf(fp, format, [kLogDateFormatter stringFromDate:log.log_date].UTF8String, log.log_content.UTF8String);
        fclose(fp);
    }
#endif
}

// Memory

+ (void)cacheLogIfNeed:(FSBLELog *)log {
    if (cacheLogs) {
        [cacheLogs addObject:log];
    }
}

+ (BOOL)installLogFile {
    if (cacheLogs) {
        return NO;
    }
    
    if (!logFileOperationQueue) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = [NSMutableArray array];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:kLifeCircleLogPath];
        FSPackageIn *packageIn = [[FSPackageIn alloc] initWithLogData:data];
        
        while (1) {
            UInt32 number = [packageIn readUInt32];
            NSDate *date = [packageIn readDate];
            Byte level = [packageIn readByte];
            NSString *content = [packageIn readString];
            if (!content) {
                break;
            }
            [cacheLogs addObject:[FSBLELog logWithNumber:number date:date level:level content:content]];
        }
    });
    
    return YES;
}

+ (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = nil;
    });
}

+ (NSArray *)logList {
    return cacheLogs;
}

@end
