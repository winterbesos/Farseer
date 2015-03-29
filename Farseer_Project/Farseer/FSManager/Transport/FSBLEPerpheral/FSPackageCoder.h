//
//  FSPackageCoder.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBMutableCharacteristic;
@class FSPackageCoder;

typedef void(^FSPackageCorderGetPackageBlock)(NSData *data, CBMutableCharacteristic *characteristic);

@protocol FSPackageCoderDelegate <NSObject>

- (void)didPushPackageToEmptyPackageLoopPackageCoder:(FSPackageCoder *)packageCoder;

@end

@interface FSPackageCoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageCoderDelegate>)delegate;

- (void)pushDataToSendQueue:(NSData *)data characteristic:(CBMutableCharacteristic *)characteristic;
- (void)getPackageToSendWithBlock:(FSPackageCorderGetPackageBlock)block;
- (void)removeSendedPackage;

@end
