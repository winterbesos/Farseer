//
//  SLFLog.c
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

static char FPRINT_OUT_FILE_PATH[64] = {0};
static BOOL launched = false;

void FS_LaunchCentral()
{
    time_t t = time(0);
    char path[64];
    strftime(path, sizeof(path), "/Users/Salo/Documents/Farseer/Log/log_%Y-%m-%d_%H%M%S.log", localtime(&t));
    
    strcpy(FPRINT_OUT_FILE_PATH, path);
    FILE *fp = fopen(FPRINT_OUT_FILE_PATH,"w");
    if (!fp)
    {
        assert(false);
    }
    fclose(fp);
    launched = true;
}

void FS_DebugLog(NSString *log, FSLogLevel level)
{
    if (!launched)
    {
        FS_LaunchCentral();
    }
    
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
    
    if (level >= Error) {
        printf("%s:%s\n", prefix, cLog);
    }
    
    FILE    *fp = fopen(FPRINT_OUT_FILE_PATH, "a");
    if (!fp) {
        assert(false);
    }
    fprintf(fp, "%s:%s\n", prefix, cLog);
    fclose(fp);
}