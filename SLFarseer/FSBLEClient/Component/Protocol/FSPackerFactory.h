//
//  FSPackerFactory.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"
#import "FSPackerProtocol.h"

@class CBATTRequest;

@interface FSPackerFactory : NSObject

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd;
+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd request:(CBATTRequest *)request;

@end
