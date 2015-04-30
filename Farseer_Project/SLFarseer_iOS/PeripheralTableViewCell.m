//
//  PeripheralTableViewCell.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/4.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "PeripheralTableViewCell.h"
#import <CoreBluetooth/CBPeripheral.h>

@implementation PeripheralTableViewCell {
    __weak IBOutlet UIActivityIndicatorView *connectingIndicator;
    __weak IBOutlet UIImageView *connectableImageView;
    
}
- (void)awakeFromNib {
    self.textLabel.font = [UIFont systemFontOfSize:15.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Method

- (void)setPripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI {
    if (RSSI.intValue == -127) {
        self.textLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.textLabel.textColor = [UIColor blackColor];
        switch (peripheral.state) {
            case CBPeripheralStateConnected:
            case CBPeripheralStateDisconnected:
                connectingIndicator.hidden = YES;
                connectableImageView.hidden = NO;
                break;
            case CBPeripheralStateConnecting:
                connectableImageView.hidden = YES;
                connectingIndicator.hidden = NO;
                [connectingIndicator startAnimating];
                break;
            default:
                NSAssert(NO, @"错误的连接类型");
                break;
        }
    }

    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.text = [NSString stringWithFormat:@"   %@ RSSI:%@", peripheral.name, RSSI];
}

@end
