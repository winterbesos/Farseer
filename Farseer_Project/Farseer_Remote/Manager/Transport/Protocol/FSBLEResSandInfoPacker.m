//
//  FSBLEResSandInfoPacker.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLEResSandInfoPacker.h"
#import "FSBLECentralPackerProtocol.h"
#import "FSCentralClient.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSPackageIn.h>
#endif

@implementation FSBLEResSandInfoPacker

- (void)unpack:(FSPackageIn *)packageIn client:(id)client peripheral:(CBPeripheral *)peripheral {
    
    NSData *data = [packageIn readData];
    NSDictionary *sendBoxInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [client recvSendBoxInfo:sendBoxInfo];
}


@end
