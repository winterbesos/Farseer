//
//  FSLogWrapper.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;
@class FSBLELogInfo;
@protocol FSLogWrapperDelegate;

@interface FSLogWrapper : NSObject

- (instancetype)initWithLogInfo:(FSBLELogInfo *)info;
- (void)insertLog:(FSBLELog *)log;
- (NSArray *)registerLogWithDelegate:(id<FSLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName;
- (NSArray *)registerKeyWithDelegate:(id<FSLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName;
- (void)writeToFileCallback:(void(^)(float percentage))callback;

@end

@protocol FSLogWrapperDelegate <NSObject>

- (void)wrapper:(FSLogWrapper *)wrapper didInsertLog:(FSBLELog *)log;

@end
