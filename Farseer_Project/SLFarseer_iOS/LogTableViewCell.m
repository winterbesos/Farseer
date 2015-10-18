//
//  LogTableViewCell.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/2/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogTableViewCell.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>
#import <FarseerBase_iOS/FSBLELog.h>

#define MINOR_LOG_COLOR     [UIColor grayColor]
#define LOG_LOG_COLOR       [UIColor greenColor]
#define WARNING_LOG_COLOR   [UIColor yellowColor]
#define ERROR_LOG_COLOR     [UIColor orangeColor]
#define FATAL_LOG_COLOR     [UIColor redColor]

static NSDateFormatter *kLogDateFormatter;

@implementation LogTableViewCell {
    __weak IBOutlet UILabel *logLabel;
}

+ (NSString *)getDateStringWithDate:(NSDate *)date {
    if (!kLogDateFormatter) {
        kLogDateFormatter = [[NSDateFormatter alloc] init];
        [kLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [kLogDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    
    return [kLogDateFormatter stringFromDate:date];
}

- (UIColor *)getLogColorWithLevel:(FSLogLevel)level {
    switch (level) {
        case FSLogLevelFatal:
            return FATAL_LOG_COLOR;
            break;
        case FSLogLevelError:
            return ERROR_LOG_COLOR;
            break;
        case FSLogLevelWarning:
            return WARNING_LOG_COLOR;
            break;
        case FSLogLevelLog:
            return LOG_LOG_COLOR;
            break;
        case FSLogLevelMinor:
            return MINOR_LOG_COLOR;
            break;
    }
}

- (void)setLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate showLogColor:(BOOL)showLogColor {
    logLabel.text = [LogTableViewCell getContentStringWithLog:log showLogNumber:showLogNumber showLogDate:showLogDate];
    logLabel.textColor = [self getLogColorWithLevel:log.log_level];
}

+ (CGFloat)calculateCellHeightWithLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate {
    CGRect rect = [[self getContentStringWithLog:log showLogNumber:showLogNumber showLogDate:showLogDate] boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    return rect.size.height;
}

+ (NSString *)getContentStringWithLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate {
    NSMutableString *contentString = [NSMutableString string];
    
    if (showLogNumber) {
        [contentString appendString:[NSString stringWithFormat:@"%05d ", (unsigned int)log.sequence]];
    }
    
    if (showLogDate) {
        [contentString appendFormat:@"%@ ", [LogTableViewCell getDateStringWithDate:log.log_date]];
    }
    
    [contentString appendString:log.log_content];
    
    return contentString;
}

@end
