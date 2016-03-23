//
//  FarseerBaseTests.m
//  FarseerBaseTests
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 so.salo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "FSLog_Test.h"
#import "NSDictionary+Contents.h"

@interface FarseerBaseTests : XCTestCase

@end

@implementation FarseerBaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCheckPlistObjectExample {
    
    id obj1 = @{
                @(1): @"abc",
                @"2": @"def"};
    
    id obj2 = @{@"1": @"abc",
                @"2": [NSObject new]};
    
    id obj3 = @{@"1": @[@"1", [NSObject new]]};
    
    id obj4 = @{@"1": @"a",
                @"2": @(1),
                @"3": @[@"a", @(2), [NSData data], @[[NSObject class]]],
                @"4": @{@"1": @"a",
                        @"2": @(1),
                        @"3": @[@"a", @(2), [NSData data], @[@"a"]]}
                };
    
    id circleObj1 = [NSMutableArray array];
    [circleObj1 addObject:circleObj1];
    [circleObj1 addObject:@"a"];
    
    id circleObj2 = @[circleObj1];
    
    id objtrue = @{@"1": @"a",
                   @"2": @(1),
                   @"3": @[@"a", @(2), [NSData data], @[@"a"]],
                   @"4": @{@"1": @"a",
                           @"2": @(1),
                           @"3": @[@"a", @(2), [NSData data], @[@"a"]]}
                   };
    
    id log = [FSStorageLog new];
    
    XCTAssertFalse([log checkObject:obj1]);
    XCTAssertFalse([log checkObject:obj2]);
    XCTAssertFalse([log checkObject:obj3]);
    XCTAssertFalse([log checkObject:obj4]);
    XCTAssertFalse([log checkObject:circleObj1]);
    XCTAssertFalse([log checkObject:circleObj2]);
    XCTAssertTrue([log checkObject:objtrue]);
}

@end
