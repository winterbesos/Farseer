//
//  FSLog.h
//  Farseer
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 so.salo. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>
#import "FarseerBase.h"

@class NSDate;
@class NSError;
@class NSString;
@class NSData;

#define STRINGIZE(arg) #arg
#define CONCATENATE(arg1, arg2) arg1##arg2

#define FSINFO_OFFSETS_1(kv, ...) kv ?: @"nil"
#define FSINFO_OFFSETS_2(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_1(__VA_ARGS__)
#define FSINFO_OFFSETS_3(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_2(__VA_ARGS__)
#define FSINFO_OFFSETS_4(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_3(__VA_ARGS__)
#define FSINFO_OFFSETS_5(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_4(__VA_ARGS__)
#define FSINFO_OFFSETS_6(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_5(__VA_ARGS__)
#define FSINFO_OFFSETS_7(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_6(__VA_ARGS__)
#define FSINFO_OFFSETS_8(kv, ...) kv ?: @"nil", FSINFO_OFFSETS_7(__VA_ARGS__)

#define FSINFO_OFFSETS_NARG(...) FSINFO_OFFSETS_NARG_(__VA_ARGS__, FSINFO_OFFSETS_RSEQ_N())
#define FSINFO_OFFSETS_NARG_(...) FSINFO_OFFSETS_ARG_N(__VA_ARGS__)
#define FSINFO_OFFSETS_ARG_N(_1, _2, _3, _4, _5, _6, _7, _8, N, ...) N
#define FSINFO_OFFSETS_RSEQ_N() 8, 7, 6, 5, 4, 3, 2, 1, 0

#define FSINFO_OFFSETS_(N, kv, ...) CONCATENATE(FSINFO_OFFSETS_, N)(kv, __VA_ARGS__)
#define FSINFO(...) @{FSINFO_OFFSETS_(FSINFO_OFFSETS_NARG(__VA_ARGS__), __VA_ARGS__)}

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
