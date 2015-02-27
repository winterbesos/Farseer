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

static dispatch_queue_t logFileOperationQueue;
static NSMutableArray   *cacheLogs;

@implementation FSLogManager

+ (void)inputLog:(FSBLELog *)log toFile:(const char *)filePath {
    
    if (!logFileOperationQueue) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    
    dispatch_async(logFileOperationQueue, ^{
        [self writeLog:log ToFile:filePath];
        [self cacheLogIfNeed:log];
        [FSBLEPerpheralService inputLogToCacheWithLog:log];
    });
}

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
}

+ (void)cacheLogIfNeed:(FSBLELog *)log {
    if (cacheLogs) {
        [cacheLogs addObject:log];
    }
}

+ (void)installLogFile:(const char *)filePath {
    if (cacheLogs) {
        return;
    }
    
    if (!logFileOperationQueue) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = [NSMutableArray array];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:[NSString stringWithCString:filePath encoding:NSUTF8StringEncoding]];
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
