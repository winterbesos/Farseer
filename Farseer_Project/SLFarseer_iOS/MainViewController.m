//
//  OCViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "MainViewController.h"
#import "LogViewController.h"
#import "PeripheralTableViewController.h"
#import "TracksView.h"
#import "DirViewController.h"

#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

@interface MainViewController ()

@property (strong, nonatomic) PeripheralTableViewController *leftViewController;
@property (strong, nonatomic) UIView *childControllerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *osTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *osVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleNameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *displayLogTimeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogNumberSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogColorSwitch;
@property (weak, nonatomic) IBOutlet UILabel *savePercentageLabel;

@property (weak, nonatomic) IBOutlet TracksView *tracksView;

@end

@implementation MainViewController {
    LogViewController *_logViewController;
    
    BOOL leftVCIsOpen;
    BOOL leftVCIsAnimating;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Farseer";
    
    [self.tracksView setItemNames:@[@"upload log", @"delete log", @"clear log", @"Save Log", @"Dir", @"crash", @"continue", @"N/A"]];
    
    self.displayLogTimeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_TIME_KEY];
    self.displayLogTimeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_NUMBER_KEY];
    self.displayLogTimeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_COLOR_KEY];
    
    _logViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogViewController"];
    
    [FSBLECentralService installWithClient:self stateChangedCallback:nil];
    
    PeripheralTableViewController *leftVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PeripheralTableViewController"];
    self.leftViewController = leftVC;
    self.leftViewController.tableView.userInteractionEnabled = YES;
    
    [self addChildViewController:leftVC];
    
    [leftVC didMoveToParentViewController:self];
    [leftVC.view setFrame:CGRectMake(-200, 0, 200, [UIScreen mainScreen].bounds.size.height - 64)];
}

#pragma mark - Private Method

- (void)showPeripheralTableView {
    if (leftVCIsAnimating) {
        return;
    }
    leftVCIsAnimating = YES;
    
    [self.view addSubview:_childControllerContainerView];
    
    CGRect newFrame = CGRectMake(0, 0, 200, [UIScreen mainScreen].bounds.size.height - 64);
    [self.childControllerContainerView addSubview:self.leftViewController.view];
    
    [UIView
     animateWithDuration:(0.3)
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         [self.leftViewController.view setFrame:newFrame];
     }
     completion:^(BOOL finished) {
         leftVCIsAnimating = NO;
     }];
    leftVCIsOpen = YES;
}

- (void)hidePeripheralTableView {
    if (leftVCIsAnimating) {
        return;
    }
    leftVCIsAnimating = YES;
    CGRect newFrame = CGRectMake(-200, 0, 200, [UIScreen mainScreen].bounds.size.height - 64);
    
    [UIView
     animateWithDuration:(0.3)
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         [self.leftViewController.view setFrame:newFrame];
     }
     completion:^(BOOL finished) {
         [_childControllerContainerView removeFromSuperview];
         leftVCIsAnimating = NO;
     }];
    leftVCIsOpen = NO;
}

- (void)displayLogInfo:(FSBLELogInfo *)logInfo {
    NSString *osType = @"";
    NSString *osVersion = @"";
    NSString *deviceType = @"";
    NSString *deviceName = @"";
    NSString *bundleName = @"";
    if (logInfo) {
        switch (logInfo.log_type) {
            case BLEOSTypeIOS:
                osType = @"iOS";
                break;
            case BLEOSTypeOSX:
                osType = @"OSX";
                break;
        }
        osVersion = logInfo.log_OSVersion;
        deviceType = logInfo.log_deviceType;
        deviceName = logInfo.log_deviceName;
        bundleName = logInfo.log_bundleName;
    }
    
    self.osTypeLabel.text = osType;
    self.osVersionLabel.text = osVersion;
    self.deviceTypeLabel.text = deviceType;
    self.deviceNameLabel.text = deviceName;
    self.bundleNameLabel.text = bundleName;
}

- (void)crash {
    
}

- (void)deleteLog {
    
}

- (void)uploadLog {
    
}

- (void)pushToDirVC {
    DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
    [dirVC setPath:[FSUtilities FS_Path]];
    [self.navigationController pushViewController:dirVC animated:YES];
}

- (void)saveLog {
    NSArray *logs = [_logViewController displayLogs];
    
    saveLog(logs, [_logViewController selectedPeripheral], self.bundleNameLabel.text, ^(float percentage) {
        if (percentage == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存日志完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            self.savePercentageLabel.text = @"";
        } else {
            self.savePercentageLabel.text = [NSString stringWithFormat:@"%.0f%%", percentage * 100];
        }
    });
}

- (void)clearLog {
    [_logViewController clearLog];
}

- (void)continueLog {
    [FSBLECentralService requLogWithLogNumber:([_logViewController lastLog] ? [_logViewController lastLog].log_number : 0)];
}

#pragma mark - BLE Client

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName peripheral:(CBPeripheral *)peripheral {
    FSBLELogInfo *logInfo = [FSBLELogInfo infoWithType:osType osVersion:osVersion deviceType:deviceType deviceName:deviceName bundleName:bundleName];
    [self displayLogInfo:logInfo];
    [FSBLECentralService requLogWithLogNumber:0];
}

- (void)recvSyncLogWithLogNumber:(UInt32)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content peripheral:(CBPeripheral *)peripheral {
    FSBLELog *log = [FSBLELog logWithNumber:logNumber date:logDate level:logLevel content:content];
    [_logViewController insertLogWithLog:log peripheral:peripheral];
    [FSBLECentralService requLogWithLogNumber:(logNumber + 1)];
}

#pragma mark - Actions

- (IBAction)peripheralListButtonAction:(id)sender {
    if (leftVCIsOpen) {
        [self hidePeripheralTableView];
    } else {
        [self showPeripheralTableView];
    }
}

- (IBAction)logButtonAction:(id)sender {
    [self.navigationController pushViewController:_logViewController animated:YES];
}

- (IBAction)displayLogTimeSwitchAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:DISPLAY_LOG_TIME_KEY];
}

- (IBAction)displayLogNumberSwitchAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:DISPLAY_LOG_NUMBER_KEY];
}

- (IBAction)displayLogColorSwitchAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:DISPLAY_LOG_COLOR_KEY];
}

#pragma mark - Property

- (UIView *)childControllerContainerView {
    if (_childControllerContainerView == nil) {
        CGRect childContainerViewFrame = self.view.bounds;
        if(_childControllerContainerView == nil){
            _childControllerContainerView = [[UIView alloc] initWithFrame:childContainerViewFrame];
            [_childControllerContainerView setBackgroundColor:[UIColor clearColor]];
            [_childControllerContainerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            _childControllerContainerView.userInteractionEnabled = YES;
            [self.view addSubview:_childControllerContainerView];
        }
        
    }
    return _childControllerContainerView;
}

#pragma mark - Logo Label Delegate

- (void)tracksView:(TracksView *)tracksView didSelectItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self uploadLog];
            break;
        case 1:
            [self deleteLog];
            break;
        case 2:
            [self clearLog];
            break;
        case 3:
            [self saveLog];
            break;
        case 4:
            [self pushToDirVC];
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

@end
