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
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

typedef NS_ENUM(NSInteger, DirType) {
    DirTypeRemote,
    DirTypeLocal,
};

@interface DirViewController () <FSDirectoryWrapperDelegate>

@end

@implementation DirViewController {
    NSArray *_contents;
    NSString *_path;
    
    // remote
    DirType _type;
    NSDictionary *_remotePathInfo;
    FSDirectoryWrapper *_directoryWrapper;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_path == nil) {
        assert(false);
    } else {
        switch (_type) {
            case DirTypeRemote:
//                _subRemoteVC = nil;
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

- (void)setRemotePath:(NSString *)path directoryWrapper:(FSDirectoryWrapper *)directoryWrapper {
    _path = path;
    if ([_path isEqualToString:@""]) {
        self.title = @"Documents";
    } else {
        self.title = _path.lastPathComponent;
    }
    _type = DirTypeRemote;
    _directoryWrapper = directoryWrapper;
    [FSBLECentralService getSandBoxInfoWithPath:path];
    _contents = [_directoryWrapper registerWithDelegate:self path:path];
}

#pragma mark - FSDirectoryWrapper Delegate

- (void)wrapper:(FSDirectoryWrapper *)wrapper didUpdateSubDirectoryInfo:(NSArray *)subDirectoryInfo {
    _contents = subDirectoryInfo;
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *fileName = _contents[indexPath.row][@"name"];
    NSString *fileType = _contents[indexPath.row][@"fileType"];
    cell.textLabel.text = fileName;
    if ([fileType isEqualToString:NSFileTypeDirectory]) {
        cell.imageView.image = [UIImage imageNamed:@"folder"];
    } else if ([fileName.pathExtension.lowercaseString isEqualToString:@"png"] || [fileName.pathExtension.lowercaseString isEqualToString:@"jpg"]) {
        cell.imageView.image = [UIImage imageNamed:@"image"];
    } else if ([fileName.pathExtension.lowercaseString isEqualToString:@"mp3"] || [fileName.pathExtension.lowercaseString isEqualToString:@"amr"] || [fileName.pathExtension.lowercaseString isEqualToString:@"wav"]) {
        cell.imageView.image = [UIImage imageNamed:@"music"];
    } else if ([fileName.pathExtension.lowercaseString isEqualToString:@"db"]) {
        cell.imageView.image = [UIImage imageNamed:@"database"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"file"];
    }
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
            [dirVC setRemotePath:filePath directoryWrapper:_directoryWrapper];
            [self.navigationController pushViewController:dirVC animated:YES];
        } else {
            // TODO: 当前用notif传输文件效率过低
//            [FSBLECentralService getSandBoxFileWithPath:filePath];
        }
    }
}

@end
