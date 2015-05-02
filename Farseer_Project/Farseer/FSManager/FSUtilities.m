//
//  FSUtilities.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSUtilities.h"
#import <CoreBluetooth/CBPeripheral.h>
#import "FSBLEDefine.h"
#import "FSBLELog.h"
#import "FSBLELogInfo.h"

#define OUTPUT_CONSOLE

@implementation FSUtilities

#pragma mark - Get Path

+ (NSString *)RootPath {
#if TARGET_OS_IPHONE
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [pathList objectAtIndex:0];
#elif TARGET_OS_MAC
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *dataPath = [path stringByAppendingPathComponent:bundleId]; // 相当于IOS的 documentpath
#endif
    return dataPath;
}

+ (NSString *)FS_Path {
    return [[self RootPath] stringByAppendingPathComponent:@"Farseer"];
}

+ (NSString *)FS_LogPath {
    return [[self FS_Path] stringByAppendingPathComponent:@"Log"];
}

+ (NSString *)FS_LogBundleNamePath:(NSString *)bundleName {
    return [[self FS_LogPath] stringByAppendingPathComponent:bundleName];
}

+ (NSString *)FS_LogPeripheralPath:(NSString *)UUIDString bundleName:(NSString *)bundleName {
    return [[self FS_LogBundleNamePath:bundleName] stringByAppendingPathComponent:UUIDString];
}

+ (NSString *)FS_LogFilePathWithFileName:(NSString *)fileName UUIDString:(NSString *)UUIDString bundleName:(NSString *)bundleName {
    return [[self FS_LogPeripheralPath:UUIDString bundleName:bundleName] stringByAppendingPathComponent:fileName];
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

#pragma mark - Write File

+ (NSData *)FSLDataWithLogInfo:(FSBLELogInfo *)logInfo logList:(NSArray *)logList {
    NSMutableData *data = [NSMutableData data];
    
    // bump
    const char bump[15] = {'f', 's', 'l'};
    [data appendBytes:bump length:sizeof(bump)];
    
    // compoment
    Float32 logVersion = 1.0;
    Float64 generateId = [NSDate timeIntervalSinceReferenceDate];
    UInt64 comSize = sizeof(logVersion) + sizeof(generateId);
    
    [data appendBytes:&comSize length:sizeof(comSize)];
    [data appendBytes:&logVersion length:sizeof(logVersion)];
    [data appendBytes:&generateId length:sizeof(generateId)];
    
    // header
    NSData *headerData = [logInfo logInfo_data];
    UInt64 headSize = headerData.length;
    [data appendBytes:&headSize length:sizeof(headSize)];
    [data appendData:headerData];
    
    // body
    NSMutableData *logData = [NSMutableData data];
    for (FSBLELog *log in logList) {
        [logData appendData:log.dataValue];
    }
    
    UInt64 bodySize = logData.length;
    [data appendBytes:&bodySize length:sizeof(bodySize)];
    [data appendData:logData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *fileName = [[formatter stringFromDate:logInfo.log_saveLogDate] stringByAppendingPathExtension:@"fsl"];
    
    NSString *fileFullPath = [FSUtilities FS_LogFilePathWithFileName:fileName UUIDString:logInfo.log_deviceUUID bundleName:logInfo.log_bundleName];
    if (![FSUtilities filePathExists:fileFullPath]) {
        [FSUtilities FS_CreatePathIfNeed:[FSUtilities FS_LogPeripheralPath:logInfo.log_deviceUUID bundleName:logInfo.log_bundleName]];
        [FSUtilities FS_CreateLogFileIfNeed:fileFullPath];
    }
    
    // save data
    [data writeToFile:fileFullPath atomically:YES];
    
    return data;
}

// File

+ (void)writeLog:(FSBLELog *)log ToFile:(const char *)filePath {
    @synchronized(self) {
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
            currentPath = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:@"current.log"];
            
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
}

@end

@implementation NSString (FSData)

- (NSData *)dataValue {
    NSData *bodyData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    UInt32 len = (UInt32)bodyData.length;
    NSMutableData *pkgData = [NSMutableData dataWithBytes:&len length:sizeof(len)];
    [pkgData appendData:bodyData];
    
    return pkgData;
}

@end
