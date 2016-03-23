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

    ConfigurationFilterTypeFatal        =   1 << 4,
    ConfigurationFilterTypeError        =   1 << 3,
    ConfigurationFilterTypeWarning      =   1 << 2,
    ConfigurationFilterTypeLog          =   1 << 1,
    ConfigurationFilterTypeMinor        =   1,
    
    ConfigurationFilterTypeAll          =   0b11111
};

@protocol ConfigurationViewControllerDelegate <NSObject>

- (void)viewController:(SLRConfigurationViewController *)viewController didSelectedFilterType:(ConfigurationFilterType)type;

@end

@interface SLRConfigurationViewController : NSViewController

@property (nonatomic, weak)id<ConfigurationViewControllerDelegate> delegate;

- (void)loadType:(ConfigurationFilterType)type;

@end
