//
//  FSTransportManager.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSPeripheralClient;

@interface FSTransportManager : NSObject

@property (nonatomic, readonly)FSPeripheralClient *peripheralClient;

- (void)openBLEDebug:(void(^)(NSError *error))callback;
- (void)closeBLEDebug;

@end
