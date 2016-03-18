//
//  FSLog.h
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FarseerBase_iOS.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FarseerBase_OSX.h>
#endif

@class NSDate;
@class NSError;
@class NSString;
@class NSData;

static const NSInteger kDefaultLogCode = -1;

#define FSFatal(format, ...)                FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelFatal, nil, __FILE__, __FUNCTION__, __LINE__)
#define FSError(code, domain, info)         FS_DebugLog(code, \
                                                        domain, \
                                                        FSLogLevelError, \
                                                        info, \
                                                        __FILE__, __FUNCTION__, __LINE__)

#define FSWarning(format, ...)              FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelWarning, nil, __FILE__, __FUNCTION__, __LINE__)
#define FSLog(format, ...)                  FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelLog, nil, __FILE__, __FUNCTION__, __LINE__)
#define FSMinor(format, ...)                FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelMinor, nil, __FILE__, __FUNCTION__, __LINE__)

#define FSCFatal(condition, format, ...)    if (condition) { FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelFatal, nil, __FILE__, __FUNCTION__, __LINE__); }
#define FSCError(condition, code, info, format, ...)    if (condition) { FS_DebugLog(code, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelError, info, __FILE__, __FUNCTION__, __LINE__); }
#define FSCWarning(condition, format, ...)  if (condition) { FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelWarning, nil __FILE__, __FUNCTION__, __LINE__); }
#define FSCLog(condition, format, ...)      if (condition) { FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelLog, nil, __FILE__, __FUNCTION__, __LINE__); }
#define FSCMinor(condition, format, ...)    if (condition) { FS_DebugLog(kDefaultLogCode, [NSString stringWithFormat: format, ##__VA_ARGS__], FSLogLevelMinor, nil __FILE__, __FUNCTION__, __LINE__); }

FOUNDATION_EXTERN void FS_DebugLog(NSInteger code, NSString *domain, FSLogLevel level, NSDictionary <NSString *, id>*info, const char *file, const char *function, unsigned int line);

void FSSendLog(id<FSBLELogProtocol> log);
void closeBLEDebug();
void cleanLogBefore(NSDate *date);
void openBLEDebug(void(^callback)(NSError *error));
