//
//  ViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "OCViewController.h"
#import "SLFarseer.h"

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FSFatal(@"this is a fatal error [OC]");
    FSError(@"this is a error [OC]");
    FSWarning(@"this is a warning [OC]");
    FSLog(@"this is a log [OC]");
    FSMinor(@"this is a minor log [OC]");
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
