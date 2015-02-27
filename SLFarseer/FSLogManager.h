//
//  FSLogManager.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;

@interface FSLogManager : NSObject

+ (NSArray *)logList;

+ (void)inputLog:(FSBLELog *)log toFile:(const char *)filePath;

+ (void)installLogFile:(const char *)filePath;

@end
