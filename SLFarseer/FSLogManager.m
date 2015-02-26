//
//  FSLogManager.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSLogManager.h"
#import "FSBLELog.h"

static dispatch_queue_t logFileOperationQueue;
static NSMutableArray   *cacheLogs;

@implementation FSLogManager

+ (void)inputLog:(FSBLELog *)log toFile:(const char *)filePath {
    
    if (!logFileOperationQueue) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    
    dispatch_async(logFileOperationQueue, ^{
        [self writeLog:log ToFile:filePath];
        [self cacheLogIfNeed:log];
    });
}

+ (void)writeLog:(FSBLELog *)log ToFile:(const char *)filePath {
    FILE    *fp = fopen(filePath, "a");
    if (!fp)
    {
        assert(false);
    }

    fprintf(fp, "%u %f %d %s\n", log.log_number, [log.log_date timeIntervalSinceReferenceDate], log.log_level, [log.log_content cStringUsingEncoding:NSUTF8StringEncoding]);
    fclose(fp);
}

+ (void)cacheLogIfNeed:(FSBLELog *)log {
    if (cacheLogs) {
        [cacheLogs addObject:log];
    }
}

+ (void)installLogFile:(const char *)filePath {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = [NSMutableArray array];
        
        FILE    *fp = fopen(filePath, "r");
        if (!fp)
        {
            assert(false);
        }
        
//        // ==
//        i=0;
//        while(!feof(fp))
//        {
//            if(fgets(a,1000,fp))
//            {
//                i++;
//                if(i==n)
//                {
//                    puts(a);
//                    fclose(fp);
//                    return 0;
//                }
//            }else{
//                break;
//            }
//        }
//        
//        //==
        
        fclose(fp);
    });
}

+ (void)uninstallLogFile {
    dispatch_async(logFileOperationQueue, ^{
        cacheLogs = nil;
    });
}

@end
