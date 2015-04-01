//
//  FSPackerFactory.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSBLEPeripheralPackerFactory.h"

#import "FSBLEReqSyncLogPacker.h"
#import "FSBLEReqSandBoxInfoPacker.h"

@implementation FSBLEPeripheralPackerFactory

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd request:(CBATTRequest *)request {
    id packerObj = nil;
    switch (cmd) {
        case CMDReqLogging:
            packerObj = [[FSBLEReqSyncLogPacker alloc] initWithRequest:request];
            break;
        case CMDReqData:
            break;
        case CMDReqSandBoxInfo:
            packerObj = [[FSBLEReqSandBoxInfoPacker alloc] initWithRequest:request];
            break;
        default:
            break;
    }
    
    return packerObj;
}

@end
