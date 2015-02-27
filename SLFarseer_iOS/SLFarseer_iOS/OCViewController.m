//
//  OCViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "OCViewController.h"
#import "FSLog.h"
#import "FSBLEDefine.h"
#import "LogViewController.h"
#import "FSBLECenteralService.h"
#import "PeripheralTableViewController.h"
#import "FSBLELog.h"
#import "FSBLELogInfo.h"

#import "FSLogManager.h"

@interface OCViewController ()

@property (strong, nonatomic) PeripheralTableViewController *leftViewController;
@property (strong, nonatomic) UIView *childControllerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *osTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *osVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bundleNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *installedLogTextView;

@end

@implementation OCViewController {
    LogViewController *_logViewController;
    
    BOOL leftVCIsOpen;
    BOOL leftVCIsAnimating;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogViewController"];
    
    [FSBLECenteralService installWithClient:self stateChangedCallback:nil];
    
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
         [self.leftViewController.view removeFromSuperview];
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

#pragma mark - BLE Client

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName {
    FSBLELogInfo *logInfo = [FSBLELogInfo infoWithType:osType osVersion:osVersion deviceType:deviceType deviceName:deviceName bundleName:bundleName];
    [self displayLogInfo:logInfo];
    [FSBLECenteralService requLogWithLogNumber:0];
}

- (void)recvSyncLogWithLogNumber:(UInt32)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content {
    FSBLELog *log = [FSBLELog logWithNumber:logNumber date:logDate level:logLevel content:content];
    [_logViewController insertLogWithLog:log];
    [FSBLECenteralService requLogWithLogNumber:(logNumber + 1)];
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

- (IBAction)installLogButtonAction:(id)sender {
    [FSLogManager installLogFile:logFilePath()];
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

@end
