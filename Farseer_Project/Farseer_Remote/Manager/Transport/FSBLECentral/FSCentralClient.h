//
//  FSCentralClient.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDefine.h"
#import "FSCentralClientDelegate.h"

@class CBPeripheral;
@class FSBLELog;

@interface FSCentralClient : NSObject

- (instancetype)initWithDelegate:(id<FSCentralClientDelegate>)delegate;
- (void)requestLogFromLogSequence:(UInt32)sequence callback:(void(^)(FSBLELog *log))callback;

//+ (void)getSandBoxInfoWithPath:(NSString *)path;
//+ (void)getSandBoxFileWithPath:(NSString *)path;
//+ (void)requLogWithLogNumber:(UInt32)logNum;
//+ (void)makePeripheralCrash;

@end
