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

@property (strong, nonatomic)TracksView *tracksView;

@end

@implementation LogViewController {
    BOOL _showLogNumber;
    BOOL _showLogDate;
    
    NSMutableArray  *_logList;
    FSLogWrapper *_logWrapper;
    NSString *_registerFileName;
    NSString *_registerFunctionName;
    BOOL _disableOtherItem;
    BOOL _showExplorer;
}

- (void)awakeFromNib {
    _logList = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapTableView:)];
    [self.tableView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.navigationController.navigationBarHidden = YES;

    _showLogNumber = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_NUMBER_KEY];
    _showLogDate = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_TIME_KEY];
    
    _logList = [[_logWrapper registerLogWithDelegate:self fileName:_registerFileName functionName:_registerFunctionName] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Public Method

- (void)setWrapper:(FSLogWrapper *)logWrapper FileName:(NSString *)fileName functionName:(NSString *)functionName {
    _disableOtherItem = (fileName != nil);
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
    _logWrapper = [[FSLogWrapper alloc] initWithFilePath:path];
    _disableOtherItem = YES;
    _showExplorer = YES;
}

#pragma mark - Actions

- (void)longTapTableView:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self.view.superview];
    location.x = location.x - 50;
    location.y = location.y + 20;
    if (tap.state == UIGestureRecognizerStateBegan) {
        [self.tracksView displayWithLocation:location];
        [[UIApplication sharedApplication].keyWindow addSubview:self.tracksView];
    } else if (tap.state == UIGestureRecognizerStateChanged) {
        [self.tracksView touchesMovedToLocation:location];
    } else if (tap.state == UIGestureRecognizerStateCancelled) {
        [self.tracksView touchesCancelled];
        [self.tracksView removeFromSuperview];
    } else if (tap.state == UIGestureRecognizerStateEnded) {
        [self.tracksView touchesEnded];
        [self.tracksView removeFromSuperview];
    } else {
        [self.tracksView touchesCancelled];
        [self.tracksView removeFromSuperview];
    }
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
    [_logWrapper writeToFileCallback:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"The log has been saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)clearLog {
    [_logList removeAllObjects];
    [self.tableView reloadData];
}

- (void)crash {
    makeCrash();
}

- (void)showOrHideTime {
    _showLogDate = !_showLogDate;
    [self.tableView reloadData];
}

- (void)showOrHideSequence {
    _showLogNumber = !_showLogNumber;
    [self.tableView reloadData];
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

- (BOOL)tracksView:(TracksView *)TracksView shouldSelectAtIndex:(NSInteger)index {
    if (!_disableOtherItem) {
        return YES;
    } else {
        if (_showExplorer) {
            return index == 4 || index == 0 || index == 1 || index == 7;
        }
        return index == 4 || index == 1 || index == 7;
    }
}

- (void)tracksView:(TracksView *)tracksView didSelectItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self showExplorerLogViewController];
            break;
        case 1:
            [self showOrHideTime];
            break;
        case 2:
            [self clearLog];
            break;
        case 3:
            [self saveLog];
            break;
        case 4:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 5:
            [self crash];
            break;
        case 6:
            [self continueLog];
            break;
        case 7:
            [self showOrHideSequence];
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
    [cell setLog:_logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate showLogColor:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LogTableViewCell calculateCellHeightWithLog:_logList[indexPath.row] showLogNumber:_showLogNumber showLogDate:_showLogDate];
}

#pragma mark - Properties

- (TracksView *)tracksView {
    if (!_tracksView) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        _tracksView = [[TracksView alloc] initWithFrame:CGRectMake(50, 0, screenBounds.size.width - 50, screenBounds.size.height)];
        _tracksView.backgroundColor = [UIColor clearColor];
        _tracksView.delegate = self;
        [_tracksView setImageItems:@[[UIImage imageNamed:@"filter-b"],
                                     [UIImage imageNamed:@"showtime-b"],
                                     [UIImage imageNamed:@"clear-b"],
                                     [UIImage imageNamed:@"save-b"],
                                     [UIImage imageNamed:@"back-b"],
                                     [UIImage imageNamed:@"crash-b"],
                                     [UIImage imageNamed:@"continue-b"],
                                     [UIImage imageNamed:@"showlineno-b"]]
               highlightItemImages:@[[UIImage imageNamed:@"filter"],
                                     [UIImage imageNamed:@"showtime"],
                                     [UIImage imageNamed:@"clear"],
                                     [UIImage imageNamed:@"save"],
                                     [UIImage imageNamed:@"back"],
                                     [UIImage imageNamed:@"crash"],
                                     [UIImage imageNamed:@"continue"],
                                     [UIImage imageNamed:@"showlineno"]]
                      disableItems:@[[UIImage imageNamed:@"filter-g"],
                                     [UIImage imageNamed:@"showtime-g"],
                                     [UIImage imageNamed:@"clear-g"],
                                     [UIImage imageNamed:@"save-g"],
                                     [UIImage imageNamed:@"back-g"],
                                     [UIImage imageNamed:@"crash-g"],
                                     [UIImage imageNamed:@"continue-g"],
                                     [UIImage imageNamed:@"showlineno-g"]]
                         itemNames:@[@"Filter", @"Toggle Time", @"Clear", @"Save", @"Back", @"Crash", @"Start", @"Toggle Sequence"]];
        
    }
    return _tracksView;
}

@end
