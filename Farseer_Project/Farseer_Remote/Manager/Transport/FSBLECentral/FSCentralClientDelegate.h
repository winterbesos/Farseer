//
//  FSCentralClientDelegate.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLELogProtocol.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLELogProtocol.h>
#endif

@class FSCentralClient;
@class FSBLELogInfo;
@class FSBLELog;

@protocol FSCentralClientDelegate <NSObject>

@optional
- (void)client:(FSCentralClient *)client didReceiveLogInfo:(FSBLELogInfo *)logInfo;
- (void)client:(FSCentralClient *)client didReceiveLog:(id<FSBLELogProtocol>)log;
- (void)client:(FSCentralClient *)client didReceiveSandBoxInfo:(NSDictionary *)sandBoxInfo;
- (void)client:(FSCentralClient *)client didReceiveOperation:(NSData *)operationData;

@end
