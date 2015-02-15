//
//  FSPerpheralClient.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPerpheralClient : NSObject

- (void)recvInitBLEWithOSVersion:(NSString *)osVersion osType:(NSString *)osType deviceType:(NSString *)deviceType bundleName:(NSString *)bundleName;

@end