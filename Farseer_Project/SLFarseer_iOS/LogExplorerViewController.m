//
//  LogExplorerViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogExplorerViewController.h"
#import "LogViewController.h"
#import <objc/runtime.h>
#import <Farseer_Remote_iOS/FSLogWrapper.h>
#import <Farseer_Remote_iOS/FSBLELog.h>

@interface LogExplorerViewController () <FSLogWrapperDelegate>

@end

@implementation LogExplorerViewController {
    FSLogWrapper *_logWrapper;
    NSString *_registerFileName;
    NSString *_registerFunctionName;
    
    NSMutableArray *_dataList;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _dataList = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _dataList = [[_logWrapper registerKeyWithDelegate:self fileName:_registerFileName functionName:_registerFunctionName] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Action

- (IBAction)longPressCellGestureAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)longPress.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if ((_registerFileName ?: _dataList[indexPath.row]) && !(_registerFileName ? _dataList[indexPath.row] : nil)) {
            LogExplorerViewController *logExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogExplorerViewController"];
            [logExplorerVC setWrapper:_logWrapper FileName:_registerFileName ?: _dataList[indexPath.row] functionName:_registerFileName ? _dataList[indexPath.row] : nil];
            [self.navigationController pushViewController:logExplorerVC animated:YES];
        }
    }
}

#pragma mark - Public Method

- (void)setWrapper:(FSLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName {
    _logWrapper = logWrapper;
    _registerFileName = fileName;
    _registerFunctionName = functionName;
}

#pragma mark - LogWrapper Delegate

- (void)wrapper:(FSLogWrapper *)wrapper didInsertLog:(FSBLELog *)log {
    if (!_registerFunctionName && !_registerFileName) {
        if (![_dataList containsObject:log.log_fileName]) {
            [_dataList addObject:log.log_fileName];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else if (_registerFileName) {
        if (![_dataList containsObject:log.log_functionName]) {
            [_dataList addObject:log.log_functionName];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExplorerCell" forIndexPath:indexPath];
    cell.textLabel.text = _dataList[indexPath.row];
    if (!_registerFileName) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCellGestureAction:)];
        NSString *ext = [_dataList[indexPath.row] pathExtension];
        cell.imageView.image = [UIImage imageNamed:ext];
        [cell addGestureRecognizer:longPress];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LogViewController *logViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogViewController"];
    [logViewController setWrapper:_logWrapper FileName:_registerFileName ?: _dataList[indexPath.row] functionName:_registerFileName ? _dataList[indexPath.row] : nil];
    [self.navigationController pushViewController:logViewController animated:YES];
}

@end
