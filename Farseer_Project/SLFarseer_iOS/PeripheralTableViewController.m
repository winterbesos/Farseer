//
//  PeripheralTableViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "PeripheralTableViewController.h"
#import <objc/runtime.h>
#import <CoreBluetooth/CBPeripheral.h>

#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

static void *AssociatedObjectHandle;

@interface PeripheralTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PeripheralTableViewController {
    NSMutableArray *_peripheralsDataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _peripheralsDataList = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self scanPeripheral];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopScanAndClearPeripheral];
}

#pragma mark - Private Method

- (void)scanPeripheral {
    [FSBLECentralService setConnectPeripheralCallback:^(CBPeripheral *peripheral) {
        switch (peripheral.state) {
            case CBPeripheralStateDisconnected:
                break;
            case CBPeripheralStateConnected:
                break;
            case CBPeripheralStateConnecting:
                break;
        }
        [self.tableView reloadData];
    }];
    [FSBLECentralService scanDidDisconvered:^(CBPeripheral *peripheral, NSNumber *RSSI) {
        NSInteger index = [_peripheralsDataList indexOfObject:peripheral];
        if (index == NSNotFound) {
            [_peripheralsDataList addObject:peripheral];
        } else {
            [_peripheralsDataList replaceObjectAtIndex:index withObject:peripheral];
        }
        
        objc_setAssociatedObject(peripheral, &AssociatedObjectHandle, RSSI, OBJC_ASSOCIATION_RETAIN);
        [self.tableView reloadData];
    }];
}

- (void)stopScanAndClearPeripheral {
    [FSBLECentralService stopScan];
    [self resetRSSI];
}

- (void)resetRSSI {
    for (CBPeripheral *peripheral in _peripheralsDataList) {
        objc_setAssociatedObject(peripheral, &AssociatedObjectHandle, @(-127), OBJC_ASSOCIATION_RETAIN);
    }
}

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peripheralsDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CBPeripheral *peripheral = _peripheralsDataList[indexPath.row];
    
    NSNumber *RSSI = objc_getAssociatedObject(peripheral, &AssociatedObjectHandle);
    UIColor *stateColor = nil;
    if (RSSI.intValue == -127) {
        stateColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    } else {
        switch (peripheral.state) {
            case CBPeripheralStateConnected:
                stateColor = [UIColor greenColor];
                break;
            case CBPeripheralStateConnecting:
                stateColor = [UIColor yellowColor];
                break;
            case CBPeripheralStateDisconnected:
                stateColor = [UIColor redColor];
                break;
            default:
                NSAssert(NO, @"错误的连接类型");
                break;
        }
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = stateColor;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ RSSI:%@", peripheral.name, RSSI];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = _peripheralsDataList[indexPath.row];
    [FSBLECentralService connectToPeripheral:peripheral];
}
@end
