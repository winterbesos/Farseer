//
//  FSFileManager.h
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSFileManager : NSObject

- (NSData *)getDirectoryContentsWithPath:(NSString *)path;

@end
