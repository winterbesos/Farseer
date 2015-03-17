//
//  FSBLEBaseReqPacker.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/17.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEBaseReqPacker.h"

@implementation FSBLEBaseReqPacker

- (instancetype)initWithRequest:(CBATTRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

@end
