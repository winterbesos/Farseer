//
//  LogTableViewCell.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/2/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSBLELog;

@interface LogTableViewCell : UITableViewCell

- (void)setLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate showLogColor:(BOOL)showLogColor;
+ (CGFloat)calculateCellHeightWithLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate;

@end
