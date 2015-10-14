//
//  FSPackerDecoder.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"

@class FSPackageDecoder;
@class CBPeripheral;

@protocol FSPackageDecoderDelegate <NSObject>

- (void)packageDecoder:(FSPackageDecoder *)packageDecoder didDecodePackageData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral cmd:(CMD)cmd;
- (void)packageDecoder:(FSPackageDecoder *)packageDecoder didDecodePackageDataProgress:(float)progress fromPeripheral:(CBPeripheral *)peripheral cmd:(CMD)cmd;

@end

@interface FSPackageDecoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageDecoderDelegate>)delegate;
- (BOOL)pushReceiveData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral;
- (void)clearCache;

@end
