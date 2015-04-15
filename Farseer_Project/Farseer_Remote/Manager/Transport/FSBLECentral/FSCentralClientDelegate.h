//
//  FSCentralClientDelegate.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSCentralClient;
@class FSBLELogInfo;
@class FSBLELog;

@protocol FSCentralClientDelegate <NSObject>

- (void)client:(FSCentralClient *)client didReceiveLogInfo:(FSBLELogInfo *)logInfo;
- (void)client:(FSCentralClient *)client didReceiveLog:(FSBLELog *)log;

@end
