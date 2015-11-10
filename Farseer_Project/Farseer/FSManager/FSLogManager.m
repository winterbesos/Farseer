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

@implementation FSLogManager {
    NSString            *logFileName;
    dispatch_queue_t    logFileOperationQueue;
    NSMutableDictionary *cacheLogDictionary;
    NSMutableArray      *cacheLogArray;
    UInt32              logNumber;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        logFileName = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    return self;
}

- (NSString *)FS_CreateLogFileIfNeedWithLog:(id<FSBLELogProtocol>)log {
    @synchronized(self) {
        NSString *fileFullName = [NSString stringWithFormat:@"%@.%@", logFileName, @"fsl"];
        NSString *filePathWithExtension = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileFullName];
        if (![FSUtilities filePathExists:filePathWithExtension]) {
            [FSUtilities FS_CreateLogFileIfNeed:filePathWithExtension];
        }
        
        return filePathWithExtension;
    }
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

- (void)inputLog:(id<FSBLELogProtocol>)log {
    [self FS_CreateLogFileIfNeedWithLog:log];
    dispatch_async(logFileOperationQueue, ^{
        log.sequence = logNumber++;
        NSString *fileFullName = [NSString stringWithFormat:@"%@.%@", logFileName, @"fsl"];
        NSString *filePathWithExtension = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileFullName];
        const char *filePath = [filePathWithExtension cStringUsingEncoding:NSUTF8StringEncoding];
        [FSUtilities writeLog:log ToFile:filePath];
        [self cacheLogIfNeed:log];
        [[FSDebugCentral getInstance].transportManager.peripheralClient writeLogToCharacteristic:log];
    });
}

// Memory

- (void)cacheLogIfNeed:(id<FSBLELogProtocol>)log {
    if (cacheLogDictionary) {
        NSMutableArray *logList = cacheLogDictionary[NSStringFromClass(log.class)];
        if (logList == nil) {
            logList = [NSMutableArray array];
            [cacheLogDictionary setObject:logList forKey:NSStringFromClass(log.class)];
        }
        [logList addObject:log];
    }
    
    if (cacheLogArray) {
        [cacheLogArray addObject:log];
    }
}

- (BOOL)installLogFile {
    if (cacheLogDictionary || cacheLogArray) {
        return NO;
    }
    
    dispatch_async(logFileOperationQueue, ^{
        cacheLogDictionary = [NSMutableDictionary dictionary];
        cacheLogArray = [NSMutableArray array];

        NSString *fileFullName = [NSString stringWithFormat:@"%@.%@", logFileName, @"fsl"];
        NSString *filePathWithExtension = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileFullName];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePathWithExtension];
        data = [data subdataWithRange:NSMakeRange(sizeof(struct LOG_HEADER), data.length - sizeof(struct LOG_HEADER))];
        FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
        while ([packageIn hasMore]) {
            NSString *className = [packageIn readString];
            UInt32 logLength = [packageIn readUInt32];
            NSData *logData = [packageIn readDataWithLength:logLength];
            Class cls = NSClassFromString(className);
            if (cls) {
                id log = [[cls alloc] init];
                [log BLETransferDecodeWithData:logData];
                [cacheLogArray addObject:log];
                
                if (!cacheLogDictionary[className]) {
                    NSMutableArray *typeLogArray = [NSMutableArray array];
                    [cacheLogDictionary setObject:typeLogArray forKey:className];
                }
                
                NSMutableArray *typeLogList = cacheLogDictionary[className];
                [typeLogList addObject:log];
            }
        }
    });
    
    return YES;
}

- (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogDictionary = nil;
        cacheLogArray = nil;
    });
}

- (NSArray *)logList {
    return cacheLogArray;
}

@end
