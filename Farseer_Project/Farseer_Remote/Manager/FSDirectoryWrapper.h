//
//  FSDirectoryWrapper.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/26.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSDirectoryWrapperDelegate;

@interface FSDirectoryWrapper : NSObject

- (void)insertSandBoxInfo:(NSDictionary *)sandBoxInfo;
- (NSArray *)registerWithDelegate:(id<FSDirectoryWrapperDelegate>)delegate path:(NSString *)path;

@end

@protocol FSDirectoryWrapperDelegate <NSObject>

- (void)wrapper:(FSDirectoryWrapper *)wrapper didUpdateSubDirectoryInfo:(NSArray *)subDirectoryInfo;

@end
