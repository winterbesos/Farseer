//
//  LogViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "LogViewController.h"
#import "LogTableViewCell.h"
#import <CoreBluetooth/CBPeripheral.h>
#import <objc/runtime.h>

#import <Farseer_Remote_iOS/FSBLELog.h>
#import "FSPackageIn.h"
#import "TracksView.h"
#import "LogExplorerViewController.h"

static void *kHandleAssociatedKey;

@interface LogViewController () <TracksViewDelegate>

@end

@implementation LogViewController {
    BOOL _showLogNumber;
    BOOL _showLogDate;
    BOOL _showLogColor;
    
    NSMutableArray *_peripheralList;
    CBPeripheral *_displayPeripheral;
    
    TracksView *_tracksView;
    LogExplorerViewController *_logExplorerVC;
}

- (void)awakeFromNib {
    _peripheralList = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    [tapGesture setNumberOfTapsRequired:2];
    [self.tableView addGestureRecognizer:tapGesture];
    
    _logExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogExplorerViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.navigationController.navigationBarHidden = YES;

    _showLogNumber = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_NUMBER_KEY];
    _showLogDate = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_TIME_KEY];
    _showLogColor = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_COLOR_KEY];
    [self.tableView reloadData];
    
    [self addTracksView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeTracksView];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)removeTracksView {
    [_tracksView removeFromSuperview];
}

- (void)addTracksView {
    if (!_tracksView) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        _tracksView = [[TracksView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width - 300, screenBounds.size.height)];
        _tracksView.backgroundColor = [UIColor clearColor];
        _tracksView.delegate = self;
        [_tracksView setItemNames:@[@"Log Explorer", @"delete log", @"clear log", @"Save Log", @"Dir", @"crash", @"continue", @"N/A"]];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_tracksView];
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
    
    [_logExplorerVC insertLog:log];
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

- (void)setFile:(NSString *)path {
    
    NSMutableArray *logList = [NSMutableArray array];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithLogData:data];
    
    while (1) {
        // TODO: add read LOG
        UInt32 number = [packageIn readUInt32];
        NSDate *date = [packageIn readDate];
        Byte level = [packageIn readByte];
        NSString *content = [packageIn readString];
        NSString *fileName = [packageIn readString];
        NSString *functionName = [packageIn readString];
        UInt32 line = [packageIn readUInt32];
        if (!content) {
            break;
        }
        [logList addObject:[FSBLELog logWithNumber:number date:date level:level content:content file:fileName function:functionName line:line]];
    }
    
    NSObject *peripheral = [[NSObject alloc] init];
    objc_setAssociatedObject(peripheral, &kHandleAssociatedKey, logList, OBJC_ASSOCIATION_RETAIN);
    _displayPeripheral = (CBPeripheral *)peripheral;
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showExplorerLogViewController {
    [self.navigationController pushViewController:_logExplorerVC animated:YES];
}

#pragma mark - Logo Label Delegate

- (void)tracksView:(TracksView *)tracksView didSelectItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self showExplorerLogViewController];
            break;
        case 1:
//            [self deleteLog];
            break;
        case 2:
//            [self clearLog];
            break;
        case 3:
//            [self saveLog];
            break;
        case 4:
//            [self pushToDirVC];
            break;
        case 5:
//            [self crash];
            break;
        case 6:
//            [self continueLog];
            break;
        default:
            break;
    }
    
//    NSLog(@"%ld", (long)index);
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
    return [LogTableViewCell calculateCellHeightWithLog:logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate];
}

@end
