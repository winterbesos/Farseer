//
//  NSDictionary+Contents.h
//  SLAppCoreUtil
//
//  Created by Salo on 16/3/1.
//  Copyright © 2016年 Salo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Contents)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;
- (NSData *)plistData;

@end
