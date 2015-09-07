//
//  NSObject_Extension.m
//  Farseer-Plugin
//
//  Created by Salo on 15/9/7.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//


#import "NSObject_Extension.h"
#import "FarseerPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[FarseerPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
