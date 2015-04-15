//
//  FSCentralClient.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/23/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDefine.h"
#import "FSCentralClientDelegate.h"

@class CBPeripheral;

@interface FSCentralClient : NSObject

- (instancetype)initWithDelegate:(id<FSCentralClientDelegate>)delegate;

@end
