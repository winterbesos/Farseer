//
//  FSPackageIn.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"

@interface FSPackageIn : NSObject

@property (nonatomic, readonly)struct PKG_HEADER header;
@property (nonatomic, readonly)struct LOG_HEADER logHeader;

- (instancetype)initWithData:(NSData *)data;
+ (instancetype)decode:(NSData *)data;

- (NSDate *)readDate;
- (NSString *)readString;
- (Byte)readByte;
- (UInt16)readUInt16;
- (UInt32)readUInt32;
- (UInt64)readUInt64;
- (NSData *)readData;

@end
