//
//  Farseer_iOSTests.m
//  Farseer_iOSTests
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 Qeekers. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Farseer_Mac/Farseer_Mac.h>

@interface Farseer_iOSTests : XCTestCase

@end

@implementation Farseer_iOSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    FSMinor(@"minor 123");
    
    FSLog(@"log 345");
    
    FSError(112, @"123123", @{});
    
}

@end
