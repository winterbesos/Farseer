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
#define SLFatal(format, ...)    SLF_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Fatal)
#define SLError(format, ...)    SLF_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Error)
#define SLWarning(format, ...)  SLF_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Warning)
#define SLLog(format, ...)      SLF_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Log)
#define SLMinor(format, ...)    SLF_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Minor)

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
