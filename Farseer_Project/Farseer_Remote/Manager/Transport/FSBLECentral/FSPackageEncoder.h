//
//  FSPackageEncoder.h
//  SLFarseer
//
//  Created by Salo on 15/10/17.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLEDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLEDefine.h>
#endif

@class FSPackageEncoder;

@protocol FSPackageEncoderDelegate <NSObject>

- (void)packageEncoderDidPushData:(FSPackageEncoder *)encoder;

@end

@interface FSPackageEncoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageEncoderDelegate>)delegate;

- (void)pushDataToSendQueue:(NSData *)data cmd:(CMD)cmd;
- (NSArray *)getTopPackageGroup;

@end
