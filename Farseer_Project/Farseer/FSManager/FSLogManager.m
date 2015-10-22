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
        NSString *fileFullName = [NSString stringWithFormat:@"%@.%@", logFileName, [log saveFileExtension]];
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
        NSString *fileFullName = [NSString stringWithFormat:@"%@.%@", logFileName, [log saveFileExtension]];
        NSString *filePathWithExtension = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileFullName];
        const char *filePath = [filePathWithExtension cStringUsingEncoding:NSUTF8StringEncoding];
        if ([log supportPrint]) {
            [FSUtilities writeLog:log ToFile:filePath];
        }
        [self cacheLogIfNeed:log];
        [[FSDebugCentral getInstance].transportManager.peripheralClient writeLogToCharacteristic:log];
    });
}

// Memory

- (void)cacheLogIfNeed:(id<FSBLELogProtocol>)log {
    if (cacheLogDictionary) {
        NSMutableArray *logList = cacheLogDictionary[[log saveFileExtension]];
        if (logList == nil) {
            logList = [NSMutableArray array];
            [cacheLogDictionary setObject:logList forKey:[log saveFileExtension]];
        }
        [logList addObject:log];
    }
}

- (BOOL)installLogFile {
    if (cacheLogDictionary) {
        return NO;
    }
    
    dispatch_async(logFileOperationQueue, ^{
        cacheLogDictionary = [NSMutableDictionary dictionary];
        NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FSUtilities FS_LogPath] error:nil];
        for (NSString *fileName in fileNames) {
            if([fileName hasPrefix:logFileName]) {
                NSMutableArray *typeLogList = [NSMutableArray array];
                [cacheLogDictionary setObject:typeLogList forKey:fileName.pathExtension];
                
                
                NSData *data = [[NSData alloc] initWithContentsOfFile:[[FSUtilities FS_LogPath] stringByAppendingPathComponent:fileName]];
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
                    [typeLogList addObject:[FSBLELog logWithNumber:number date:date level:level content:content file:fileName function:functionName line:line]];
                }
            }
        }
    });
    
    return YES;
}

- (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogDictionary = nil;
    });
}

- (NSArray *)logList {
    return cacheLogDictionary[@"fsl"];
}

@end
