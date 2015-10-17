//
//  FSOperationManager.m
//  SLFarseer
//
//  Created by Salo on 15/10/16.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import "FSOperationManager.h"
#import "FSUtilities.h"
#import "FSDebugCentral.h"
#import "FSTransportManager.h"
#import "FSPeripheralClient.h"
#import "FSPackageIn.h"

@implementation FSOperationManager

- (void)sendOperationData:(NSData *)operationData {
    [[FSDebugCentral getInstance].transportManager.peripheralClient writeOperationToCharacteristic:operationData];
}

@end
