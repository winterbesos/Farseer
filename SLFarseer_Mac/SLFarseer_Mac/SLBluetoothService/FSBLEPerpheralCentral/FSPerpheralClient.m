//
//  FSPerpheralClient.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPerpheralClient.h"

@implementation FSPerpheralClient

- (void)recvInitBLEWithOSVersion:(NSString *)osVersion osType:(NSString *)osType deviceType:(NSString *)deviceType bundleName:(NSString *)bundleName {
    NSLog(@"%s: %@ %@ %@ %@", __FUNCTION__, osVersion, osType, deviceType, bundleName);
}

@end
