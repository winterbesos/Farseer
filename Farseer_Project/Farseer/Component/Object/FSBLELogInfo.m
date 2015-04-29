//
//  FSBLELogInfo.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/26/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELogInfo.h"
#import "FSUtilities.h"

@implementation FSBLELogInfo

+ (FSBLELogInfo *)infoWithType:(BLEOSType)type osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName deviceUUID:(NSString *)deviceUUID {
    FSBLELogInfo *logInfo = [[FSBLELogInfo alloc] init];
    logInfo->_log_OSType = type;
    logInfo->_log_OSVersion = osVersion;
    logInfo->_log_deviceType = deviceType;
    logInfo->_log_deviceName = deviceName;
    logInfo->_log_bundleName = bundleName;
    logInfo->_log_deviceUUID = deviceUUID;
    logInfo->_log_saveLogDate = [NSDate date];
    return logInfo;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSData *)logInfo_data {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&_log_OSType length:sizeof(self.log_OSType)];
    [data appendData:_log_OSVersion.dataValue];
    [data appendData:_log_deviceType.dataValue];
    [data appendData:_log_deviceName.dataValue];
    [data appendData:_log_bundleName.dataValue];
    [data appendData:_log_deviceUUID.dataValue];
    
    return data;
}

@end
