//
//  FSPackageIn.m
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"
#import "FSBLEPerpheralService.h"

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
        [data getBytes:&_header length:sizeof(PKG_HEADER)];
        _pkg = data;
        _readPos = 0;
    }
    return self;
}

#pragma mark - Read Method

- (Byte)readByte {
    if (_readPos + sizeof(PKG_HEADER) + sizeof(Byte) <= _pkg.length) {
        Byte value;
        [_pkg getBytes:&value range:NSMakeRange(_readPos + sizeof(PKG_HEADER), sizeof(Byte))];
        _readPos += sizeof(Byte);
        return value;
    }
    
    return 0;
}

- (UInt16)readUInt16 {
    if (_readPos + sizeof(PKG_HEADER) + sizeof(UInt16) <= _pkg.length) {
        UInt16 value;
        [_pkg getBytes:&value range:NSMakeRange(_readPos + sizeof(PKG_HEADER), sizeof(UInt16))];
        _readPos += sizeof(UInt16);
        return value;
    }
    
    return 0;
}

- (UInt32)readUInt32 {
    if (_readPos + sizeof(PKG_HEADER) + sizeof(UInt32) <= _pkg.length) {
        UInt32 value;
        [_pkg getBytes:&value range:NSMakeRange(_readPos + sizeof(PKG_HEADER), sizeof(UInt32))];
        _readPos += sizeof(UInt32);
        return value;
    }
    
    return 0;
}

- (UInt64)readUInt64 {
    if (_readPos + sizeof(PKG_HEADER) + sizeof(UInt64) <= _pkg.length) {
        UInt64 value;
        [_pkg getBytes:&value range:NSMakeRange(_readPos + sizeof(PKG_HEADER), sizeof(UInt64))];
        _readPos += sizeof(UInt64);
        return value;
    }
    
    return 0;
}

- (NSDate *)readDate {
    UInt64 value = [self readUInt64];
    if (value) {
        return [NSDate dateWithTimeIntervalSinceReferenceDate:value];
    }
    
    return nil;
}

- (NSString *)readString {
    if (_readPos + sizeof(PKG_HEADER) + sizeof(Byte) <= _pkg.length) {
        Byte len;
        [_pkg getBytes:&len range:NSMakeRange(_readPos + sizeof(PKG_HEADER), sizeof(Byte))];
        
        _readPos += sizeof(Byte);
        if (_readPos + sizeof(PKG_HEADER) + len <= _pkg.length) {
            NSData *stringData = [_pkg subdataWithRange:NSMakeRange(_readPos + sizeof(PKG_HEADER), len)];
            NSString *string = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
            _readPos += len;
            return string;
        } else {
            NSAssert(false, @"-(void)readString error");
        }
    }
    
    return nil;
}

@end
