//
//  NSString+FSBLECatetory.m
//  SLFarseer
//
//  Created by Salo on 15/10/23.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "NSString+FSBLECatetory.h"

@implementation NSString (FSBLECatetory)

- (NSData *)SLEncodeData {
    NSData *bodyData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    UInt32 len = (UInt32)bodyData.length;
    NSMutableData *pkgData = [NSMutableData dataWithBytes:&len length:sizeof(len)];
    [pkgData appendData:bodyData];
    
    return pkgData;
}

@end
