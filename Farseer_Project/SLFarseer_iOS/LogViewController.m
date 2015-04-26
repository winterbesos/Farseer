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
#import "FSPackageIn.h"
#import "TracksView.h"
#import "LogExplorerViewController.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

@interface LogViewController () <TracksViewDelegate, FSLogWrapperDelegate>

@end

@implementation LogViewController {
    BOOL _showLogNumber;
    BOOL _showLogDate;
    BOOL _showLogColor;
    
    TracksView *_tracksView;
    NSMutableArray  *_logList;
    FSLogWrapper *_logWrapper;
    NSString *_registerFileName;
    NSString *_registerFunctionName;
}

- (void)awakeFromNib {
    _logList = [NSMutableArray array];
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
    
    if (!_registerFileName) {
        [self addTracksView];
    }
    _logList = [[_logWrapper registerLogWithDelegate:self fileName:_registerFileName functionName:_registerFunctionName] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeTracksView];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)addTracksView {
    if (!_tracksView) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        _tracksView = [[TracksView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width * 0.8, screenBounds.size.height)];
        _tracksView.backgroundColor = [UIColor clearColor];
        _tracksView.delegate = self;
        [_tracksView setItemNames:@[@"Log Explorer", @"N/A", @"clear log", @"Save Log", @"N/A", @"crash", @"continue", @"N/A"]];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:_tracksView];
}

- (void)removeTracksView {
    [_tracksView removeFromSuperview];
}

#pragma mark - Public Method

- (void)setWrapper:(FSLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName {
    _logWrapper = logWrapper;
    _registerFileName = fileName;
    _registerFunctionName = functionName;
}

- (void)loagWithLogs:(NSArray *)logs pathValue:(NSString *)pathValue {
    _pathValue = pathValue;
    _logList = [logs mutableCopy];
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
    return [_logList lastObject];
}

- (NSArray *)displayLogs {
    return _logList;
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
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showExplorerLogViewController {
    LogExplorerViewController *logExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogExplorerViewController"];
    [logExplorerVC setWrapper:_logWrapper FileName:nil functionName:nil];
    [self.navigationController pushViewController:logExplorerVC animated:YES];
}

- (void)continueLog {
    requestLog();
}

- (void)saveLog {
    saveLog(^(float percentage) {
        if (percentage == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存日志完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    });
}

- (void)clearLog {
    [_logList removeAllObjects];
    [self.tableView reloadData];
}

- (void)crash {
    // TODO: remote control peripheral crash
}

#pragma mark - LogWrapper Delegate

- (void)wrapper:(FSLogWrapper *)wrapper didInsertLog:(FSBLELog *)log {
    [_logList addObject:log];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_logList.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height - 30) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_logList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - Logo Label Delegate

- (void)tracksView:(TracksView *)tracksView didSelectItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self showExplorerLogViewController];
            break;
        case 1:
            break;
        case 2:
            [self clearLog];
            break;
        case 3:
            [self saveLog];
            break;
        case 4:
            break;
        case 5:
            [self crash];
            break;
        case 6:
            [self continueLog];
            break;
        default:
            break;
    }
}

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
    [cell setLog:_logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate showLogColor:_showLogColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LogTableViewCell calculateCellHeightWithLog:_logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate];
}

@end
