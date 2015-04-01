//
//  FSDefine.h
//  SLFarseer
//
//  Created by Go Salo on 15/3/19.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#ifndef SLFarseer_FSDefine_h
#define SLFarseer_FSDefine_h

typedef NS_ENUM(unsigned char, FSLogLevel) {
    FSLogLevelMinor = 0,
    FSLogLevelLog,
    FSLogLevelWarning,
    FSLogLevelError,
    FSLogLevelFatal,
};

typedef NS_ENUM(unsigned char, BLEOSType) {
    BLEOSTypeIOS,
    BLEOSTypeOSX
};

typedef NS_ENUM(unsigned char, BLEDeviceType) {
    BLEDeviceTypeIPod,
    BLEDeviceTypeIPhone,
    BLEDeviceTypeIPad,
    BLEDeviceTypeMac,
    BLEDeviceTypeAppleWatch
};

#endif
