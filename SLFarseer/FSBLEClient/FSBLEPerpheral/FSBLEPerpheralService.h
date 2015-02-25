//
//  BTCentrelService.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSBLEPerpheralServiceDelegate <NSObject>

@end

@interface FSBLEPerpheralService : NSObject

+ (void)install;

+ (void)updateLogCharacteristicWithLogNum:(Byte)logNum;
+ (void)inputLogToCacheWithNumber:(Byte)number date:(NSDate *)date level:(Byte)level content:(NSString *)content;

@end
