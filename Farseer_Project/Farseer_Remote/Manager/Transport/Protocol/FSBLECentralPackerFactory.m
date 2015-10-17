//
//  FSBLECentralPackerFactory.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSBLECentralPackerFactory.h"
#import "FSInitBLEPacker.h"
#import "FSBLEResSyncLogPacker.h"
#import "FSBLEResSyncDataPacker.h"
#import "FSBLEResSandInfoPacker.h"
#import "FSBLEResOperationPacker.h"

@implementation FSBLECentralPackerFactory

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
        case CMDResSandBoxInfo:
            packerObj = [[FSBLEResSandInfoPacker alloc] init];
            break;
        case CMDResOperation:
            packerObj = [[FSBLEResOperationPacker alloc] init];
            break;
        default:
            break;
    }
    
    return packerObj;
}


@end
