//
//  NSDictionary+Contents.m
//  SLAppCoreUtil
//
//  Created by Salo on 16/3/1.
//  Copyright © 2016年 Salo. All rights reserved.
//

#import "NSDictionary+Contents.h"

@implementation NSDictionary (Contents)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    CFPropertyListRef list = CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL, NULL);
    if (list == nil) return nil;
    
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *)list;
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        return dictionary;
    } else {
        return nil;
    }
}

- (NSData *)plistData {
    CFDataRef data = CFPropertyListCreateData(kCFAllocatorDefault, (__bridge CFPropertyListRef)self, kCFPropertyListXMLFormat_v1_0, kCFPropertyListImmutable, NULL);
    
    return (__bridge_transfer NSData *)data;
}

@end
