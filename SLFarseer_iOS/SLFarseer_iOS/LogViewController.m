//
//  LogViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "LogViewController.h"
#import "LogTableViewCell.h"
#import "FSBLELog.h"

@interface LogViewController ()

@end

@implementation LogViewController {
    NSMutableArray *_logList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logList = [NSMutableArray array];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    [tapGesture setNumberOfTapsRequired:2];
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Public Method

- (void)insertLogWithLog:(FSBLELog *)log {
    [_logList addObject:log];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_logList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    if (!self.tableView.dragging) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_logList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - Actions

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
    [cell setLog:_logList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LogTableViewCell calculateCellHeightWithLog:_logList[indexPath.row]];
}

@end
