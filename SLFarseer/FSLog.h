//
//  SLFLog.h
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
//

@class NSString;

#import <Foundation/NSObjCRuntime.h>

// macro for log
#define FSFatal(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Fatal)
#define FSError(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Error)
#define FSWarning(format, ...)  FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Warning)
#define FSLog(format, ...)      FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Log)
#define FSMinor(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Minor)

// console level config
#define SLCONSOLE_LEVEL Error

typedef enum {
    Minor = 0,
    Log,
    Warning,
    Error,
    Fatal,
} FSLogLevel;
#define SLCONSOLE_LEVEL Error
FOUNDATION_EXPORT void FS_LaunchCentral();
FOUNDATION_EXPORT void FS_DebugLog(NSString *log, FSLogLevel level);
