//
//  Farseer-Plugin.h
//  Farseer-Plugin
//
//  Created by Salo on 15/9/7.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <AppKit/AppKit.h>

@class FarseerPlugin;

static FarseerPlugin *sharedPlugin;

@interface FarseerPlugin : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end