//
//  FSUtilities.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;
@class CBPeripheral;

@interface FSUtilities : NSObject

+ (NSString *)RootPath;

+ (NSString *)FS_Path;
+ (NSString *)FS_LogPath;
+ (NSString *)FS_LogBundleNamePath:(NSString *)bundleName;
+ (NSString *)FS_LogPeripheralPath:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName;
+ (NSString *)FS_LogFilePathWithFileName:(NSString *)fileName peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName;
+ (BOOL)filePathExists:(NSString *)filePath;

+ (void)FS_CreatePathIfNeed:(NSString *)path;
+ (void)FS_CreateLogFileIfNeed:(NSString *)path;

@end
