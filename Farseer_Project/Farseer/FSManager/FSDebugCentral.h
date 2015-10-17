//
//  FSDebugCentral.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSLogManager;
@class FSTransportManager;
@class FSFileManager;
@class FSOperationManager;

@interface FSDebugCentral : NSObject

@property (nonatomic, readonly)FSLogManager *logManager;
@property (nonatomic, readonly)FSTransportManager *transportManager;
@property (nonatomic, readonly)FSFileManager *fileManager;
@property (nonatomic, readonly)FSOperationManager *operationManager;

+ (FSDebugCentral *)getInstance;

+ (void)closeBLEDebug;
+ (void)openBLEDebug:(void(^)(NSError *error))callback;

@end
