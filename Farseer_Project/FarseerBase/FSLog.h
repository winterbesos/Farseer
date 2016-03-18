//
//  FSLog.h
//  SLFarseer
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSStorageLogProtocol.h>
#import <FarseerBase_iOS/FSDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSStorageLogProtocol.h>
#import <FarseerBase_OSX/FSDefine.h>
#endif

@interface FSLog : NSObject <FSStorageLogProtocol>

@property (nonatomic, strong)NSDate       *log_date;
@property (nonatomic, assign)FSLogLevel   log_level;
@property (nonatomic, copy)NSString     *log_domain;
@property (nonatomic, strong)NSDictionary *log_info;
@property (nonatomic, copy)NSString     *log_fileName;
@property (nonatomic, copy)NSString     *log_functionName;
@property (nonatomic, assign)UInt32       log_line;

+ (instancetype)createLogWithLevel:(Byte)level domain:(NSString *)domain info:(NSDictionary *)info file:(const char *)file function:(const char *)function line:(unsigned int)line;

@end
