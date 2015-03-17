//
//  FSPackerFactory.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackerFactory.h"

#import "FSInitBLEPacker.h"

#import "FSBLEReqSyncLogPacker.h"
#import "FSBLEResSyncLogPacker.h"

#import "FSBLEResSyncDataPacker.h"

@implementation FSPackerFactory

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd {
    id packerObj = nil;
    switch (cmd) {
        case CMDCPInit:
            packerObj = [[FSInitBLEPacker alloc] init];
            break;
        case CMDResLogging:
            packerObj = [[FSBLEResSyncLogPacker alloc] init];
            break;
        case CMDResData:
            packerObj = [[FSBLEResSyncDataPacker alloc] init];
            break;
        default:
            break;
    }
    
    return packerObj;
}

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd request:(CBATTRequest *)request {
    id packerObj = nil;
    switch (cmd) {
        case CMDReqLogging:
            packerObj = [[FSBLEReqSyncLogPacker alloc] initWithRequest:request];
            break;
        case CMDReqData:
            break;
        default:
            break;
    }
    
    return packerObj;
}

@end
