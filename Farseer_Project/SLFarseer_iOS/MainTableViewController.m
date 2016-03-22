//
//  MainTableViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/4.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "MainTableViewController.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>
#import <FarseerBase_iOS/FarseerBase_iOS.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <objc/runtime.h>
#import "LogViewController.h"
#import "DocumentTableViewController.h"
#import "DirViewController.h"
#import "PeripheralTableViewCell.h"

static char AssociatedObjectHandle;

@interface MainTableViewController () <FSCentralClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *OSTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *OSVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogTimeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *displayLogNumberSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logNavigationButton;

@end

@implementation MainTableViewController {
    __weak IBOutlet UIButton        *otherDeviceButton;
    __weak IBOutlet UILabel         *currentDeviceNameLabel;
    
    NSMutableArray                  *_peripheralsDataList;
    CBPeripheral                    *_activePeripheral;
    FSLogWrapper                    *_logWrapper;
    FSDirectoryWrapper              *_directoryWrapper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _peripheralsDataList = [NSMutableArray array];
    
    self.displayLogTimeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_TIME_KEY];
    self.displayLogNumberSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_LOG_NUMBER_KEY];
    
    setupBLEClient(self, ^(CBCentralManagerState state) {
        _activePeripheral = nil;
        otherDeviceButton.hidden = YES;
        currentDeviceNameLabel.text = @"No connected";
        [self displayLogInfo:nil];
        [_peripheralsDataList removeAllObjects];
        if (state == CBCentralManagerStatePoweredOn) {
            [self scanPeripheral];
            otherDeviceButton.hidden = YES;
        }
    });
}

#pragma mark - Private Method

- (void)scanPeripheral {
    scanPeripheral(^(CBPeripheral *peripheral, NSNumber *RSSI) {
        NSInteger index = [_peripheralsDataList indexOfObject:peripheral];
        objc_setAssociatedObject(peripheral, &AssociatedObjectHandle, RSSI, OBJC_ASSOCIATION_RETAIN);
        
        if (index == NSNotFound) {
            if (peripheral != _activePeripheral) {
                [_peripheralsDataList addObject:peripheral];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_peripheralsDataList.count inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
            }
        } else {
            [_peripheralsDataList replaceObjectAtIndex:index withObject:peripheral];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    });
}

- (void)closePeripheralList {
    NSMutableArray *peripheralIndexPaths = [NSMutableArray array];
    for (int index = 1; index <= _peripheralsDataList.count; index ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [peripheralIndexPaths addObject:indexPath];
    }
    
    [self stopScanAndClearPeripheral];
    [self.tableView deleteRowsAtIndexPaths:peripheralIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    otherDeviceButton.hidden = NO;
}

- (void)stopScanAndClearPeripheral {
    stopScan();
    [_peripheralsDataList removeAllObjects];
}

- (void)displayLogInfo:(FSBLELogInfo *)logInfo {
    NSString *osType = @"N/A";
    NSString *osVersion = @"N/A";
    NSString *deviceType = @"N/A";
    NSString *bundleName = @"N/A";

    if (logInfo) {
        switch (logInfo.log_OSType) {
            case BLEOSTypeIOS:
                osType = @"iOS";
                break;
            case BLEOSTypeOSX:
                osType = @"OSX";
                break;
        }
        osVersion = logInfo.log_OSVersion;
        deviceType = logInfo.log_deviceType;
        bundleName = logInfo.log_bundleName;
    }
    
    _logNavigationButton.enabled = logInfo != nil;
    
    _OSTypeLabel.text = osType;
    _OSVersionLabel.text = osVersion;
    _deviceTypeLabel.text = deviceType;
    _appNameLabel.text = bundleName;
}

#pragma mark - BLE Client Delegate

- (void)client:(FSCentralClient *)client didReceiveLogInfo:(FSBLELogInfo *)logInfo {
    [self displayLogInfo:logInfo];
    _logWrapper = [[FSLogWrapper alloc] initWithLogInfo:logInfo];
    _directoryWrapper = [[FSDirectoryWrapper alloc] init];
}

- (void)client:(FSCentralClient *)client didReceiveLog:(id<FSBLELogProtocol>)log {
    [_logWrapper insertLog:(FSBLELog *)log];
}

- (void)client:(FSCentralClient *)client didReceiveSandBoxInfo:(NSDictionary *)sandBoxInfo {
    [_directoryWrapper insertSandBoxInfo:sandBoxInfo];
}

- (void)recvSandBoxFile:(NSData *)sandBoxData {
//    [_remoteDirVC recvSandBoxFile:sandBoxData];
}

#pragma mark - Actions

- (IBAction)otherDeviceButtonAction:(id)sender {
    [self scanPeripheral];
}

- (IBAction)displayLogTimeSwitchAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:DISPLAY_LOG_TIME_KEY];
}

- (IBAction)displayLogNumberSwitchAction:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:DISPLAY_LOG_NUMBER_KEY];
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 ) {
        return _peripheralsDataList.count + 1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row != 0) {
        static NSString *identifier = @"PeripheralCell";
        PeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PeripheralTableViewCell" owner:self options:nil] firstObject];
        }
        
        CBPeripheral *peripheral = _peripheralsDataList[indexPath.row - 1];
        NSNumber *RSSI = objc_getAssociatedObject(peripheral, &AssociatedObjectHandle);
        [cell setPripheral:peripheral RSSI:RSSI];
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row != 0) {
        CBPeripheral *peripheral = _peripheralsDataList[indexPath.row - 1];
        if (_activePeripheral != peripheral) {
            disconnectPeripheral(_activePeripheral);
            connectToPeripheral(peripheral, ^(CBPeripheral *peripheral) {
                switch (peripheral.state) {
                    case CBPeripheralStateConnected: {
                        _activePeripheral = peripheral;
                        currentDeviceNameLabel.text = peripheral.name;
                        [self closePeripheralList];
                    }
                        break;
                    default: {
                        if (_activePeripheral.state != CBPeripheralStateConnected) {
                            otherDeviceButton.hidden = NO;
                            currentDeviceNameLabel.text = @"No connected";
                            [self displayLogInfo:nil];
                            _activePeripheral = nil;
                            otherDeviceButton.hidden = YES;
                            [self scanPeripheral];
                        }
                    }
                        break;
                }
            });
        } else {
            [self closePeripheralList];
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id targetViewController = [segue destinationViewController];
    if ([targetViewController isKindOfClass:[LogViewController class]]) {
        [((LogViewController *)targetViewController) setWrapper:_logWrapper FileName:nil functionName:nil];
    } else if ([targetViewController isKindOfClass:[DocumentTableViewController class]]) {
        [(DocumentTableViewController *)targetViewController setRemoteDirectoryWrapper:_directoryWrapper];
    }
}


@end
