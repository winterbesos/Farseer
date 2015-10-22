//
//  FSPeripheralClient.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLELogProtocol.h>
#import <FarseerBase_iOS/FSDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLELogProtocol.h>
#import <FarseerBase_OSX/FSDefine.h>
#endif
#import "FSBLEPeripheralPackerProtocol.h"

@class FSBLELog;
@class CBMutableCharacteristic;

@interface FSPeripheralClient : NSObject <FSBLEResDelegate>

- (void)setPeripheralInfoCharacteristic:(CBMutableCharacteristic *)infoCharacteristic
                      logCharacteristic:(CBMutableCharacteristic *)logCharacteristic
                     dataCharacteristic:(CBMutableCharacteristic *)dataCharacteristic
                      cmdCharacteristic:(CBMutableCharacteristic *)cmdCharacteristic;

- (void)writeLogToCharacteristic:(id<FSBLELogProtocol>)log;

@end