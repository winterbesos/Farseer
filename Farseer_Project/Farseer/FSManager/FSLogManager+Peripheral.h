//
//  FSLogManager+Peripheral.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogManager.h"

@class FSBLELog;

@interface FSLogManager (Peripheral)

- (void)cleanLogBeforeDate:(NSDate *)date;
- (void)inputLog:(FSBLELog *)log;

- (NSArray *)logList;
- (void)uninstallLogFile;
- (BOOL)installLogFile;

@end
