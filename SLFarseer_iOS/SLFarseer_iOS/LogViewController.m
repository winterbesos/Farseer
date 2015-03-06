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
#import <CoreBluetooth/CBPeripheral.h>
#import <objc/runtime.h>

static void *kHandleAssociatedKey;

@interface LogViewController ()

@end

@implementation LogViewController {
    BOOL _showLogNumber;
    BOOL _showLogDate;
    BOOL _showLogColor;
    
    NSMutableArray *_peripheralList;
    CBPeripheral *_displayPeripheral;
}

- (void)awakeFromNib {
    _peripheralList = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    [tapGesture setNumberOfTapsRequired:2];
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.navigationController.navigationBarHidden = YES;

    _showLogNumber = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_NUMBER_KEY];
    _showLogDate = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_TIME_KEY];
    _showLogColor = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_COLOR_KEY];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Public Method

- (void)insertLogWithLog:(FSBLELog *)log peripheral:(CBPeripheral *)peripheral {
    if (![_peripheralList containsObject:peripheral]) {
        [_peripheralList addObject:peripheral];
        objc_setAssociatedObject(peripheral, &kHandleAssociatedKey, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN);
    }
    
    if (_displayPeripheral == nil) {
        _displayPeripheral = peripheral;
    }
    
    NSMutableArray *logList = objc_getAssociatedObject(peripheral, &kHandleAssociatedKey);
    [logList addObject:log];
    
    if (_displayPeripheral == peripheral) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:logList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        if (self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height - 30) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:logList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)clearLog {
    NSMutableArray *logList = objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
    [logList removeAllObjects];
    [self.tableView reloadData];
}

- (void)switchLogNumber {
    _showLogNumber = !_showLogNumber;
    [self.tableView reloadData];
}

- (void)switchLogDate {
    _showLogDate = !_showLogDate;
    [self.tableView reloadData];
}

- (FSBLELog *)lastLog {
    NSMutableArray *logList = objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
    return [logList lastObject];
}

- (NSArray *)peripherals {
    return _peripheralList;
}

- (void)selectPeripheral:(CBPeripheral *)peripheral {
    _displayPeripheral = peripheral;
    [self.tableView reloadData];
}

- (NSArray *)displayLogs {
    return objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
}

- (CBPeripheral *)selectedPeripheral {
    return _displayPeripheral;
}

#pragma mark - Actions

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *logList = objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
    return logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
    NSMutableArray *logList = objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
    [cell setLog:logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate showLogColor:_showLogColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *logList = objc_getAssociatedObject(_displayPeripheral, &kHandleAssociatedKey);
    return [LogTableViewCell calculateCellHeightWithLog:logList[indexPath.row]];
}

@end
