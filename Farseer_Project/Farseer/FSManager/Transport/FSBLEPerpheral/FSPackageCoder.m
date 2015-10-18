//
//  FSPackageCoder.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSPackageCoder.h"
#import "FSBLEDefine.h"
#import <objc/runtime.h>

static char characteristicAssociatedHandle;

@implementation FSPackageCoder {
    __weak id<FSPackageCoderDelegate> _delegate;
    NSMutableArray *_packageLoop;
}

- (instancetype)initWithDelegate:(id<FSPackageCoderDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _packageLoop = [NSMutableArray array];
    }
    return self;
}

- (void)pushDataToSendQueue:(NSData *)originData characteristic:(CBMutableCharacteristic *)characteristic cmd:(CMD)cmd {
    // protocol header
    struct PROTOCOL_HEADER protocolHeader;
    protocolHeader.cmd = cmd;
    NSMutableData *data = [NSMutableData dataWithBytes:&protocolHeader length:sizeof(protocolHeader)];
    [data appendData:originData];
    NSMutableArray *pkgs = [NSMutableArray array];
    NSUInteger pkgCount = data.length / MAX_PACKAGE_DATA_SIZE + (data.length % MAX_PACKAGE_DATA_SIZE == 0 ? 0 : 1);
   
    static struct PKG_HEADER egHeader;
    int max = ((typeof(egHeader.currentPackageNumber))-1);
    if (pkgCount > max) {
        NSLog(@"too larg package beyond the max limit");
        return;
    }
    
    for (int index = 0; index < pkgCount; index++) {
        NSUInteger pkgLength;
        if (data.length > (index + 1) * MAX_PACKAGE_DATA_SIZE) {
            pkgLength = MAX_PACKAGE_DATA_SIZE;
        } else {
            pkgLength = data.length - index * MAX_PACKAGE_DATA_SIZE;
        }
        
        NSData *originPkgData = [data subdataWithRange:NSMakeRange(index * MAX_PACKAGE_DATA_SIZE, pkgLength)];
        
        // add header
        struct PKG_HEADER pkg_header;
        pkg_header.sequId = [self getSeqId];
        pkg_header.lastPackageNumber = pkgCount - 1;
        pkg_header.currentPackageNumber = index;
        
        NSMutableData *pkgData = [NSMutableData dataWithBytes:&pkg_header length:sizeof(struct PKG_HEADER)];
        [pkgData appendData:originPkgData];
        
        objc_setAssociatedObject(pkgData, &characteristicAssociatedHandle, characteristic, OBJC_ASSOCIATION_RETAIN);
        
        [pkgs addObject:pkgData];
    }
    
    NSUInteger count = _packageLoop.count;
    [_packageLoop addObjectsFromArray:pkgs];
    if (count == 0) {
        [_delegate didPushPackageToEmptyPackageLoopPackageCoder:self];
    }
}


- (void)getPackageToSendWithBlock:(FSPackageCorderGetPackageBlock)block {
    NSData *pkgData = _packageLoop.firstObject;
    CBMutableCharacteristic *associatedCharacteristic = objc_getAssociatedObject(pkgData, &characteristicAssociatedHandle);
    
    if (pkgData) {
        block(pkgData, associatedCharacteristic);
    }
}

- (void)removeSendedPackage {
    if (_packageLoop.count) {
        [_packageLoop removeObjectAtIndex:0];
    }
}

- (void)clearCache {
    [_packageLoop removeAllObjects];
}

#pragma mark - Private Method

- (UInt32)getSeqId {
    @synchronized(self) {
        static unsigned int seqId = 0;
        return seqId++;
    }
}

@end
