//
//  FSPackerFactory.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackerFactory.h"

#import "FSInitBLEPacker.h"
#import "FSBLEResSyncLogPacker.h"
#import "FSBLEReqSyncLogPacker.h"

@implementation FSPackerFactory

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd {
    id packerObj = nil;
    switch (cmd) {
        case CMDCPInit:
            packerObj = [[FSInitBLEPacker alloc] init];
            break;
        case CMDCPLoggingACK:
            
            break;
        case CMDPCInit:
            
            break;
        case CMDRecLogging:
            packerObj = [[FSBLEResSyncLogPacker alloc] init];
            break;
        case CMDReqLogging:
            packerObj = [[FSBLEReqSyncLogPacker alloc] init];
            break;
        default:
            break;
    }
    
    return packerObj;
}

@end
