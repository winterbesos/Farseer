//
//  BTCentrelService.h
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

@class CBMutableCharacteristic;
@class FSBLELog;

@protocol FSBLEPeripheralServiceDelegate <NSObject>

@end

@interface FSBLEPeripheralService : NSObject

+ (void)installWithClient:(id)client callback:(void(^)(CBMutableCharacteristic *peripheralInfoCharacteristic,
                                                       CBMutableCharacteristic *logCharacteristic,
                                                       CBMutableCharacteristic *dataCharacteristic,
                                                       CBMutableCharacteristic *cmdCharacteristic,
                                                       NSError *error))callback;
+ (void)uninstall;
+ (void)updateCharacteristic:(CBMutableCharacteristic *)characteristic withData:(NSData *)data cmd:(CMD)cmd;

@end
