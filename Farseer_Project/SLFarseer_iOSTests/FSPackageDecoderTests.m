//
//  FSPackageDecoderTests.m
//  SLFarseer
//
//  Created by Salo on 15/10/13.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSPackageDecoder.h"

@interface FSPackageDecoderTests : XCTestCase

@end

@implementation FSPackageDecoderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDecoder {
    FSPackageDecoder *decoder = [[FSPackageDecoder alloc] initWithDelegate:nil];

    struct PKG_HEADER pkg_header;
    pkg_header.cmd = 1;
    pkg_header.sequId = 0;
    pkg_header.currentPackage = 0;
    pkg_header.totalPackage = 10;
    NSUInteger headerLen = sizeof(struct PKG_HEADER);
    NSData *data = [NSData dataWithBytes:&pkg_header length:headerLen];

    [decoder pushReceiveData:data fromPeripheral:nil];
}

@end
