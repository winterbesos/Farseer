//
//  LogExplorerViewController.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLLogWrapper;

@interface LogExplorerViewController : UITableViewController

- (void)setWrapper:(SLLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName;

@end
