//
//  FSDirectoryWrapper.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/26.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSDirectoryWrapper.h"

@implementation FSDirectoryWrapper {
    id<FSDirectoryWrapperDelegate> _delegate;
    NSMutableDictionary *_sandBoxDicrionary;
    NSString *_attentionPath;
}

/* ********************************************************************* *
 * [                                                                     *
 *  key: path value: relative path                                       *
 *  key: contents value: [[                                              *
 *                         key: fileType value: fileType                 *
 *                         key: size value: size                         *
 *                         key: name value: name                         *
 *                         key: contents value: [contents as superNode]  *
 *                       ]]                                              *
 * ]                                                                     *
 * ********************************************************************* */

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sandBoxDicrionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)insertSandBoxInfo:(NSDictionary *)sandBoxInfo {
    NSString *path = sandBoxInfo[@"path"];
    NSArray *contents = sandBoxInfo[@"contents"];
    if ([path isEqualToString:@""]) {
        _sandBoxDicrionary = [sandBoxInfo mutableCopy];
    }
    
    if ([path isEqualToString:_attentionPath] && [_delegate respondsToSelector:@selector(wrapper:didUpdateSubDirectoryInfo:)]) {
        [_delegate wrapper:self didUpdateSubDirectoryInfo:contents];
    }
}

- (NSArray *)registerWithDelegate:(id<FSDirectoryWrapperDelegate>)delegate path:(NSString *)path {
    _attentionPath = path;
    _delegate = delegate;
    
    return @[];
}

@end
