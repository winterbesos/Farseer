//
//  FSBLELogInfo.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/26/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSBLELogInfo.h"

@implementation FSBLELogInfo

+ (FSBLELogInfo *)infoWithType:(BLEOSType)type osVersion:(NSString *)osVersion deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName bundleName:(NSString *)bundleName {
    FSBLELogInfo *logInfo = [[FSBLELogInfo alloc] init];
    logInfo->_log_type = type;
    logInfo->_log_OSVersion = osVersion;
    logInfo->_log_deviceType = deviceType;
    logInfo->_log_deviceName = deviceName;
    logInfo->_log_bundleName = bundleName;
    return logInfo;
}

@end
