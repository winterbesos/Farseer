//
//  LogExplorerViewController.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSLogWrapper;

@interface LogExplorerViewController : UITableViewController

- (void)setWrapper:(FSLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName;

@end
