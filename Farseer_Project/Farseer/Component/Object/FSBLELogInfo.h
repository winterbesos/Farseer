//
//  FSBLELogInfo.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/26/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDefine.h"

@interface FSBLELogInfo : NSObject

@property (nonatomic, assign, readonly)BLEOSType    log_type;
@property (nonatomic, copy, readonly)NSString       *log_OSVersion;
@property (nonatomic, copy, readonly)NSString       *log_deviceType;
@property (nonatomic, copy, readonly)NSString       *log_deviceName;
@property (nonatomic, copy, readonly)NSString       *log_bundleName;

+ (FSBLELogInfo *)infoWithType:(BLEOSType)type osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName;

@end
