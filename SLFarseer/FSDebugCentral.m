//
//  FSDebugCentral.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSDebugCentral.h"

static FSDebugCentral *instance = nil;

@implementation FSDebugCentral

+ (void)setup {
    if (!instance) {
        instance = [[FSDebugCentral alloc] init];
    }
}

+ (void)getObjectWithDefaultObject:(id)object {
    NSLog(@"%s, %d", __FILE__, __LINE__);

}

@end
