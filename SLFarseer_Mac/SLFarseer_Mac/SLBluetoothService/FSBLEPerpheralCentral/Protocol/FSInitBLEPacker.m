//
//  FSInitBLEPacker.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSInitBLEPacker.h"
#import "FSPackerProtocol.h"
#import "FSPackageIn.h"
#import "FSPerpheralClient.h"

@interface FSInitBLEPacker () <FSPackerDelegate>

@end

@implementation FSInitBLEPacker

- (void)unpack:(FSPackageIn *)packageIn client:(FSPerpheralClient *)client {
    NSString *osVersion = [packageIn readString];
    NSString *osType = [packageIn readString];
    NSString *deviceType = [packageIn readString];
    NSString *bundleName = [packageIn readString];
    
    [client recvInitBLEWithOSVersion:osVersion osType:osType deviceType:deviceType bundleName:bundleName];
}

@end
