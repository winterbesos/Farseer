//
//  FSPackerProtocol.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import "FSPackageIn.h"

@protocol FSPackerDelegate <NSObject>

@required

- (void)unpack:(FSPackageIn *)packageIn client:(id)client;

@end

@protocol FSBLEResDelegate <NSObject>

- (void)recvSyncLogWithLogNumber:(UInt32)logNum;

@end

@protocol FSBLEReqDelegate <NSObject>

@end
