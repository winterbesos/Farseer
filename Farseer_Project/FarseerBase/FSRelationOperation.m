//
//  FSRelationOperation.m
//  SLFarseer
//
//  Created by Salo on 15/10/23.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "FSRelationOperation.h"
#import "NSString+FSBLECatetory.h"
#import "FSPackageIn.h"

static NSString *header = @"RO";

@implementation FSRelationOperation

- (instancetype)initWithFromNodeName:(NSString *)fromNodeName toNodeName:(NSString *)toNodeName
{
    self = [super init];
    if (self) {
        _fromNodeName = fromNodeName;
        _toNodeName = toNodeName;
    }
    return self;
}

- (NSData *)BLETransferEncode {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&(_sequence) length:sizeof(_sequence)];
    [data appendData:_fromNodeName.SLEncodeData];
    [data appendData:_toNodeName.SLEncodeData];
    return data;
}

- (void)BLETransferDecodeWithData:(NSData *)data {
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
    self.sequence = [packageIn readUInt32];
    self.fromNodeName = [packageIn readString] ?: @"";
    self.toNodeName = [packageIn readString] ?: @"";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d %@ ==> %@", (unsigned int)self.sequence, self.fromNodeName, self.toNodeName];
}

@end
