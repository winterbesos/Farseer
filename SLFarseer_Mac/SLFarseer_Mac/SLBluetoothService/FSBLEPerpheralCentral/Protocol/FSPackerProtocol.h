//
//  FSPackerProtocol.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"

@class FSPerpheralClient;

@protocol FSPackerDelegate <NSObject>

@required

- (void)unpack:(FSPackageIn *)packageIn client:(FSPerpheralClient *)client;

@end
