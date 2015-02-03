//
//  OCViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "OCViewController.h"
#import "FSLog.h"

@interface OCViewController ()

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    FSFatal(@"this is a fatal error [OC]");
    FSError(@"this is a error [OC]");
    FSWarning(@"this is a warning [OC]");
    FSLog(@"this is a log [OC]");
    FSMinor(@"this is a minor log [OC]");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
