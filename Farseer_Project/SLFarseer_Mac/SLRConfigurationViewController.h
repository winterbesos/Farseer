//
//  ConfigurationViewController.h
//  SLFarseer
//
//  Created by Go Salo on 15/5/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SLRConfigurationViewController;

typedef NS_ENUM(NSInteger, ConfigurationFilterType) {
    ConfigurationFilterTypeNone         =   0,

    ConfigurationFilterTypeFatal        =   0b10000,
    ConfigurationFilterTypeError        =   0b01000,
    ConfigurationFilterTypeWarning      =   0b00100,
    ConfigurationFilterTypeLog          =   0b00010,
    ConfigurationFilterTypeMinor        =   0b00001,
    
    ConfigurationFilterTypeAll          =   0b11111
};

@protocol ConfigurationViewControllerDelegate <NSObject>

- (void)viewController:(SLRConfigurationViewController *)viewController didSelectedFilterType:(ConfigurationFilterType)type;

@end

@interface SLRConfigurationViewController : NSViewController

@property (nonatomic, weak)id<ConfigurationViewControllerDelegate> delegate;

- (void)loadType:(ConfigurationFilterType)type;

@end
