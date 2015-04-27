//
//  DocumentTableViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/4.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "DocumentTableViewController.h"
#import "DirViewController.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

@interface DocumentTableViewController ()

@end

@implementation DocumentTableViewController {
    FSDirectoryWrapper *_remoteDirectoryWrapper;
}

- (void)setRemoteDirectoryWrapper:(FSDirectoryWrapper *)remoteDirectoryWrapper {
    _remoteDirectoryWrapper = remoteDirectoryWrapper;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    id targetViewController = [segue destinationViewController];
    if ([sender.textLabel.text isEqualToString:@"目标沙盒"]) {
        [(DirViewController *)targetViewController setRemotePath:@"" directoryWrapper:_remoteDirectoryWrapper];
    } else if ([sender.textLabel.text isEqualToString:@"本地文件"]) {
        [(DirViewController *)targetViewController setPath:@""];
    }
}

@end
