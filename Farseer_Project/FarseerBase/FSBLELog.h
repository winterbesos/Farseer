//
//  FSBLELog.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStorageLog.h"
#import "FSBLELogProtocol.h"
#import "FSDefine.h"

@interface FSBLELog : FSStorageLog <FSBLELogProtocol, FSStorageLogProtocol>

@property (nonatomic)UInt32       sequence;

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line;

@end
