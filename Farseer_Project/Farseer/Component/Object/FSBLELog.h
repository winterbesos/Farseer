//
//  FSBLELog.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDefine.h"

@interface FSBLELog : NSObject

@property (nonatomic, assign, readonly)UInt32       log_number;
@property (nonatomic, strong, readonly)NSDate       *log_date;
@property (nonatomic, assign, readonly)FSLogLevel   log_level;
@property (nonatomic, copy, readonly)NSString       *log_content;
@property (nonatomic, copy, readonly)NSString       *log_fileName;
@property (nonatomic, copy, readonly)NSString       *log_functionName;
@property (nonatomic, assign, readonly)UInt32       log_line;

+ (FSBLELog *)createLogWithLevel:(Byte)level content:(NSString *)content file:(const char *)file function:(const char *)function line:(unsigned int)line;
+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line;

- (NSData *)dataValue;

@end
