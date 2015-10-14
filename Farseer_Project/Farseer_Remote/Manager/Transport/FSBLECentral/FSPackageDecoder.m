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
    struct PKG_HEADER *_lastHeader;
}

- (instancetype)initWithDelegate:(id<FSPackageDecoderDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _packageLoop = [NSMutableData data];
    }
    return self;
}

- (BOOL)pushReceiveData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral {
    // parse data
    struct PKG_HEADER pkg_header;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    [data getBytes:&pkg_header length:headerLen];
    
    // exception judge
    if ((_lastHeader == NULL && pkg_header.currentPackageNumber != 0) // the first pkg verify
        ||
        (_lastHeader != NULL && (pkg_header.currentPackageNumber != _lastHeader->currentPackageNumber + 1)) // not the first pkg verify
        ||
        (_lastHeader != NULL && pkg_header.cmd != _lastHeader->cmd) // not equal cmd
        ||
        (_lastHeader != NULL && pkg_header.sequId != _lastHeader->sequId + 1) // seq not countinuous
        ) {
        if (_lastHeader) {
            NSLog(@"exception last package: %@ >> current package: %@", NSStringFromPKG_Header(_lastHeader), NSStringFromPKG_Header(&pkg_header));
        } else {
            NSLog(@"exception first package: %@", NSStringFromPKG_Header(&pkg_header));
        }
        [self clearCache];
        return NO;
    }
    
    [_delegate packageDecoder:self didDecodePackageDataProgress:(pkg_header.currentPackageNumber / (float)pkg_header.lastPackageNumber) fromPeripheral:peripheral cmd:pkg_header.cmd];
#if DEBUG
    NSLog(@"progress: %hu/%hu", pkg_header.currentPackageNumber, pkg_header.lastPackageNumber);
#endif
    
    _lastHeader = (struct PKG_HEADER *)malloc(sizeof(struct PKG_HEADER));
    memcpy(_lastHeader, &pkg_header, sizeof(struct PKG_HEADER));
    
    // normal
    NSData *contentData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];
    [_packageLoop appendData:contentData];
    
    if (pkg_header.currentPackageNumber == pkg_header.lastPackageNumber) {
        [_delegate packageDecoder:self didDecodePackageData:_packageLoop fromPeripheral:peripheral cmd:pkg_header.cmd];
        [self clearCache];
    }
    return YES;
}

- (void)clearCache {
    if (_packageLoop.length) {
        _packageLoop = [NSMutableData data];
    }
    _lastHeader = NULL;
}


NSString * NSStringFromPKG_Header(struct PKG_HEADER *header) {
    return [NSString stringWithFormat:@"CMD: %X SeqId: %X current: %X last: %X", header->cmd, header->sequId, header->currentPackageNumber, header->lastPackageNumber];
}

@end
