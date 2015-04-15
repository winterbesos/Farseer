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
    DirViewController *_remoteDirVC;
}

- (void)pushToDirVC {
    DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
//    [dirVC setPath:[FSUtilities FS_Path]];
    [self.navigationController pushViewController:dirVC animated:YES];
}

- (void)pushToRemoteDirVC {
    [self.navigationController pushViewController:_remoteDirVC animated:YES];
}

- (void)setRemoteDirVC:(DirViewController *)dirVC {
    _remoteDirVC = dirVC;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self pushToRemoteDirVC];
    } else if (indexPath.row == 1) {
        [self pushToDirVC];
    }
}

@end
