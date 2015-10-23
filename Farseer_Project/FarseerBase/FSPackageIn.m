//
//  FSPackageIn.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"

#define READTYPE(a, headSize) if (_readPos + headSize + sizeof(a) <= _pkg.length) {     \
                           a value;                                                  \
                           [_pkg getBytes:&value range:NSMakeRange(_readPos + headSize, sizeof(a))]; \
                           _readPos += sizeof(a);                                       \
                           return value;                                                \
                        }                                                                   \
                        return 0;

#define READSTRING(headSize) if (_readPos + headSize + sizeof(UInt32) <= _pkg.length) { \
                             UInt32 len;                                                      \
                             [_pkg getBytes:&len range:NSMakeRange(_readPos + headSize, sizeof(UInt32))];\
                             _readPos += sizeof(UInt32);\
                             if (_readPos + headSize + len <= _pkg.length) {\
                                NSData *stringData = [_pkg subdataWithRange:NSMakeRange(_readPos + headSize, len)];\
                                NSString *string = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];\
                                _readPos += len;\
                                return string;\
                             } else {\
                                return @"";\
                             }\
                         }\
                         return nil;


@implementation FSPackageIn {
    NSInteger   _readPos;
    NSData      *_pkg;
}

#pragma mark - Initialization

+ (instancetype)decode:(NSData *)data {
    return [[FSPackageIn alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _pkg = data;
        _readPos = 0;
    }
    return self;
}

#pragma mark - Read Method

- (Byte)readByte {
    READTYPE(Byte, 0)
}

- (UInt16)readUInt16 {
    READTYPE(UInt16, 0)
}

- (UInt32)readUInt32 {
    READTYPE(UInt32, 0)
}

- (UInt64)readUInt64 {
    READTYPE(UInt64, 0)
}

- (double)readDouble {
    READTYPE(double, 0)
}

- (NSDate *)readDate {
    NSTimeInterval value = [self readDouble];
    if (value) {
        return [NSDate dateWithTimeIntervalSinceReferenceDate:value];
    }
    
    return nil;
}

- (NSString *)readString {
    READSTRING(0)
}

- (NSData *)readData {
    return _pkg;
}

- (NSData *)readDataWithLength:(NSInteger)length {
    NSData *data = [_pkg subdataWithRange:NSMakeRange(_readPos, length)];
    _readPos += length;
    return data;
}

- (BOOL)hasMore {
    return _readPos < _pkg.length;
}

@end
