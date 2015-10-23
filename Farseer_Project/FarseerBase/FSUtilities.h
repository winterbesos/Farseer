//
//  FSUtilities.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FarseerBase_iOS.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FarseerBase_OSX.h>
#endif

@class FSBLELog;

@interface FSUtilities : NSObject

+ (NSString *)RootPath;

+ (NSString *)FS_Path;
+ (NSString *)FS_LogPath;
+ (NSString *)FS_LogBundleNamePath:(NSString *)bundleName;
+ (NSString *)FS_LogPeripheralPath:(NSString *)UUIDString bundleName:(NSString *)bundleName;
+ (NSString *)FS_LogFilePathWithFileName:(NSString *)fileName UUIDString:(NSString *)UUIDString bundleName:(NSString *)bundleName;
+ (BOOL)filePathExists:(NSString *)filePath;

+ (void)FS_CreatePathIfNeed:(NSString *)path;
+ (void)FS_CreateLogFileIfNeed:(NSString *)path;

+ (void)writeLog:(id<FSBLELogProtocol>)log ToFile:(const char *)filePath;

@end

@interface NSString (FSData)

@property (nonatomic, readonly)NSData *dataValue;

@end
