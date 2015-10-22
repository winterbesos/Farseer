//
//  FSLogManager+Peripheral.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Eitdesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLELogProtocol.h>
#import <FarseerBase_iOS/FSBLELog.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLELogProtocol.h>
#import <FarseerBase_OSX/FSBLELog.h>
#endif

@class FSBLELog;

@interface FSLogManager: NSObject

- (void)cleanLogBeforeDate:(NSDate *)date;
- (void)inputLog:(id<FSBLELogProtocol>)log;

- (NSArray *)logList;
- (void)uninstallLogFile;
- (BOOL)installLogFile;

@end
