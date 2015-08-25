//
//  FSLogManager+Central.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSCentralLogManager.h"
#import "FSUtilities.h"
#import "FSBLELogInfo.h"
#import "FSBLECentralService.h"

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

#pragma mark - Public Method
// DOING:
- (void)sendLogToEmailToAddress:(NSString *)address withSubject:(NSString *)subject attachments:(NSArray *)attachments {
    /*
    NSString *bodyText = @"Copyright (c) 2014 Farseer";
    
    NSString *emailString = [NSString stringWithFormat:@"\
                             tell application \"Mail\"\n\
                             set newMessage to make new outgoing message with properties {subject:\"%@\", content:\"%@\" & return} \n\
                             tell newMessage\n\
                             set visible to false\n\
                             set sender to \"%@\"\n\
                             make new to recipient at end of to recipients with properties {name:\"%@\", address:\"%@\"}\n\
                             tell content\n\
                             ", subject, bodyText, @"McAlarm alert", @"McAlarm User", address];
    
    //add attachments to script
    for (NSString *alarmPhoto in attachments) {
        emailString = [emailString stringByAppendingFormat:@"make new attachment with properties {file name:\"%@\"} at after the last paragraph\n\
                       ",alarmPhoto];
    }
    //finish script
    emailString = [emailString stringByAppendingFormat:@"\
                   end tell\n\
                   send\n\
                   end tell\n\
                   end tell"];
    
    
    
    //NSLog(@"%@",emailString);
    NSAppleScript *emailScript = [[NSAppleScript alloc] initWithSource:emailString];
    [emailScript executeAndReturnError:nil];
//    [emailScript release];
    

    NSLog(@"Message passed to Mail");
    */
}

- (void)requestLog {
    [FSBLECentralService requLogWithLogNumber:(UInt32)_logList.count];
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

- (void)makePeripheralCrash {
    [FSBLECentralService makePeripheralCrash];
}

@end
