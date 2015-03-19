//
//  Farseer_Remote.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface Farseer_Remote : NSObject

void saveLog(NSArray *logList, CBPeripheral *peripheral, NSString *bundleName, void(^callback)(float percentage));

@end
