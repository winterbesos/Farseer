//
//  Farseer_Remote.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "Farseer_Remote.h"
#import "FSLogManager+Central.h"
#import "FSDebugCentral_Remote.h"

void saveLog(NSArray *logList, CBPeripheral *peripheral, NSString *bundleName, void(^callback)(float percentage)) {
    [[FSDebugCentral_Remote getInstance].logManager saveLog:logList peripheral:peripheral bundleName:bundleName callback:callback];
}
