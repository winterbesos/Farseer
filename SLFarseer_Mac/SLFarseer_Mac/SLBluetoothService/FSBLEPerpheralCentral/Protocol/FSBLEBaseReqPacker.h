//
//  FSBLEBaseReqPacker.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBATTRequest;

@interface FSBLEBaseReqPacker : NSObject

@property (nonatomic, readonly)CBATTRequest *request;

- (instancetype)initWithRequest:(CBATTRequest *)request;

@end
