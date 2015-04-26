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

- (void)pushToDirVC {
    DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
//    [dirVC setPath:[FSUtilities FS_Path]];
    [self.navigationController pushViewController:dirVC animated:YES];
}

- (void)setRemoteDirectoryWrapper:(FSDirectoryWrapper *)remoteDirectoryWrapper {
    _remoteDirectoryWrapper = remoteDirectoryWrapper;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id targetViewController = [segue destinationViewController];
    if ([targetViewController isKindOfClass:[DirViewController class]]) {
        [(DirViewController *)targetViewController setRemotePath:@"" directoryWrapper:_remoteDirectoryWrapper];
    }
}

@end
