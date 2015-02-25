//
//  PeripheralTableViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "PeripheralTableViewController.h"
#import "FSBLECenteralService.h"
#import "FSBLEPerpheralService.h"
#import "FSBLECenteralService.h"
#import <objc/runtime.h>
#import <CoreBluetooth/CBPeripheral.h>

static void *AssociatedObjectHandle;

@interface PeripheralTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PeripheralTableViewController {
    NSMutableArray *_peripheralsDataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self scanPeripheral];
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopScanAndClearPeripheral];
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Private Method

- (void)scanPeripheral {
    _peripheralsDataList = [NSMutableArray array];
    [FSBLECenteralService setConnectPeripheralCallback:^(CBPeripheral *perpheral) {
        [self.tableView reloadData];
    }];
    [FSBLECenteralService scanDidDisconvered:^(CBPeripheral *perpheral, NSNumber *RSSI) {
        NSInteger index = [_peripheralsDataList indexOfObject:perpheral];
        if (index == NSNotFound) {
            [_peripheralsDataList addObject:perpheral];
        } else {
            [_peripheralsDataList replaceObjectAtIndex:index withObject:perpheral];
        }
        
        objc_setAssociatedObject(perpheral, &AssociatedObjectHandle, RSSI, OBJC_ASSOCIATION_RETAIN);
        [self.tableView reloadData];
    }];
}

- (void)stopScanAndClearPeripheral {
    [FSBLECenteralService stopScan];
    _peripheralsDataList = nil;
    [self.tableView reloadData];                                                              
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
    
    cell.backgroundColor = stateColor;
    cell.textLabel.text = [NSString stringWithFormat:@"RSSI:%@ Name:%@", RSSI, peripheral.name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = _peripheralsDataList[indexPath.row];
    [FSBLECenteralService connectToPeripheral:peripheral];
}
@end
