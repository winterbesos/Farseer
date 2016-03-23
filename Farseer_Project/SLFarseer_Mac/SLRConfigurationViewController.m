//
//  ConfigurationViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/5/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "SLRConfigurationViewController.h"

@interface SLRConfigurationViewController ()

@property (weak) IBOutlet NSButton *filterAllCheckBox;
@property (weak) IBOutlet NSButton *filterFatalCheckBox;
@property (weak) IBOutlet NSButton *filterErrorCheckBox;
@property (weak) IBOutlet NSButton *filterWarningCheckBox;
@property (weak) IBOutlet NSButton *filterLogCheckBox;
@property (weak) IBOutlet NSButton *filterMinorCheckBox;

@end

@implementation SLRConfigurationViewController

#pragma mark - Public Method

- (void)loadType:(ConfigurationFilterType)type {
    self.filterFatalCheckBox.state = type & ConfigurationFilterTypeFatal;
    self.filterErrorCheckBox.state = type & ConfigurationFilterTypeError;
    self.filterWarningCheckBox.state = type & ConfigurationFilterTypeWarning;
    self.filterLogCheckBox.state = type & ConfigurationFilterTypeLog;
    self.filterMinorCheckBox.state = type & ConfigurationFilterTypeMinor;
    self.filterAllCheckBox.state = (type == ConfigurationFilterTypeAll);
}

#pragma mark - Actions

- (IBAction)filterCheckBox:(NSButton *)sender {
    if ([sender.title isEqualToString:@"All"]) {
        if (sender.state == NSOnState) {
            self.filterFatalCheckBox.state = NSOnState;
            self.filterErrorCheckBox.state = NSOnState;
            self.filterWarningCheckBox.state = NSOnState;
            self.filterLogCheckBox.state = NSOnState;
            self.filterMinorCheckBox.state = NSOnState;
        } else {
            self.filterFatalCheckBox.state = NSOffState;
            self.filterErrorCheckBox.state = NSOffState;
            self.filterWarningCheckBox.state = NSOffState;
            self.filterLogCheckBox.state = NSOffState;
            self.filterMinorCheckBox.state = NSOffState;
        }
    } else {
        if (self.filterFatalCheckBox.state
            &&
            self.filterErrorCheckBox.state
            &&
            self.filterWarningCheckBox.state
            &&
            self.filterLogCheckBox.state
            &&
            self.filterMinorCheckBox.state) {
            self.filterAllCheckBox.state = NSOnState;
        } else {
            self.filterAllCheckBox.state = NSOffState;
        }
    }
    
    ConfigurationFilterType type = (self.filterFatalCheckBox.state << 4
                                    |
                                    self.filterErrorCheckBox.state << 3
                                    |
                                    self.filterWarningCheckBox.state << 2
                                    |
                                    self.filterLogCheckBox.state << 1
                                    |
                                    self.filterMinorCheckBox.state);
    
    if ([self.delegate respondsToSelector:@selector(viewController:didSelectedFilterType:)]) {
        [self.delegate viewController:self didSelectedFilterType:type];
    }
}

@end
