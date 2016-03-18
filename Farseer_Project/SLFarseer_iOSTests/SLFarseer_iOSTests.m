//
//  SLFarseer_iOSTests.m
//  SLFarseer_iOSTests
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <FarseerBase_iOS/FarseerBase_iOS.h>
#import <Farseer_iOS/Farseer_iOS.h>

@interface SLFarseer_iOSTests : XCTestCase

@end

@implementation SLFarseer_iOSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncoderAndDecoder {
    NSDate *date = [NSDate date];
    FSBLELog *log = [FSBLELog logWithNumber:0 date:date level:1 content:@"content" file:@"file" function:@"function" line:10];
    NSData *data = [log BLETransferEncode];
    
    FSBLELog *log2 = [[FSBLELog alloc] init];
    [log2 BLETransferDecodeWithData:data];
}

- (void)testExample {

    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
