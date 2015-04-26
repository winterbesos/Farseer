//
//  LogViewController.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DISPLAY_LOG_TIME_KEY @"DISPLAY_LOG_TIME_KEY"
#define DISPLAY_LOG_NUMBER_KEY @"DISPLAY_LOG_NUMBER_KEY"
#define DISPLAY_LOG_COLOR_KEY @"DISPLAY_LOG_COLOR_KEY"

@class FSLogWrapper;
@class FSBLELog;
@class CBPeripheral;

@interface LogViewController : UITableViewController

@property (nonatomic, readonly)NSString *pathValue;

- (void)setWrapper:(FSLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName;

- (void)setFile:(NSString *)path;
- (void)loagWithLogs:(NSArray *)logs pathValue:(NSString *)pathValue;
- (void)clearLog;
- (void)switchLogNumber;
- (void)switchLogDate;
- (FSBLELog *)lastLog;
- (NSArray *)displayLogs;

@end
