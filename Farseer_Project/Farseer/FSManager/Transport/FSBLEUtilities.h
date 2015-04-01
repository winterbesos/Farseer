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
+ (NSData *)getReqLogWithNumber:(UInt32)number;
+ (NSData *)getDataWithPkgString:(NSString *)string;
+ (NSData *)getReqSendBoxInfoWithData:(NSData *)data;
@end
