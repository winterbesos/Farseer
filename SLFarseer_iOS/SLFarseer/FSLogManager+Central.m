//
//  FSLogManager+Central.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogManager+Central.h"
#import "FSUtilities.h"

@implementation FSLogManager (Central)

- (NSString *)FS_CreateLogFileIfNeedWithPeripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *filePath = [FSUtilities FS_LogFilePathWithFileName:fileName peripheral:peripheral bundleName:bundleName];
    if (![FSUtilities filePathExists:filePath]) {
        [FSUtilities FS_CreatePathIfNeed:[FSUtilities FS_LogPeripheralPath:peripheral bundleName:bundleName]];
        [FSUtilities FS_CreateLogFileIfNeed:filePath];
    }
    
    return filePath;
}

- (void)inputLog:(FSBLELog *)log peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName fileName:(NSString *)fileName {
    NSString *fileFullPath = [self FS_CreateLogFileIfNeedWithPeripheral:peripheral bundleName:bundleName fileName:fileName];
    [self writeLog:log ToFile:[fileFullPath UTF8String]];
}

- (void)saveLog:(NSArray *)logs peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName callback:(void(^)(float percentage))callback {
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

@end
