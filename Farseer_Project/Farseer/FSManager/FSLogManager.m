//
//  FSLogManager+Peripheral.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogManager.h"
#import "FSUtilities.h"
#import "FSDebugCentral.h"
#import "FSTransportManager.h"
#import "FSPeripheralClient.h"
#import <FarseerBase_iOS/FarseerBase_iOS.h>

@implementation FSLogManager {
    NSString         *kLifeCircleLogPath; // 当前生命周期log文件路径
    dispatch_queue_t logFileOperationQueue;
    NSMutableArray   *cacheLogs;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    return self;
}

- (NSString *)FS_CreateLogFileIfNeed {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *fileName = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        NSString *filePath = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileName];
        if (![FSUtilities filePathExists:filePath]) {
            [FSUtilities FS_CreateLogFileIfNeed:filePath];
        }
        kLifeCircleLogPath = filePath;
        
    });
    return kLifeCircleLogPath;
}

- (void)cleanLogBeforeDate:(NSDate *)date {
    NSError *error = nil;
    NSString *logPath = [FSUtilities FS_LogPath];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logPath error:&error];
    if (error) {
        return;
    }
    
    for (NSString *fileName in contents) {
        NSString *filePath = [logPath stringByAppendingPathComponent:fileName];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (error) {
            return;
        }
        NSDate *fileDate = attributes[NSFileCreationDate];
        if ([fileDate earlierDate:date] == fileDate) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                return;
            }
        }
    }
}

- (void)inputLog:(FSBLELog *)log {
    [self FS_CreateLogFileIfNeed];
    
    dispatch_async(logFileOperationQueue, ^{
        const char *filePath = [kLifeCircleLogPath cStringUsingEncoding:NSUTF8StringEncoding];
        [FSUtilities writeLog:log ToFile:filePath];
        [self cacheLogIfNeed:log];
        [[FSDebugCentral getInstance].transportManager.peripheralClient writeLogToCharacteristicIfWaitingWithLog:log];
    });
}

// Memory

- (void)cacheLogIfNeed:(FSBLELog *)log {
    if (cacheLogs) {
        [cacheLogs addObject:log];
    }
}

- (BOOL)installLogFile {
    if (cacheLogs) {
        return NO;
    }
    
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = [NSMutableArray array];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:kLifeCircleLogPath];
        data = [data subdataWithRange:NSMakeRange(sizeof(struct LOG_HEADER), data.length - sizeof(struct LOG_HEADER))];
        FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
        
        while (1) {
            UInt32 number = [packageIn readUInt32];
            NSDate *date = [packageIn readDate];
            Byte level = [packageIn readByte];
            NSString *content = [packageIn readString];
            NSString *fileName = [packageIn readString];
            NSString *functionName = [packageIn readString];
            UInt32 line = [packageIn readUInt32];
            if (!content) {
                break;
            }
            [cacheLogs addObject:[FSBLELog logWithNumber:number date:date level:level content:content file:fileName function:functionName line:line]];
        }
    });
    
    return YES;
}

- (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = nil;
    });
}

- (NSArray *)logList {
    return cacheLogs;
}

@end
