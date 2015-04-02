//
//  DirViewController.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirViewController : UITableViewController

// local
- (void)setPath:(NSString *)path;

// remote
- (void)setRemotePath:(NSString *)path;
- (void)recvSandBoxInfo:(NSDictionary *)sandBoxInfo;
- (void)recvSandBoxFile:(NSData *)sandBoxData;

@end
