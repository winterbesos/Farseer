//
//  LogTableViewCell.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/2/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogTableViewCell.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

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
        case Fatal:
            return FATAL_LOG_COLOR;
            break;
        case Error:
            return ERROR_LOG_COLOR;
            break;
        case Warning:
            return WARNING_LOG_COLOR;
            break;
        case Log:
            return LOG_LOG_COLOR;
            break;
        case Minor:
            return MINOR_LOG_COLOR;
            break;
    }
}

- (void)setLog:(FSBLELog *)log showLogNumber:(BOOL)showLogNumber showLogDate:(BOOL)showLogDate showLogColor:(BOOL)showLogColor {
    NSMutableString *contentString = [NSMutableString string];
    if (showLogNumber) {
        [contentString appendString:[NSString stringWithFormat:@"%05d ", (unsigned int)log.log_number]];
    }
    
    if (showLogDate) {
        [contentString appendFormat:@"%@ ", [LogTableViewCell getDateStringWithDate:log.log_date]];
    }
    
    UIColor *logColor = nil;
    if (showLogColor) {
        switch ((FSLogLevel)log.log_level) {
            case Fatal: {
                logColor = [UIColor redColor];
            }
                break;
            case Error: {
                logColor = [UIColor orangeColor];
            }
                break;
            case Warning: {
                logColor = [UIColor yellowColor];
            }
                break;
            case Log: {
                logColor = [UIColor greenColor];
            }
                break;
            case Minor: {
                logColor = [UIColor grayColor];
            }
                break;
            default:
                NSAssert(false, @"错误");
                break;
        }
    } else {
        logColor = [UIColor greenColor];
    }
    
    [contentString appendString:log.log_content];
    logLabel.text = contentString;
    
    logLabel.textColor = [self getLogColorWithLevel:log.log_level];
}

+ (CGFloat)calculateCellHeightWithLog:(FSBLELog *)log {
    NSString *content = [NSString stringWithFormat:@"%@", log];
    
    CGRect rect = [content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    return rect.size.height;
}

@end
