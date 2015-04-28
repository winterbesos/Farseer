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
    DirType _type;
    
    // remote
    NSDictionary *_remotePathInfo;
    FSDirectoryWrapper *_directoryWrapper;
}

#pragma mark - Public Method

- (void)setPath:(NSString *)path {
    _path = path;
    _type = DirTypeLocal;
    
    if ([_path isEqualToString:@""]) {
        self.title = @"Documents";
    } else {
        self.title = _path.lastPathComponent;
    }
    
    NSString *contentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:_path];
    NSError *err;
    _contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentPath error:&err];
}

- (void)setRemotePath:(NSString *)path directoryWrapper:(FSDirectoryWrapper *)directoryWrapper {
    _path = path;
    _type = DirTypeRemote;
    
    if ([_path isEqualToString:@""]) {
        self.title = @"Documents";
    } else {
        self.title = _path.lastPathComponent;
    }
    
    _directoryWrapper = directoryWrapper;
    [FSBLECentralService getSandBoxInfoWithPath:path];
    _contents = [_directoryWrapper registerWithDelegate:self path:path];
}

#pragma mark - Private Method

- (UIImage *)getFileIconWithPath:(NSString *)path isDir:(BOOL)isDir {
    UIImage *fileIcon = nil;
    if (isDir) {
        fileIcon = [UIImage imageNamed:@"folder"];
    } else if ([path.pathExtension.lowercaseString isEqualToString:@"png"] || [path.pathExtension.lowercaseString isEqualToString:@"jpg"]) {
        fileIcon = [UIImage imageNamed:@"image"];
    } else if ([path.pathExtension.lowercaseString isEqualToString:@"mp3"] || [path.pathExtension.lowercaseString isEqualToString:@"amr"] || [path.pathExtension.lowercaseString isEqualToString:@"wav"]) {
        fileIcon = [UIImage imageNamed:@"music"];
    } else if ([path.pathExtension.lowercaseString isEqualToString:@"db"]) {
        fileIcon = [UIImage imageNamed:@"database"];
    } else if ([path.pathExtension.lowercaseString isEqualToString:@"fsl"]) {
        fileIcon = [UIImage imageNamed:@"fsl"];
    } else {
        fileIcon = [UIImage imageNamed:@"file"];
    }
    
    return fileIcon;
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
    BOOL isDir;
    if (_type == DirTypeRemote) {
        NSString *fileName = _contents[indexPath.row][@"name"];
        isDir = [_contents[indexPath.row][@"fileType"] isEqualToString:NSFileTypeDirectory];
        
        cell.textLabel.text = fileName;
        cell.imageView.image = [self getFileIconWithPath:fileName isDir:isDir];
    } else {
        NSString *contentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:_path];
        NSString *path = [contentPath stringByAppendingPathComponent:_contents[indexPath.row]];
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        
        NSString *fileName = _contents[indexPath.row];
        cell.imageView.image = [self getFileIconWithPath:path isDir:isDir];
        cell.textLabel.text = fileName;
    }
    
    if (isDir) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == DirTypeLocal) {
        NSString *contentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:_path];
        NSString *path = [contentPath stringByAppendingPathComponent:_contents[indexPath.row]];
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        
        if (isDir) {
            DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
            [dirVC setPath:[_path stringByAppendingPathComponent:_contents[indexPath.row]]];
            [self.navigationController pushViewController:dirVC animated:YES];
        } else if ([path.pathExtension isEqualToString:@"fsl"]) {
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
        }
    }
}

@end
