//
//  FSPackageEncoder.m
//  SLFarseer
//
//  Created by Salo on 15/10/17.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "FSPackageEncoder.h"
#import <FarseerBase_iOS/FarseerBase_iOS.h>

@implementation FSPackageEncoder

- (void)pushRequestData:(NSData *)data cmd:(CMD)cmd {
    
    struct PKG_HEADER header;
    header.cmd = CMDReqLogging;
    header.currentPackageNumber = 1;
    header.lastPackageNumber = 1;
    header.sequId = 0;
    
    NSMutableData *requestData = [NSMutableData dataWithBytes:&header length:sizeof(struct PKG_HEADER)];
    [requestData appendBytes:&sequence length:sizeof(sequence)];
    
    
    
//    // parse data
//    struct PKG_HEADER pkg_header;
//    NSUInteger headerLen = sizeof(struct PKG_HEADER);
//    [data getBytes:&pkg_header length:headerLen];
//    
//    // exception judge
//    if ((_lastHeader == NULL && pkg_header.currentPackageNumber != 0) // the first pkg verify
//        ||
//        (_lastHeader != NULL && (pkg_header.currentPackageNumber != _lastHeader->currentPackageNumber + 1)) // not the first pkg verify
//        ||
//        (_lastHeader != NULL && pkg_header.cmd != _lastHeader->cmd) // not equal cmd
//        ||
//        (_lastHeader != NULL && pkg_header.sequId != _lastHeader->sequId + 1) // seq not countinuous
//        ) {
//        if (_lastHeader) {
//            NSLog(@"exception last package: %@ >> current package: %@", NSStringFromPKG_Header(_lastHeader), NSStringFromPKG_Header(&pkg_header));
//        } else {
//            NSLog(@"exception first package: %@", NSStringFromPKG_Header(&pkg_header));
//        }
//        [self clearCache];
//        return NO;
//    }
//    
//    _lastHeader = (struct PKG_HEADER *)malloc(sizeof(struct PKG_HEADER));
//    memcpy(_lastHeader, &pkg_header, sizeof(struct PKG_HEADER));
//    
//    // normal
//    NSData *contentData = [data subdataWithRange:NSMakeRange(headerLen, data.length - headerLen)];
//    [_packageLoop appendData:contentData];
//    
//    if (pkg_header.currentPackageNumber == pkg_header.lastPackageNumber) {
//        FSPackageIn *packageIn = [FSPackageIn decode:data];
//        [[FSBLECentralPackerFactory getObjectWithCMD:pkg_header.cmd] unpack:packageIn client:_client peripheral:peripheral];
//        [self clearCache];
//    }
}

@end
