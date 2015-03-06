//
//  FSDefine.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#ifndef SLBTServiceDemo_FSDefine_h
#define SLBTServiceDemo_FSDefine_h

typedef NS_ENUM(Byte, CMD) {
    CMDCPInit               = 0xa0,
    
    CMDReqLogging            = 0xa1,
    CMDRecLogging            = 0Xb1,
};

typedef NS_ENUM(Byte, BLEOSType) {
    BLEOSTypeIOS,
    BLEOSTypeOSX
};

typedef NS_ENUM(Byte, BLEDeviceType) {
    BLEDeviceTypeIPod,
    BLEDeviceTypeIPhone,
    BLEDeviceTypeIPad,
    BLEDeviceTypeMac,
    BLEDeviceTypeAppleWatch
};

struct PKG_HEADER {
    Byte cmd;
    Byte sequId;
    Byte totalPackage;
    Byte currentPackage;
};

struct LOG_HEADER {
    NSTimeInterval  createTime;
};

static NSString *kPeripheralInfoCharacteristicUUIDString = @"838D0104-C9B7-4B34-97B9-8213E24D5493";
static NSString *kWriteLogCharacteristicUUIDString = @"622C6B76-5A52-48F7-8595-468F7B8DD11D";
static NSString *kServiceUUIDString = @"A7D38D3B-0D9C-4D3C-AC9F-46C5E608A316";

#endif
