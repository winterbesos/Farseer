//
//  Farseer-Plugin.m
//  Farseer-Plugin
//
//  Created by Salo on 15/9/7.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FarseerPlugin.h"
#import <objc/runtime.h>

@interface FarseerPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation FarseerPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:nil object:nil];
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Debug"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
    
}

- (void)getHer {
    NSView *rootView = [NSApp mainWindow].contentView;
    if (rootView) {
        [self showViewHir:rootView dept:0];
    } else {
        BOOL more = YES;
        NSInteger number = 0;
        while (more) {
            NSWindow *window = [[NSApplication sharedApplication] windowWithWindowNumber:number];
            if (window) {
                NSLog(@"@%@", window);
                number++;
            } else {
                more = NO;
            }
            
        }
        
        NSLog(@"@NULL number is : %ld", number);
        NSLog(@"@application is : %@", [NSApplication sharedApplication]);
        [self printAllPropertyWithObject:[NSApplication sharedApplication]];
        
    }
}

- (void)printAllPropertyWithObject:(id)object {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    NSLog(@"@%@", keys);
}

- (void)showViewHir:(NSView *)view dept:(NSUInteger)dept {
    NSMutableString *prefix = [NSMutableString stringWithString:@"@"];
    for (int index = 0; index < dept; index++) {
        [prefix appendString:@"-"];
    }
    NSString *main = [NSString stringWithFormat:@"[%@][%p][%@]", NSStringFromClass([view class]), view, NSStringFromRect(view.frame)];
    NSLog(@"%@ %@", prefix, main);
    
    for (NSView *subView in view.subviews) {
        [self showViewHir:subView dept:dept + 1];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    
    [self getHer];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationLog:(NSNotification *)notif {
    // NSLog(@"%@", notif.name);
}

@end
