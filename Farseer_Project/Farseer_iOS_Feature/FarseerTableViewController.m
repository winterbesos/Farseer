//
//  FarseerTableViewController.m
//  testapp
//
//  Created by Go Salo on 15/7/10.
//  Copyright (c) 2015年 eitdesign. All rights reserved.
//

#import "FarseerTableViewController.h"

@interface FarseerTableViewController ()

@end

@implementation FarseerTableViewController

- (void)setResponseLongPressPeepUI:(BOOL)on {
    static UILongPressGestureRecognizer *longPress = nil;
    if (!longPress) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressKeyWindow:)];
        longPress.minimumPressDuration = 3;
    }
    
    if (on) {
        [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:longPress];
    } else {
        [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:longPress];
    }
}

#pragma mark - Actions

- (void)longPressKeyWindow:(UILongPressGestureRecognizer *)gesture {
    NSLog(@"%s", __FUNCTION__);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self loadViewInfo];
    }
}

- (IBAction)UIPeepSwitchAction:(UISwitch *)sender {
    [self setResponseLongPressPeepUI:sender.on];
}

#pragma mark - Load Info

- (void)loadViewInfo {
    NSLog(@"%s", __FUNCTION__);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self recursiveLoadSubviewInfo:window level:0];
}

- (void)recursiveLoadSubviewInfo:(UIView *)view level:(NSUInteger)level {
    NSLog(@"%s level: %ld", __FUNCTION__, (long)level);
    // print self current view info
    [self printViewInfo:view level:level];
    
    // recuresive subview
    for (UIView *subview in view.subviews) {
        [self recursiveLoadSubviewInfo:subview level:level + 1];
    }
}

- (void)printViewInfo:(UIView *)view level:(NSUInteger)level {
    NSMutableString *header = [NSMutableString string];
    for (int index = 0; index < level; index ++) {
        [header appendString:@"    "];
    }
    
    NSLog(@"%@%@", header, view);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}

@end
