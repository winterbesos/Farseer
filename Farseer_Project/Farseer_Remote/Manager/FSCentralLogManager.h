//
//  FSLogManager+Central.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;
@class FSBLELog;
@class FSBLELogInfo;

typedef NS_ENUM(NSInteger, FSLogCategory) {
    FSLogCategoryFile,
    FSLogCategoryFunction,
    FSLogCategoryLine
};

@interface FSCentralLogManager : NSObject

- (void)setupCacheWithInfo:(FSBLELogInfo *)logInfo;
- (void)cacheLog:(FSBLELog *)log;
- (void)clearCache;

- (void)requestLog;
- (void)saveLogCallback:(void(^)(float percentage))callback;

@end
