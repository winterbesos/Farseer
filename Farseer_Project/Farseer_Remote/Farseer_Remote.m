//
//  Farseer_Remote.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "Farseer_Remote.h"
#import "FSCentralLogManager.h"
#import "FSDebugCentral_Remote.h"

void requestLog() {
    [[FSDebugCentral_Remote getInstance].logManager requestLog];
}

void saveLog(void(^callback)(float percentage)) {
    [[FSDebugCentral_Remote getInstance].logManager saveLogCallback:callback];
}

void makeCrash() {
    [[FSDebugCentral_Remote getInstance].logManager makePeripheralCrash];
}
