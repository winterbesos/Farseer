//
//  DocumentTableViewController.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/4.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirViewController;
@class FSDirectoryWrapper;

@interface DocumentTableViewController : UITableViewController;

- (void)setRemoteDirectoryWrapper:(FSDirectoryWrapper *)remoteDirectoryWrapper;

@end
