//
//  FSBLELog.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBLELog : NSObject

@property (nonatomic, assign, readonly)UInt32       log_number;
@property (nonatomic, strong, readonly)NSDate     *log_date;
@property (nonatomic, assign, readonly)Byte       log_level;
@property (nonatomic, copy, readonly)NSString     *log_content;

+ (FSBLELog *)createLogWithLevel:(Byte)level content:(NSString *)content;
+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content;

- (NSData *)dataValue;

@end
