//
//  FSBLEReqSendBoxInfoPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEReqSandBoxInfoPacker.h"
#import "FSBLEPeripheralPackerProtocol.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLEDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLEDefine.h>
#endif

@implementation FSBLEReqSandBoxInfoPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id<FSBLEResDelegate>)client {
    NSString *path = [packageIn readString];
    [client recvGetSendBoxInfoWithPath:path];
}


@end
