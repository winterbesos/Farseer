//
//  FSFileManager.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSFileManager.h"
#import "FSUtilities.h"

@implementation FSFileManager

- (NSData *)getDirectoryContentsWithPath:(NSString *)path {
    NSError *error;
    NSString *targetPath = [[FSUtilities RootPath] stringByAppendingPathComponent:path];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetPath error:&error];
    
    NSMutableDictionary *directoryContents = [NSMutableDictionary dictionary];
    NSMutableArray *files = [NSMutableArray array];
    [directoryContents setObject:path forKey:@"path"];
    [directoryContents setObject:files forKey:@"contents"];
    
    for (NSString *content in contents) {
        NSDictionary *attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:[targetPath stringByAppendingPathComponent:content] error:nil];
        
        NSDictionary *fileInfo = @{@"name": content,
                                   @"fileType": attribute[@"NSFileType"],
                                   @"size": attribute[@"NSFileSize"]};
        [files addObject:fileInfo];
    }
    
    return [NSJSONSerialization dataWithJSONObject:directoryContents options:NSJSONWritingPrettyPrinted error:nil];
}

@end
