//
//  ViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "OCViewController.h"
#import <Farseer_Mac/Farseer.h>
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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    openBLEDebug(^(NSError *error) {
        FSLog(@"AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD");
        
        FSLog(@"AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD");
        
        FSLog(@"AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD");
        
        FSLog(@"AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD AAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDDDDD");
    });
    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Actions

- (IBAction)addLogAction:(id)sender {
    FSLog(@"%@", [NSDate date]);
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
//    [FSBLECentralService connectToPeripheral:_peripheralsDataList[row]];
    return YES;
}

@end
