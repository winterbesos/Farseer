//
//  FSDebugCentral.h
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

// 后接可变数量参数一个或者两个，如果是两个的话第二个是相对应的key值，显示到界面上
#define FSVAR()
#define FSOBJ()

/* ************
 * 将所有需要动态调试的变量使用宏FSDVAR(var)或者FSOBJ(obj)来负值
 * ************/

@interface FSDebugCentral : NSObject

+ (void)setup;

+ (void)openBLEDebug:(void(^)(NSError *error))callback;

@end
