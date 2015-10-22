//
//  FSPackerFactory.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLEDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLEDefine.h>
#endif
#import "FSBLEPeripheralPackerProtocol.h"

@class CBATTRequest;

@interface FSBLEPeripheralPackerFactory : NSObject

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd request:(CBATTRequest *)request;

@end
