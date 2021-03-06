//
//  FSPackerDecoder.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"
#import "FSCentralClientDelegate.h"

@class FSPackageDecoder;
@class CBPeripheral;

@protocol FSPackageDecoderDelegate <NSObject>

@end

@interface FSPackageDecoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageDecoderDelegate>)delegate;
- (BOOL)pushReceiveData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral;
- (void)clearCache;

@end
