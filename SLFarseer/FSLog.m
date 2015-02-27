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

static char FPRINT_OUT_FILE_PATH[512] = {0};

char *logFilePath() {
    return FPRINT_OUT_FILE_PATH;
}

static const char * logPath() {
#if TARGET_OS_IPHONE
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[pathList objectAtIndex:0] stringByAppendingPathComponent:@"/Farseer/Log/"];
#elif TARGET_OS_MAC
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *dataPath = [[path stringByAppendingPathComponent:bundleId] stringByAppendingPathComponent:@"/Farseer/Log/"]; // 相当于IOS的 documentpath
#endif
    return [dataPath cStringUsingEncoding:NSUTF8StringEncoding];
}

static void createLogPathIfNeed()
{
    NSError *err;
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithCString:logPath() encoding:NSUTF8StringEncoding] withIntermediateDirectories:YES attributes:nil error:&err];
}

static void FS_LaunchCentralIfNeed()
{
    static BOOL launched = false;
    if (!launched)
    {
        createLogPathIfNeed();
        
        // get fasser document path
        char fullpath[256] = {0};
        strcpy(fullpath, logPath());
        
        char filename[64];
        time_t t = time(0);
        strftime(filename, sizeof(filename), "log_%Y-%m-%d_%H%M%S.log", localtime(&t));
        strcat(fullpath, filename);
        
        strcpy(FPRINT_OUT_FILE_PATH, fullpath);
        FILE *fp = fopen(FPRINT_OUT_FILE_PATH,"w");
        if (!fp)
        {
            assert(false);
        }
        
        struct LOG_HEADER header;
        header.a = 1;
        
        fwrite(&header, sizeof(Byte), 1, fp);
        
        fclose(fp);

        launched = true;
    }
}


void FS_DebugLog(NSString *log, FSLogLevel level)
{
    FS_LaunchCentralIfNeed();
    
    [FSLogManager inputLog:[FSBLELog createLogWithLevel:level content:log] toFile:FPRINT_OUT_FILE_PATH];
    
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
