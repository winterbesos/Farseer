//
//  SLLogWrapper.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;
@class FSBLELogInfo;
@protocol SLLogWrapperDelegate;

@interface SLLogWrapper : NSObject

- (instancetype)initWithLogInfo:(FSBLELogInfo *)info;
- (void)insertLog:(FSBLELog *)log;
- (NSArray *)registerLogWithDelegate:(id<SLLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName;
- (NSArray *)registerKeyWithDelegate:(id<SLLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName;
- (void)writeToFileCallback:(void(^)(float percentage))callback;

@end

@protocol SLLogWrapperDelegate <NSObject>

- (void)wrapper:(SLLogWrapper *)wrapper didInsertLog:(FSBLELog *)log;

@end
