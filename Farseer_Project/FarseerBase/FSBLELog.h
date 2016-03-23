//
//  FSBLELog.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSStorageLog.h>
#import <FarseerBase_iOS/FSBLELogProtocol.h>
#import <FarseerBase_iOS/FSDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSStorageLog.h>
#import <FarseerBase_OSX/FSBLELogProtocol.h>
#import <FarseerBase_OSX/FSDefine.h>
#endif

@interface FSBLELog : FSStorageLog <FSBLELogProtocol>

@property (nonatomic)UInt32       sequence;

+ (FSBLELog *)logWithNumber:(UInt32)number date:(NSDate *)date level:(Byte)level content:(NSString *)content file:(NSString *)file function:(NSString *)function line:(UInt32)line;

@end
