//
//  FSLog.m
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
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

#define SLCONSOLE_LEVEL FSLogLevelWarning

void FS_DebugLog(NSString *log, FSLogLevel level, const char *file, const char *function, unsigned int line)
{   
    [[FSDebugCentral getInstance].logManager inputLog:[FSBLELog createLogWithLevel:level content:log file:file function: function line: line]];
    
#ifdef DEBUG
    const char *cLog = [log cStringUsingEncoding:NSUTF8StringEncoding];
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
            break;
    }
    
    if (level >= SLCONSOLE_LEVEL)
    {
        printf("%s:%s\n", prefix, cLog);
    }
    
    if (level == FSLogLevelFatal)
    {
        printf("fatal error");
        assert(false);
    }
    
#endif
}

void FSSendLog(id<FSBLELogProtocol> log) {
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

// TODO: doing

#include <objc/runtime.h>

static dispatch_once_t onceToken;

#define FSRegister(obj) dispatch_once(&onceToken, ^{ \
                            Register(obj);           \
                        });

void Register(id obj) {
    FSRegister([NSObject new]);
    static char kRegisterAssociatedhandleKey;
    static NSMutableArray *objs = nil;
    if (!objs) {
        objs = [NSMutableArray array];
    }
    
    NSObject *baseObj = [NSObject new];
    objc_setAssociatedObject(baseObj, &kRegisterAssociatedhandleKey, obj, OBJC_ASSOCIATION_ASSIGN);
    [objs addObject:baseObj];
}
