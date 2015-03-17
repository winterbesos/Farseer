//
//  FSPackageIn.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"
#import "FSBLEPeripheralService.h"

#define READTYPE(a, b) if (_readPos + sizeof(b) + sizeof(a) <= _pkg.length) {     \
                           a value;                                                  \
                           [_pkg getBytes:&value range:NSMakeRange(_readPos + sizeof(b), sizeof(a))]; \
                           _readPos += sizeof(a);                                       \
                           return value;                                                \
                        }                                                                   \
                        return 0;

#define READSTRING(b) if (_readPos + sizeof(b) + sizeof(Byte) <= _pkg.length) { \
                             Byte len;                                                      \
                             [_pkg getBytes:&len range:NSMakeRange(_readPos + sizeof(b), sizeof(Byte))];\
                             _readPos += sizeof(Byte);\
                             if (_readPos + sizeof(b) + len <= _pkg.length) {\
                                NSData *stringData = [_pkg subdataWithRange:NSMakeRange(_readPos + sizeof(b), len)];\
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
        [data getBytes:&_header length:sizeof(PKG_HEADER)];
        _pkg = data;
        _readPos = 0;
        _readLogFile = NO;
    }
    return self;
}

- (instancetype)initWithLogData:(NSData *)data {
    self = [super init];
    if (self) {
        [data getBytes:&_logHeader length:sizeof(LOG_HEADER)];
        _pkg = data;
        _readPos = 0;
        _readLogFile = YES;
    }
    return self;
}

#pragma mark - Read Method

- (Byte)readByte {
    if (_readLogFile) {
        READTYPE(Byte, LOG_HEADER)
    } else {
        READTYPE(Byte, PKG_HEADER)
    }
}

- (UInt16)readUInt16 {
    if (_readLogFile) {
        READTYPE(UInt16, LOG_HEADER)
    } else {
        READTYPE(UInt16, PKG_HEADER)
    }
}

- (UInt32)readUInt32 {
    if (_readLogFile) {
        READTYPE(UInt32, LOG_HEADER)
    } else {
        READTYPE(UInt32, PKG_HEADER)
    }
}

- (UInt64)readUInt64 {
    if (_readLogFile) {
        READTYPE(UInt64, LOG_HEADER)
    } else {
        READTYPE(UInt64, PKG_HEADER)
    }
}

- (double)readDouble {
    if (_readLogFile) {
        READTYPE(double, LOG_HEADER)
    } else {
        READTYPE(double, PKG_HEADER)
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
        READSTRING(LOG_HEADER)
    } else {
        READSTRING(PKG_HEADER)
    }
}

@end
