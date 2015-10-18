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
#import "FSBLELogProtocol.h"

@class FSBLELog;
@class CBMutableCharacteristic;

@interface FSPeripheralClient : NSObject <FSBLEResDelegate>

- (void)setPeripheralInfoCharacteristic:(CBMutableCharacteristic *)infoCharacteristic
                      logCharacteristic:(CBMutableCharacteristic *)logCharacteristic
                     dataCharacteristic:(CBMutableCharacteristic *)dataCharacteristic
                      cmdCharacteristic:(CBMutableCharacteristic *)cmdCharacteristic;

- (void)writeLogToCharacteristic:(id<FSBLELogProtocol>)log;

@end