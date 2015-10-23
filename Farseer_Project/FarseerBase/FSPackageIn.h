//
//  FSPackageIn.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLEDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLEDefine.h>
#endif

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
- (NSData *)readDataWithLength:(NSInteger)length;
- (BOOL)hasMore;

@end
