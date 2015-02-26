//
//  LogViewController.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSBLELog;

@interface LogViewController : UITableViewController

- (void)insertLogWithLog:(FSBLELog *)log;

@end
