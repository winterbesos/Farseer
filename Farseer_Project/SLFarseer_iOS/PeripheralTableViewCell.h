//
//  PeripheralTableViewCell.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/4.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

@interface PeripheralTableViewCell : UITableViewCell

- (void)setPripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;

@end
