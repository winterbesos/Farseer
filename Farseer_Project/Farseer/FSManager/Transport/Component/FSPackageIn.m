//
//  FSPackageIn.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"
#import "FSBLEPeripheralService.h"

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
    
    BOOL        _readLogFile;
}

#pragma mark - Initialization

+ (instancetype)decode:(NSData *)data {
    return [[FSPackageIn alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
//        [data getBytes:&_header length:sizeof(struct PKG_HEADER)];
        _pkg = data;
        _readPos = 0;
        _readLogFile = NO;
    }
    return self;
}

- (instancetype)initWithLogData:(NSData *)data {
    self = [super init];
    if (self) {
//        [data getBytes:&_logHeader length:sizeof(struct LOG_HEADER)];
        _pkg = data;
        _readPos = 0;
        _readLogFile = YES;
    }
    return self;
}

#pragma mark - Read Method

- (Byte)readByte {
    if (_readLogFile) {
        READTYPE(Byte, sizeof(struct LOG_HEADER))
    } else {
        READTYPE(Byte, 0)
    }
}

- (UInt16)readUInt16 {
    if (_readLogFile) {
        READTYPE(UInt16, sizeof(struct LOG_HEADER))
    } else {
        READTYPE(UInt16, 0)
    }
}

- (UInt32)readUInt32 {
    if (_readLogFile) {
        READTYPE(UInt32, sizeof(struct LOG_HEADER))
    } else {
        READTYPE(UInt32, 0)
    }
}

- (UInt64)readUInt64 {
    if (_readLogFile) {
        READTYPE(UInt64, sizeof(struct LOG_HEADER))
    } else {
        READTYPE(UInt64, 0)
    }
}

- (double)readDouble {
    if (_readLogFile) {
        READTYPE(double, sizeof(struct LOG_HEADER))
    } else {
        READTYPE(double, 0)
    }
}

- (NSDate *)readDate {
    NSTimeInterval value = [self readDouble];
    if (value) {
        return [NSDate dateWithTimeIntervalSinceReferenceDate:value];
    }
    
    return nil;
}

- (NSString *)readString {
    if (_readLogFile) {
        READSTRING(sizeof(struct LOG_HEADER))
    } else {
        READSTRING(0)
    }
}

@end
