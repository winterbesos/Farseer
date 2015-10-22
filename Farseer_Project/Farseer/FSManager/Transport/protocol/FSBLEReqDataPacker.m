//
//  FSBLEReqDataPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/2.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEReqDataPacker.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif
#import "FSBLEPeripheralPackerProtocol.h"

@implementation FSBLEReqDataPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id<FSBLEResDelegate>)client {
    NSString *path = [packageIn readString];
    [client recvGetFileWithPath:path];
}

@end
