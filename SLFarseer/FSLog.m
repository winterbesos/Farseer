//
//  FSLog.m
//  imoffice_for_mac
//
//  Created by Go Salo on 1/30/15.
//  Copyright (c) 2015 imo. All rights reserved.
//

#include "FSLog.h"
#include <Foundation/NSString.h>
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
#import "FSLogManager.h"
#import "FSBLELog.h"
#import "FSBLEDefine.h"

#define SLCONSOLE_LEVEL Warning

void FS_DebugLog(NSString *log, FSLogLevel level)
{   
    [FSLogManager inputLog:[FSBLELog createLogWithLevel:level content:log]];
    
#ifdef DEBUG
    const char *cLog = [log cStringUsingEncoding:NSUTF8StringEncoding];
    char *prefix = NULL;
    switch (level) {
        case Fatal:
            prefix = "[FATAL]";
            break;
        case Error:
            prefix = "[ERROR]";
            break;
        case Warning:
            prefix = "[WARNING]";
            break;
        case Log:
            prefix = "[LOG]";
            break;
        case Minor:
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
    
    if (level == Fatal)
    {
        printf("fatal error");
        assert(false);
    }
    
#endif
}

void FSPFatal(NSString *log) {
    FS_DebugLog(log, Fatal);
}

void FSPError(NSString *log) {
    FS_DebugLog(log, Error);
}

void FSPWarning(NSString *log) {
    FS_DebugLog(log, Warning);
}

void FSPLog(NSString *log) {
    FS_DebugLog(log, Log);
}

void FSPMinor(NSString *log) {
    FS_DebugLog(log, Minor);
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
