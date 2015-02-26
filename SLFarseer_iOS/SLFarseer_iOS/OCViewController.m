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

@interface OCViewController ()

@property (strong, nonatomic) PeripheralTableViewController *leftViewController;
@property (strong, nonatomic) UIView *childControllerContainerView;

@end

@implementation OCViewController {
    LogViewController *_logViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FSBLECenteralService installWithClient:self stateChangedCallback:^(CBCentralManagerState state) {
        if (state == CBCentralManagerStatePoweredOn) {
            [self.leftViewController scanPeripheral];
        }
    }];
}

#pragma mark - Private Method

- (void)showPeripheralTableView {
    self.leftViewController.view.hidden = NO;
//    [self.leftViewController beginAppearanceTransition:YES animated:YES];
    
    CGRect newFrame = CGRectMake(0, 0, 200, self.view.bounds.size.height);
    
    [UIView
     animateWithDuration:(0.3)
     delay:0.0
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         [self.leftViewController.view setFrame:newFrame];
     }
     completion:^(BOOL finished) {
//         [self.leftViewController endAppearanceTransition];
     }];
}

- (void)hidePeripheralTableView {
    
}

#pragma mark - BLE Client

- (void)recvInitBLEWithOSType:(BLEOSType)osType osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName {
    NSLog(@"%s: %d %@ %@ %@ %@", __FUNCTION__, osType, osVersion, deviceType, deviceName, bundleName);
}

- (void)recvSyncLogWithLogNumber:(UInt32)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content {
    [_logViewController insertLogWithLogNumber:logNumber logDate:logDate logLevel:logLevel content:content];
    [FSBLECenteralService requLogWithLogNumber:(logNumber + 1)];
}

#pragma mark - Actions

- (IBAction)peripheralListButtonAction:(id)sender {
    [self showPeripheralTableView];
}

#pragma mark - Property

- (UIViewController *)leftViewController {
    if (!_leftViewController) {
        PeripheralTableViewController *leftVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PeripheralTableViewController"];
        self.leftViewController = leftVC;
        self.leftViewController.tableView.userInteractionEnabled = YES;
        
        [self addChildViewController:leftVC];
        
        [self.childControllerContainerView addSubview:leftVC.view];
        [self.childControllerContainerView sendSubviewToBack:leftVC.view];
        
        [leftVC.view setHidden:YES];
        [leftVC didMoveToParentViewController:self];
        [leftVC.view setFrame:CGRectMake(-200, 0, 200, leftVC.view.frame.size.height)];
    }
    
    return _leftViewController;
}

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    _logViewController = [segue destinationViewController];
}

@end
