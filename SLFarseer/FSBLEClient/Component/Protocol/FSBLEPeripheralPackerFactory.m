//
//  FSPackerFactory.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSBLEPeripheralPackerFactory.h"

#import "FSInitBLEPacker.h"

#import "FSBLEReqSyncLogPacker.h"
#import "FSBLEResSyncLogPacker.h"

#import "FSBLEResSyncDataPacker.h"

@implementation FSBLEPeripheralPackerFactory

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
