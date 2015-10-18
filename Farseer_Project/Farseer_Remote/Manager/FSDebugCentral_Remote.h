//
//  FSDebugCentral_Remote.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCentralClient.h"

@class FSCentralLogManager;

@interface FSDebugCentral_Remote : NSObject

@property (nonatomic, readonly)FSCentralLogManager *logManager;
@property (nonatomic, readonly)FSCentralClient *centralClient;

+ (FSDebugCentral_Remote *)getInstance;

@end
