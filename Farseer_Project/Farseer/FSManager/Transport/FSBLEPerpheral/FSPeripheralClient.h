//
//  FSPeripheralClient.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLEDefine.h"
#import "FSBLEPeripheralPackerProtocol.h"

@class FSBLELog;
@class CBMutableCharacteristic;

@interface FSPeripheralClient : NSObject <FSBLEResDelegate>

- (void)setPeripheralInfoCharacteristic:(CBMutableCharacteristic *)infoCharacteristic
                      logCharacteristic:(CBMutableCharacteristic *)logCharacteristic
                     dataCharacteristic:(CBMutableCharacteristic *)dataCharacteristic
                      cmdCharacteristic:(CBMutableCharacteristic *)cmdCharacteristic;

- (void)writeLogToCharacteristicIfWaitingWithLog:(FSBLELog *)log;
- (void)writeOperationToCharacteristic:(NSData *)operationData;

@end