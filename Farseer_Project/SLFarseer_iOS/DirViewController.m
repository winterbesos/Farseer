//
//  DirViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "DirViewController.h"
#import "FSLogManager.h"
#import "LogViewController.h"
#import "FSBLECentralService.h"

typedef NS_ENUM(NSInteger, DirType) {
    DirTypeRemote,
    DirTypeLocal,
};

@interface DirViewController ()

@end

@implementation DirViewController {
    NSArray *_contents;
    NSString *_path;
    
    // remote
    DirViewController *_subRemoteVC;
    DirType _type;
    NSDictionary *_remotePathInfo;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_path == nil) {
        assert(false);
    } else {
        switch (_type) {
            case DirTypeRemote:
                _subRemoteVC = nil;
                break;
            case DirTypeLocal:
                _contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Public Method

- (void)setPath:(NSString *)path {
    _path = path;
    _type = DirTypeLocal;
}

- (void)setRemotePath:(NSString *)path {
    _path = path;
    _type = DirTypeRemote;
    [FSBLECentralService getSandBoxInfoWithPath:path];
}

- (void)recvSandBoxInfo:(NSDictionary *)sandBoxInfo {
    if (_subRemoteVC) {
        [_subRemoteVC recvSandBoxInfo:sandBoxInfo];
    } else {
        _contents = sandBoxInfo[@"contents"];
        [self.tableView reloadData];
    }
}

- (void)recvSandBoxFile:(NSData *)sandBoxData {
    if (_subRemoteVC) {
        [_subRemoteVC recvSandBoxFile:sandBoxData];
    } else {
        NSLog(@"recv file size: %lu", sandBoxData.length);
    }
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _contents[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == DirTypeLocal) {
        NSString *path = [_path stringByAppendingPathComponent:_contents[indexPath.row]];
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        
        if (isDir) {
            DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
            [dirVC setPath:[_path stringByAppendingPathComponent:_contents[indexPath.row]]];
            [self.navigationController pushViewController:dirVC animated:YES];
        } else {
            LogViewController *logVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogViewController"];
            [logVC setFile:path];
            [self.navigationController pushViewController:logVC animated:YES];
        }
    } else {
        NSString *filePath = [_path stringByAppendingPathComponent:_contents[indexPath.row][@"name"]];
        if ([_contents[indexPath.row][@"fileType"] isEqualToString:NSFileTypeDirectory]) {
            DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
            [dirVC setRemotePath:filePath];
            _subRemoteVC = dirVC;
            [self.navigationController pushViewController:dirVC animated:YES];
        } else {
            // TODO: 当前用notif传输文件效率过低
//            [FSBLECentralService getSandBoxFileWithPath:filePath];
        }
    }
}

@end
