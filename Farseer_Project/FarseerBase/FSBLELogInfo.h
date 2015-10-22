//
//  FSBLELogInfo.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/26/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSDefine.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSDefine.h>
#endif

@interface FSBLELogInfo : NSObject

@property (nonatomic, readonly)BLEOSType        log_OSType;
@property (nonatomic, readonly)NSString         *log_OSVersion;
@property (nonatomic, readonly)NSString         *log_deviceType;
@property (nonatomic, readonly)NSString         *log_deviceName;
@property (nonatomic, readonly)NSString         *log_bundleName;
@property (nonatomic, readonly)NSString         *log_deviceUUID;
@property (nonatomic, readonly)NSDate           *log_saveLogDate;

@property (nonatomic, readonly)NSData           *logInfo_data;

+ (FSBLELogInfo *)infoWithType:(BLEOSType)type osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName deviceUUID:(NSString *)deviceUUID;
- (instancetype)initWithData:(NSData *)data;

@end
