//
//  FSLogManager+Central.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSCentralLogManager.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLELogInfo.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLELogInfo.h>
#endif
#import "FSUtilities.h"
#import "FSBLECentralService.h"
#import "FSDebugCentral_Remote.h"

@implementation FSCentralLogManager {
    FSBLELogInfo *_logInfo;
    NSMutableArray *_logList;
}

- (void)setupCacheWithInfo:(FSBLELogInfo *)logInfo {
    _logInfo = logInfo;
    _logList = [NSMutableArray array];
}

- (void)cacheLog:(FSBLELog *)log {
    [_logList addObject:log];
}


- (void)clearCache {
    [_logList removeAllObjects];
}

- (NSString *)FS_CreateLogFileIfNeedWithUUIDString:(NSString *)UUIDString bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *filePath = [FSUtilities FS_LogFilePathWithFileName:fileName UUIDString:UUIDString bundleName:bundleName];
    if (![FSUtilities filePathExists:filePath]) {
        [FSUtilities FS_CreatePathIfNeed:[FSUtilities FS_LogPeripheralPath:UUIDString bundleName:bundleName]];
        [FSUtilities FS_CreateLogFileIfNeed:filePath];
    }
    
    return filePath;
}

- (void)inputLog:(FSBLELog *)log UUIDString:(NSString *)UUIDString bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *fileFullPath = [self FS_CreateLogFileIfNeedWithUUIDString:UUIDString bundleName:bundleName fileName:fileName];
    [FSUtilities writeLog:log ToFile:[fileFullPath UTF8String]];
}

- (void)requestLog {
    [[FSDebugCentral_Remote getInstance].centralClient requestLog];
}

- (void)saveLogCallback:(void(^)(float percentage))callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *fileName = [[formatter stringFromDate:_logInfo.log_saveLogDate] stringByAppendingPathExtension:@"fsl"];
        
        NSString *fileFullPath = [FSUtilities FS_LogFilePathWithFileName:fileName UUIDString:_logInfo.log_deviceUUID bundleName:_logInfo.log_bundleName];
        if (![FSUtilities filePathExists:fileFullPath]) {
            [FSUtilities FS_CreatePathIfNeed:[FSUtilities FS_LogPeripheralPath:_logInfo.log_deviceUUID bundleName:_logInfo.log_bundleName]];
            [FSUtilities FS_CreateLogFileIfNeed:fileFullPath];
        }
        
        for (FSBLELog *log in _logList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUInteger index = [_logList indexOfObject:log];
                if (index % 50 == 0) {
                    callback(1.0 * index / _logList.count);
                }
            });
        
            [FSUtilities writeLog:log ToFile:[fileFullPath UTF8String]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(1);
        });
    });
}

@end
