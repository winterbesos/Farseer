//
//  FSPackageCoder.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"

@class CBMutableCharacteristic;
@class FSPackageCoder;

typedef void(^FSPackageCorderGetPackageBlock)(NSData *data, CBMutableCharacteristic *characteristic);

@protocol FSPackageCoderDelegate <NSObject>

- (void)didPushPackageToEmptyPackageLoopPackageCoder:(FSPackageCoder *)packageCoder;

@end

@interface FSPackageCoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageCoderDelegate>)delegate;

- (void)pushDataToSendQueue:(NSData *)data characteristic:(CBMutableCharacteristic *)characteristic cmd:(CMD)cmd;
- (void)getPackageToSendWithBlock:(FSPackageCorderGetPackageBlock)block;
- (void)removeSendedPackage; // 接收到Ack时Remove

- (void)clearCache;

@end
