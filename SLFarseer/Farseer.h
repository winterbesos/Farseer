//
//  FSLog.h
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>

@class NSError;
@class NSString;

typedef enum {
    Minor = 0,
    Log,
    Warning,
    Error,
    Fatal,
} FSLogLevel;

#define FSFatal(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Fatal)
#define FSError(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Error)
#define FSWarning(format, ...)  FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Warning)
#define FSLog(format, ...)      FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Log)
#define FSMinor(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], Minor)

void FSPFatal(NSString *log);
void FSPError(NSString *log);
void FSPWarning(NSString *log);
void FSPLog(NSString *log);
void FSPMinor(NSString *log);

void FS_DebugLog(NSString *log, FSLogLevel level);

void closeBLEDebug();
void openBLEDebug(void(^callback)(NSError *error));