//
//  FSRLogDetailViewController.m
//  SLFarseer
//
//  Created by Salo on 16/3/21.
//  Copyright © 2016年 so.salo. All rights reserved.
//

#import "SLRLogDetailViewController.h"
#import <FarseerBase_OSX/FarseerBase_OSX.h>

@interface SLRLogDetailViewController ()

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *logDetail;

@end

@implementation SLRLogDetailViewController

- (void)setupLog:(FSStorageLog *)log {
    self.view.window.title = log.description;
    
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"domain: %@\n\n", log.log_domain];
    
    for (NSString *key in [log.log_info allKeys]) {
        id obj = log.log_info[key];
        NSString *value = nil;
        if ([obj isKindOfClass:[NSString class]]) {
            value = obj;
        } else if ([obj isKindOfClass:[NSData class]]) {
            value = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
        } else {
            value = [obj description];
        }
        
        [content appendFormat:@"%@: %@\n\n", key, value];
    }
    
    self.logDetail.string = content;
}

@end
