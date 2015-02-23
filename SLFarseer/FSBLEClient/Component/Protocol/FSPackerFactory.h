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

@interface FSPackerFactory : NSObject

+ (id<FSPackerDelegate>)getObjectWithCMD:(CMD)cmd;

@end
