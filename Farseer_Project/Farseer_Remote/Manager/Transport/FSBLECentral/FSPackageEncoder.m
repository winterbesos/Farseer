//
//  FSPackageEncoder.m
//  SLFarseer
//
//  Created by Salo on 15/10/17.
//  Copyright © 2015年 eitdesign. All rights reserved.
//

#import "FSPackageEncoder.h"

@implementation FSPackageEncoder {
    __weak id<FSPackageEncoderDelegate> _delegate;
    NSMutableArray *_packageLoop;
}

- (instancetype)initWithDelegate:(id<FSPackageEncoderDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _packageLoop = [NSMutableArray array];
    }
    return self;
}

- (void)pushDataToSendQueue:(NSData *)originData cmd:(CMD)cmd {
    // embed protocol header
    struct PROTOCOL_HEADER protocolHeader;
    protocolHeader.cmd = cmd;
    NSMutableData *data = [NSMutableData dataWithBytes:&protocolHeader length:sizeof(protocolHeader)];
    if (originData) {
        [data appendData:originData];
    }

    // divide package
    NSMutableArray *pkgGroup = [NSMutableArray array];
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

        // embed package header
        struct PKG_HEADER pkg_header;
        pkg_header.sequId = [self getSeqId];
        pkg_header.lastPackageNumber = pkgCount - 1;
        pkg_header.currentPackageNumber = index;
        NSMutableData *pkgData = [NSMutableData dataWithBytes:&pkg_header length:sizeof(struct PKG_HEADER)];
        [pkgData appendData:originPkgData];
        
        [pkgGroup addObject:pkgData];
    }
    
    [_packageLoop addObject:pkgGroup];
    [_delegate packageEncoderDidPushData:self];
}

- (NSArray *)getTopPackageGroup {
    NSArray *pkgGroup = _packageLoop.firstObject;
    if (pkgGroup) {
        [_packageLoop removeObjectAtIndex:0];
    }
    return pkgGroup;
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
