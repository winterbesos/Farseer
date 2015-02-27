//
//  BTCentrelService.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;

@protocol FSBLEPerpheralServiceDelegate <NSObject>

@end

@interface FSBLEPerpheralService : NSObject

+ (void)install:(void(^)(NSError *error))callback;
+ (void)uninstall;

+ (void)inputLogToCacheWithLog:(FSBLELog *)log;

@end
