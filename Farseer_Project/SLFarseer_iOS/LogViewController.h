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

@class FSBLELog;
@class CBPeripheral;

@interface LogViewController : UITableViewController

- (void)setFile:(NSString *)path;

- (void)insertLogWithLog:(FSBLELog *)log peripheral:(CBPeripheral *)peripheral;
- (void)clearLog;
- (void)switchLogNumber;
- (void)switchLogDate;
- (FSBLELog *)lastLog;
- (CBPeripheral *)selectedPeripheral;
- (NSArray *)displayLogs;
- (NSArray *)peripherals;
- (void)selectPeripheral:(CBPeripheral *)peripheral;

@end
