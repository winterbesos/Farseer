//
//  FSBLECentralPackerFactory.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLECentralPackerProtocol.h"

@interface FSBLECentralPackerFactory : NSObject

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd;

@end
