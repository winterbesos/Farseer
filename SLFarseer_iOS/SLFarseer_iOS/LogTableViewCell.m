//
//  LogTableViewCell.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/2/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogTableViewCell.h"
#import "FSBLELog.h"

@implementation LogTableViewCell {
    __weak IBOutlet UILabel *logLabel;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLog:(FSBLELog *)log {
    logLabel.text = [NSString stringWithFormat:@"%@", log];
}

+ (CGFloat)calculateCellHeightWithLog:(FSBLELog *)log {
    NSString *content = [NSString stringWithFormat:@"%@", log];
    
    CGRect rect = [content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    return rect.size.height;
}

@end
