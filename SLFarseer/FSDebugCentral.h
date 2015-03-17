//
//  FSDebugCentral.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDebugCentral : NSObject

+ (void)setup;
+ (FSDebugCentral *)getInstance;

+ (void)closeBLEDebug;
+ (void)openBLEDebug:(void(^)(NSError *error))callback;

@end
