//
//  FSPackerDecoder.m
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSPackageDecoder.h"
#import "FSBLEDefine.h"
#import "FSCentralClientDelegate.h"
#import "FSBLECentralPackerFactory.h"
#import "FSCentralClient.h"

@implementation FSPackageDecoder {
    FSCentralClient *_client;
    NSMutableData *_packageLoop;
    struct PKG_HEADER *_lastHeader;
}

- (instancetype)initWithDelegate:(id<FSCentralClientDelegate>)delegate {
    self = [super init];
    if (self) {
        _packageLoop = [NSMutableData data];
        _client = [[FSCentralClient alloc] initWithDelegate:delegate];
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
    
    _lastHeader = (struct PKG_HEADER *)malloc(sizeof(struct PKG_HEADER));
    memcpy(_lastHeader, &pkg_header, sizeof(struct PKG_HEADER));
    
    // normal
    NSData *contentData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];
    [_packageLoop appendData:contentData];
    
    if (pkg_header.currentPackageNumber == pkg_header.lastPackageNumber) {
        FSPackageIn *packageIn = [FSPackageIn decode:data];
        [[FSBLECentralPackerFactory getObjectWithCMD:pkg_header.cmd] unpack:packageIn client:_client peripheral:peripheral];
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
    return [NSString stringWithFormat:@"CMD: %X SeqId: %X current: %X last: %X", header->cmd, (unsigned int)header->sequId, header->currentPackageNumber, header->lastPackageNumber];
}

@end
