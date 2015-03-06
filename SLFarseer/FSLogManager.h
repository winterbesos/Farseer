//
//  FSLogManager.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;
@class CBPeripheral;

@interface FSLogManager : NSObject

+ (NSArray *)logList;
+ (void)inputLog:(FSBLELog *)log;

+ (void)uninstallLogFile;
+ (BOOL)installLogFile;

#pragma mark - Central

+ (void)saveLog:(NSArray *)logs peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName callback:(void(^)(float percentage))callback;

+ (NSString *)FS_Path;

@end
