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

#define kFARSEER_SEND_LOG_TO_EMAIL_ADDRESS @"2680914103@qq.com"
#define kFARSEER_SEND_LOG_TO_EMAIL_SUBJECT @"Farseer Log fsl Documents"

void requestLog() {
    [[FSDebugCentral_Remote getInstance].logManager requestLog];
}

void saveLog(void(^callback)(float percentage)) {
    [[FSDebugCentral_Remote getInstance].logManager saveLogCallback:callback];
}

void makeCrash() {
    [[FSDebugCentral_Remote getInstance].logManager makePeripheralCrash];
}

void sendLogThroughEmail() {
    [[FSDebugCentral_Remote getInstance].logManager sendLogToEmailToAddress:kFARSEER_SEND_LOG_TO_EMAIL_ADDRESS withSubject:kFARSEER_SEND_LOG_TO_EMAIL_SUBJECT attachments:@[]];
}
