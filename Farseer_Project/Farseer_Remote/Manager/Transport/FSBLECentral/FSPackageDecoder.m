//
//  FSPackerDecoder.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSPackageDecoder.h"
#import "FSBLEDefine.h"

@implementation FSPackageDecoder {
    __weak id<FSPackageDecoderDelegate> _delegate;
    NSMutableData *_packageLoop;
}

- (instancetype)initWithDelegate:(id<FSPackageDecoderDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _packageLoop = [NSMutableData data];
    }
    return self;
}

- (void)pushReceiveData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral {
//    static struct PKG_HEADER *lastHeader = NULL;
    
    struct PKG_HEADER pkg_header;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    [data getBytes:&pkg_header length:headerLen];
    
    NSData *contentData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];
    [_packageLoop appendData:contentData];
    
    if (pkg_header.currentPackage == pkg_header.totalPackage) {
        [_delegate packageDecoder:self didDecodePackageData:_packageLoop fromPeripheral:peripheral cmd:pkg_header.cmd];
        _packageLoop = [NSMutableData data];
    }
}

- (void)clearCache {
    _packageLoop = [NSMutableData data];
}

@end
