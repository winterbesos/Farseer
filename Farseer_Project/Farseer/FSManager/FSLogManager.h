//
//  FSLogManager.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSBLELog;
@class CBPeripheral;

@interface FSLogManager : NSObject {
    NSString         *kLifeCircleLogPath; // 当前生命周期log文件路径
    dispatch_queue_t logFileOperationQueue;
    NSMutableArray   *cacheLogs;
}

@end
