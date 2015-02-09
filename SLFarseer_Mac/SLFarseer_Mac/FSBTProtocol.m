//
//  FSBTProtocol.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/7/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBTProtocol.h"

typedef NS_ENUM(NSInteger, FSBTProtocolRecvCMD) {
    FSBTProtocolRecvCMDSingle = 0xA0,
    FSBTProtocolRecvCMDStartLog = 0xA1,
};

typedef NS_ENUM(NSInteger, FSBTProtocolSendCMD) {
    FSBTProtocolSendCMDSingle = 0xB0,
    FSBTProtocolSendCMDSendLog = 0xB1,
};

@implementation FSBTProtocol

#pragma mark - Recv

+ (void)recvSingle {
    
}

#pragma mark - Send

@end
