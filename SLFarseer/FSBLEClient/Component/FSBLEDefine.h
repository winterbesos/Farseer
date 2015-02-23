//
//  FSDefine.h
//  SLBTServiceDemo
//
//  Created by Go Salo on 2/15/15.
//  Copyright (c) 2015 Go Salo. All rights reserved.
//

#ifndef SLBTServiceDemo_FSDefine_h
#define SLBTServiceDemo_FSDefine_h

struct PKG_HEADER {
    Byte cmd;
    Byte sequId;
    Byte totalPackage;
    Byte currentPackage;
};

typedef NS_ENUM(Byte, CMD) {
    CMDCPInit               = 0xa0,
    CMDCPBeginReceiveLog    = 0xa1,
    CMDCPLoggingACK         = 0xa2,
    
    CMDPCInit               = 0xb0,
    CMDCPLogging            = 0Xb1,
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

#endif
