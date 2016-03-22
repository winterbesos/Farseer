//
//  FSLog.m
//  Farseer
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 so.salo. All rights reserved.
//

#include "Farseer.h"
#include <stdio.h>
#include <stdarg.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>
#include <dirent.h>
#import <Foundation/NSString.h>
#import "FSLogManager.h"
#import "FSDebugCentral.h"

static BOOL isDebug = NO;
static FSLogLevel consoleLevel = FSLogLevelError;

void FS_DebugLog(NSInteger code, NSString *domain, FSLogLevel level, NSDictionary <NSString *, id>*info, const char *file, const char *function, unsigned int line)
{
    FSBLELog *log = [FSBLELog createLogWithLevel:level domain:domain info:info file:file function:function line:line];
    [[FSDebugCentral getInstance].logManager inputLog:log];
    
    if (isDebug) {
        const char *cLog = [domain cStringUsingEncoding:NSUTF8StringEncoding];
        char *prefix = NULL;
        switch (level) {
            case FSLogLevelFatal:
                prefix = "[FATAL]";
                break;
            case FSLogLevelError:
                prefix = "[ERROR]";
                break;
            case FSLogLevelWarning:
                prefix = "[WARNING]";
                break;
            case FSLogLevelLog:
                prefix = "[LOG]";
                break;
            case FSLogLevelMinor:
                prefix = "[MINOR]";
                break;
            default:
                assert(false);
                return;
        }
        
        if (level >= consoleLevel)
        {
            printf("%s:%s\n", prefix, cLog);
        }
        
        if (level == FSLogLevelFatal)
        {
            printf("fatal error");
            assert(false);
        }
    }
    
}

void FSSendLog(id<FSBLELogProtocol, FSStorageLogProtocol> log) {
    [[FSDebugCentral getInstance].logManager inputLog:log];
}

void closeBLEDebug() {
    [FSDebugCentral closeBLEDebug];
}

void openBLEDebug(void(^callback)(NSError *error)) {
    [FSDebugCentral openBLEDebug:callback];
}

void cleanLogBefore(NSDate *date) {
    [[FSDebugCentral getInstance].logManager cleanLogBeforeDate:date];
}
