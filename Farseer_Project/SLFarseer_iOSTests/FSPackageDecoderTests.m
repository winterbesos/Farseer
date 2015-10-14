//
//  FSPackageDecoderTests.m
//  SLFarseer
//
//  Created by Salo on 15/10/13.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "FSPackageDecoder.h"
#import "FSBLECentralService.h"

@interface FSPackageDecoderTests : XCTestCase

@end

@implementation FSPackageDecoderTests {
    id _decoderMock;
    id _decoderDelegateMock;
}

- (void)setUp {
    [super setUp];
  
    id decoderDelegateMock = OCMClassMock([FSBLECentralService class]);
    id decoder = [[FSPackageDecoder alloc] initWithDelegate:decoderDelegateMock];
    OCMockObject *decoderMock = OCMPartialMock(decoder);
    
    _decoderDelegateMock = decoderDelegateMock;
    _decoderMock = decoderMock;
}

- (void)tearDown {
    _decoderMock = nil;
    _decoderDelegateMock = nil;
    [super tearDown];
}

- (void)testSimply {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 0;
    pkg_header.lastPackageNumber = 0;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    OCMVerify([_decoderDelegateMock packageDecoder:[OCMArg any] didDecodePackageData:[OCMArg any] fromPeripheral:[OCMArg any] cmd:1]);
}

- (void)testDecoderExceptionPkgOverflow {
    struct PKG_HEADER pkg_header;
    pkg_header.sequId = -1;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    int maxP1 = ((typeof(pkg_header.currentPackageNumber))-1);
    for (int index = 0; index <= maxP1; index ++) {
        pkg_header.cmd = 1;
        pkg_header.sequId += 1;
        pkg_header.currentPackageNumber = index;
        pkg_header.lastPackageNumber = maxP1;
        NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
        [_decoderMock pushReceiveData:data fromPeripheral:nil];
    }
    
    OCMVerify([_decoderMock clearCache]);
    OCMVerify([_decoderDelegateMock packageDecoder:[OCMArg any] didDecodePackageData:[OCMArg any] fromPeripheral:[OCMArg any] cmd:1]);
}

- (void)testDecoderFirstPackageException {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 8; // verify first pkg
    pkg_header.lastPackageNumber = 0;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    OCMVerify([_decoderMock clearCache]);
}

- (void)testDecoderClearCache {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 0;
    pkg_header.lastPackageNumber = 0;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
}

- (void)testDecoderReceivePackageSeqIdNotCountinuous {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 0;
    pkg_header.lastPackageNumber = 5;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    pkg_header.sequId = 2; // verify seq
    pkg_header.currentPackageNumber = 1;
    data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    OCMVerify([_decoderMock clearCache]);
}

- (void)testDecoderReceivePackageNotCountinuous {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 0;
    pkg_header.lastPackageNumber = 5;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    pkg_header.sequId = 1;
    pkg_header.currentPackageNumber = 2;
    data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    OCMVerify([_decoderMock clearCache]);
}

- (void)testCMDNotEqual {
    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackageNumber = 0;
    pkg_header.lastPackageNumber = 5;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    pkg_header.cmd = 2;
    pkg_header.sequId = 1;
    pkg_header.currentPackageNumber = 1;
    data = [NSData dataWithBytes:&pkg_header length:headerLen];
    [_decoderMock pushReceiveData:data fromPeripheral:nil];
    
    OCMVerify([_decoderMock clearCache]);
}

- (void)testDecoderFirstPackageExceptionAfterClear {
    [self testSimply];
    [self testDecoderFirstPackageException];
}

@end
