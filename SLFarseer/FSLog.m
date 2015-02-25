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

#import "FSBLEPerpheralService.h"

static char FPRINT_OUT_FILE_PATH[64] = {0};
static BOOL launched = false;

// console level config
#define SLCONSOLE_LEVEL Error
#define HOME_PATH       "/Users/Salo"


static void FS_LaunchCentral()
{
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR || 1
    [FSBLEPerpheralService install];
#else
    // get fasser document path
    char fullpath[256] = HOME_PATH;
    time_t t = time(0);
    const char *path = "/Documents/Farseer/Log/";
    strcat(fullpath, path);
    
    char filename[64];
    strftime(filename, sizeof(filename), "log_%Y-%m-%d_%H%M%S.log", localtime(&t));
    strcat(fullpath, filename);
    
    strcpy(FPRINT_OUT_FILE_PATH, fullpath);
    FILE *fp = fopen(FPRINT_OUT_FILE_PATH,"w");
    if (!fp)
    {
        assert(false);
    }
    fclose(fp);
#endif
    launched = true;
}


void FS_DebugLog(NSString *log, FSLogLevel level)
{
    if (!launched)
    {
        FS_LaunchCentral();
    }
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR || 1
    static Byte logNumber = 0;
    [FSBLEPerpheralService inputLogToCacheWithNumber:(Byte)logNumber date:[NSDate date] level:level content:log];
    
    logNumber ++;
#elif TARGET_OS_MAC
    
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

    if (level >= Error)
    {
        printf("%s:%s\n", prefix, cLog);
    }

    FILE    *fp = fopen(FPRINT_OUT_FILE_PATH, "a");
    if (!fp)
    {
        assert(false);
    }
    fprintf(fp, "%s:%s\n", prefix, cLog);
    fclose(fp);
    
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
