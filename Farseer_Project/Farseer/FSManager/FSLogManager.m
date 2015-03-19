//
//  FSLogManager.m
//  SLFarseer
//
//  Created by Go Salo on 1/16/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "FSLogManager.h"
#import "FSBLELog.h"
#import "FSPackageIn.h"
#import "FSBLEPeripheralService.h"
#import <CoreBluetooth/CBPeripheral.h>
#import "FSDebugCentral.h"
#import "FSPeripheralClient.h"
#import "FSUtilities.h"
#import "FSTransportManager.h"

#define OUTPUT_CONSOLE

@implementation FSLogManager 

- (instancetype)init
{
    self = [super init];
    if (self) {
        logFileOperationQueue = dispatch_queue_create("logFileOperationQueue", NULL);
    }
    return self;
}

#pragma mark - Write File

// File

- (void)writeLog:(FSBLELog *)log ToFile:(const char *)filePath {
    @synchronized(self) {
        FILE    *fp = fopen(filePath, "a");
        if (!fp)
        {
            assert(false);
        }
        
        NSData *dataValue = [log dataValue];
        const void *bytes = [dataValue bytes];
        fwrite(bytes, sizeof(Byte), dataValue.length, fp);
        fclose(fp);
        
#ifdef OUTPUT_CONSOLE
        static NSString *currentPath = nil;
        if (!currentPath) {
            currentPath = [[FSUtilities FS_LogPath] stringByAppendingPathComponent:@"current.log"];
            
            fp = fopen(currentPath.UTF8String, "w");
            fprintf(fp, "\33[2J");
            fclose(fp);
        }
        
        fp = fopen(currentPath.UTF8String, "a");
        if (fp != NULL) {
            char *format = NULL;
            switch (log.log_level) {
                case 0:
                    format = "\033[37m%s %s \033[0m\n";
                    break;
                case 1:
                    format = "\033[32m%s %s \033[0m\n";
                    break;
                case 2:
                    format = "\033[33m%s %s \033[0m\n";
                    break;
                case 3:
                    format = "\033[31m%s %s \033[0m\n";
                    break;
                case 4:
                    format = "\033[41;37m%s %s \033[0m\n";
                    break;
            }
            
            static NSDateFormatter *kLogDateFormatter = nil;
            if (!kLogDateFormatter) {
                kLogDateFormatter = [[NSDateFormatter alloc] init];
                [kLogDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [kLogDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            }
            
            fprintf(fp, format, [kLogDateFormatter stringFromDate:log.log_date].UTF8String, log.log_content.UTF8String);
            fclose(fp);
        }
#endif
    }
}

@end
