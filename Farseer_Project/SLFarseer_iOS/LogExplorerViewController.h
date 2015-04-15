//
//  LogExplorerViewController.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBLELog.h"

@interface LogExplorerViewController : UITableViewController

@property (nonatomic, readonly)NSString *pathValue;

- (void)insertLog:(FSBLELog *)log;

@end
