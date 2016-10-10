//
//  FSBLEReqSendBoxInfoPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEReqSandBoxInfoPacker.h"
#import "FSBLEPeripheralPackerProtocol.h"
#import "FSBLEDefine.h"

@implementation FSBLEReqSandBoxInfoPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id<FSBLEResDelegate>)client {
    NSString *path = [packageIn readString];
    [client recvGetSendBoxInfoWithPath:path];
}


@end
