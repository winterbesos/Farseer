//
//  FSLogManager+Peripheral.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogManager+Peripheral.h"
#import "FSUtilities.h"
#import "FSDebugCentral.h"
#import "FSTransportManager.h"
#import "FSPeripheralClient.h"
#import "FSPackageIn.h"
#import "FSBLELog.h"

@implementation FSLogManager (Peripheral) 

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

- (void)inputLog:(FSBLELog *)log {
    [self FS_CreateLogFileIfNeed];
    
    dispatch_async(logFileOperationQueue, ^{
        const char *filePath = [kLifeCircleLogPath cStringUsingEncoding:NSUTF8StringEncoding];
        [self writeLog:log ToFile:filePath];
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

- (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = nil;
    });
}

- (NSArray *)logList {
    return cacheLogs;
}

@end
