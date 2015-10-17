//
//  FSLog.h
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>
#import "FSDefine.h"

@class NSDate;
@class NSError;
@class NSString;
@class NSData;

#define FSFatal(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelFatal, __FILE__, __FUNCTION__, __LINE__)
#define FSError(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelError, __FILE__, __FUNCTION__, __LINE__)
#define FSWarning(format, ...)  FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelWarning, __FILE__, __FUNCTION__, __LINE__)
#define FSLog(format, ...)      FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelLog, __FILE__, __FUNCTION__, __LINE__)
#define FSMinor(format, ...)    FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelMinor, __FILE__, __FUNCTION__, __LINE__)

#define FSCFatal(condition, format, ...)    if (condition) { FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelFatal, __FILE__, __FUNCTION__, __LINE__); }
#define FSCError(condition, format, ...)    if (condition) { FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelError, __FILE__, __FUNCTION__, __LINE__); }
#define FSCWarning(condition, format, ...)  if (condition) { FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelWarning, __FILE__, __FUNCTION__, __LINE__); }
#define FSCLog(condition, format, ...)      if (condition) { FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelLog, __FILE__, __FUNCTION__, __LINE__); }
#define FSCMinor(condition, format, ...)    if (condition) { FS_DebugLog([NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelMinor, __FILE__, __FUNCTION__, __LINE__); }

FOUNDATION_EXTERN void FS_DebugLog(NSString *log, FSLogLevel level, const char *file, const char *function, unsigned int line);

void FSSendOperationData(NSData *operationData);
void closeBLEDebug();
void cleanLogBefore(NSDate *date);
void openBLEDebug(void(^callback)(NSError *error));