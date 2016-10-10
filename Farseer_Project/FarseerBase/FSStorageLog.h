//
//  FSLog.h
//  SLFarseer
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStorageLogProtocol.h"
#import "FSDefine.h"

@interface FSStorageLog : NSObject <FSStorageLogProtocol>

@property (nonatomic, strong)NSDate       *log_date;
@property (nonatomic, assign)FSLogLevel   log_level;
@property (nonatomic, copy)NSString     *log_domain;
@property (nonatomic, strong)NSDictionary *log_info;
@property (nonatomic, copy)NSString     *log_fileName;
@property (nonatomic, copy)NSString     *log_functionName;
@property (nonatomic, assign)UInt32       log_line;

+ (instancetype)createLogWithLevel:(Byte)level domain:(NSString *)domain info:(NSDictionary *)info file:(const char *)file function:(const char *)function line:(unsigned int)line;

@end
