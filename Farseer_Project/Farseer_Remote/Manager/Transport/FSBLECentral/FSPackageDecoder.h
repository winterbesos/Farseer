//
//  FSPackerDecoder.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/29.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLEDefine.h>
#import <Farseer_Remote_iOS/FSCentralClientDelegate.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLEDefine.h>
#import <Farseer_Remote_Mac/FSCentralClientDelegate.h>
#endif

@class FSPackageDecoder;
@class CBPeripheral;

@protocol FSPackageDecoderDelegate <NSObject>

@end

@interface FSPackageDecoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageDecoderDelegate>)delegate;
- (BOOL)pushReceiveData:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral;
- (void)clearCache;

@end
