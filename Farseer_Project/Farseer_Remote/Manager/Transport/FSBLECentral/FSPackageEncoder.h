//
//  FSPackageEncoder.h
//  SLFarseer
//
//  Created by Salo on 15/10/17.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FarseerBase_iOS/FSBLEDefine.h>

@class FSPackageEncoder;

@protocol FSPackageEncoderDelegate <NSObject>

- (void)packageEncoderDidPushData:(FSPackageEncoder *)encoder;

@end

@interface FSPackageEncoder : NSObject

- (instancetype)initWithDelegate:(id<FSPackageEncoderDelegate>)delegate;

- (void)pushDataToSendQueue:(NSData *)data cmd:(CMD)cmd;
- (NSArray *)getTopPackageGroup;

@end
