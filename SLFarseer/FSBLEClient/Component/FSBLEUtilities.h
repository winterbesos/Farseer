//
//  FSBLEUtilities.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBLEUtilities : NSObject

+ (NSData *)getPeripheralInfoData;
+ (NSData *)getLogDataWithNumber:(Byte)number date:(NSDate *)date level:(Byte)level content:(NSString *)content;
+ (NSData *)getReqLogWithNumber:(Byte)number;

@end