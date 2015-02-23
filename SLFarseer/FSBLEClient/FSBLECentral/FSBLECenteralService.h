//
//  FSBLECenteralService.h
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/22/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface FSBLECenteralService : NSObject

+ (void)install;
+ (void)uninstall;
+ (void)scanDidDisconvered:(void(^)(CBPeripheral *perpheral, NSNumber *RSSI))callback;
+ (void)setConnectPerpheralCallback:(void(^)(CBPeripheral *perpheral, BOOL success))callback;
+ (void)connectToPerpheral:(CBPeripheral *)perpheral;

@end
