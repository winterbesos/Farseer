//
//  ViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "OCViewController.h"
#import <SLFarseer/FSLog.h>
#import "FSBLECentralService.h"
#import <objc/runtime.h>
#import <CoreBluetooth/CBPeripheral.h>

#import "FSBLEUtilities.h"

static void *AssociatedObjectHandle;

@interface OCViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *peripheralTableView;

@end

@implementation OCViewController {
    NSMutableArray *_peripheralsDataList;
}

- (void)dealloc {
    [FSBLECentralService uninstall];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FSBLEUtilities getPeripheralInfoData];
    
    FSFatal(@"this is a fatal error [OC]");
    FSError(@"this is a error [OC]");
    FSWarning(@"this is a warning [OC]");
    FSLog(@"this is a log [OC]");
    FSMinor(@"this is a minor log [OC]");
    
    [FSBLECentralService install];
    _peripheralsDataList = [NSMutableArray array];
    [FSBLECentralService setConnectPeripheralCallback:^(CBPeripheral *peripheral) {
        [self.peripheralTableView reloadData];
    }];

    [FSBLECentralService scanDidDisconvered:^(CBPeripheral *perpheral, NSNumber *RSSI) {
        NSInteger index = [_peripheralsDataList indexOfObject:perpheral];
        if (index == NSNotFound) {
            [_peripheralsDataList addObject:perpheral];
        } else {
            [_peripheralsDataList replaceObjectAtIndex:index withObject:perpheral];
        }
        
        objc_setAssociatedObject(perpheral, &AssociatedObjectHandle, RSSI, OBJC_ASSOCIATION_RETAIN);
        [self.peripheralTableView reloadData];
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - NSTableView DataSource and Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _peripheralsDataList.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CBPeripheral *peripheral = _peripheralsDataList[row];
    NSNumber *RSSI = objc_getAssociatedObject(peripheral, &AssociatedObjectHandle);
    NSString *connectStatusString = nil;
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            connectStatusString = @"已连接";
            break;
        case CBPeripheralStateConnecting:
            connectStatusString = @"连接中";
            break;
        case CBPeripheralStateDisconnected:
            connectStatusString = @"未连接";
            break;
        default:
            NSAssert(NO, @"错误的连接类型");
            break;
    }
    
    return [NSString stringWithFormat:@"Name:%@ RSSI:%@ Status:%@", peripheral.name, RSSI, connectStatusString];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    [FSBLECentralService connectToPeripheral:_peripheralsDataList[row]];
    return YES;
}

@end
