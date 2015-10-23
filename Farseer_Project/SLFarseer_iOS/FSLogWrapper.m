//
//  FSLogWrapper.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogWrapper.h"
#import "FSUtilities.h"
#if TARGET_OS_IPHONE
#import <FarseerBase_iOS/FSBLELog.h>
#import <FarseerBase_iOS/FSBLELogInfo.h>
#import <FarseerBase_iOS/FSPackageIn.h>
#elif TARGET_OS_MAC
#import <FarseerBase_OSX/FSBLELog.h>
#import <FarseerBase_OSX/FSBLELogInfo.h>
#import <FarseerBase_OSX/FSPackageIn.h>
#endif

#define kCONTENT_KEY @"kCONTENT_KEY"
#define kSUBNODE_KEY @"kSUBNODE_KEY"

@implementation FSLogWrapper {
    /* **************************************************************************************************************** *
     * [                                                                                                                *
     *  key: content value: [logs]                                                                                      *
     *  key: subNode value: [                                                                                           *
     *                       key: fileName value: [                                                                     *
     *                                             key: content value: [logs]                                           *
     *                                             key: subNode value: [                                                *
     *                                                                  functionName value: [                           *
     *                                                                                       key: content value: [logs] *
     *                                                                                      ]                           *
     *                                            ]                                                                     *
     * ]                                                                                                                *
     * **************************************************************************************************************** */
    NSMutableDictionary *_logDictionary;
    id<FSLogWrapperDelegate> _delegate;
    NSString *_registerFileName;
    NSString *_registerFunctionName;
    FSBLELogInfo *_logInfo;
}

#pragma mark - Life Circle

- (instancetype)initWithLogInfo:(FSBLELogInfo *)info
{
    self = [super init];
    if (self) {
        _logInfo = info;
        _logDictionary = [self addSubNodeIfNeedToDictionary:nil key:nil];
    }
    return self;
}

+ (NSArray *)logsWithOriginalFilePath:(NSURL *)fileURL {
    NSMutableArray *logs = [NSMutableArray array];
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    data = [data subdataWithRange:NSMakeRange(sizeof(struct LOG_HEADER), data.length - sizeof(struct LOG_HEADER))];
    
    FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:data];
    while ([packageIn hasMore]) {
        NSString *className = [packageIn readString];
        UInt32 logLength = [packageIn readUInt32];
        NSData *logData = [packageIn readDataWithLength:logLength];
        Class cls = NSClassFromString(className);
        if (cls) {
            id log = [[cls alloc] init];
            [log BLETransferDecodeWithData:logData];
            [logs addObject:log];
        }
    }
    
    return logs;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _logDictionary = [self addSubNodeIfNeedToDictionary:nil key:nil];
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        NSUInteger pointer = 15;
        
        UInt64 comSize;
        [data getBytes:&comSize range:NSMakeRange(pointer, sizeof(comSize))];
        pointer += sizeof(comSize);
        pointer += comSize;
        
        // header
        UInt64 headSize;
        [data getBytes:&headSize range:NSMakeRange(pointer, sizeof(headSize))];
        pointer += sizeof(headSize);
        
        _logInfo = [[FSBLELogInfo alloc] initWithData:[data subdataWithRange:NSMakeRange(pointer, (NSUInteger)headSize)]];
        pointer += headSize;
        
        
        // body
        UInt64 bodySize;
        [data getBytes:&bodySize range:NSMakeRange(pointer, sizeof(bodySize))];
        pointer += sizeof(bodySize);
        NSData *logData = [data subdataWithRange:NSMakeRange(pointer, (NSUInteger)bodySize)];
        
        FSPackageIn *packageIn = [[FSPackageIn alloc] initWithData:logData];
        while ([packageIn hasMore]) {
            NSString *className = [packageIn readString];
            UInt32 logLength = [packageIn readUInt32];
            NSData *logData = [packageIn readDataWithLength:logLength];
            Class cls = NSClassFromString(className);
            if (cls) {
                id log = [[cls alloc] init];
                [log BLETransferDecodeWithData:logData];
                [self insertLog:log];
            }
        }
    }
    return self;
}

#pragma mark - Private Method

- (NSMutableDictionary *)addSubNodeIfNeedToDictionary:(NSMutableDictionary *)dictionary key:(NSString *)key {
    NSMutableDictionary *subDictionary = [NSMutableDictionary dictionary];
    if (!key || !dictionary[kSUBNODE_KEY][key]) { // if key == nil means add root node
        [dictionary[kSUBNODE_KEY] setObject:subDictionary forKey:key];
        [subDictionary setObject:[NSMutableArray array] forKey:kCONTENT_KEY];
        [subDictionary setObject:[NSMutableDictionary dictionary] forKey:kSUBNODE_KEY];
    }
    return subDictionary;
}

#pragma mark - Public Method

- (void)insertLog:(FSBLELog *)log {
    [_logDictionary[kCONTENT_KEY] addObject:log];
    [self addSubNodeIfNeedToDictionary:_logDictionary key:log.log_fileName];
    [_logDictionary[kSUBNODE_KEY][log.log_fileName][kCONTENT_KEY] addObject:log];
    [self addSubNodeIfNeedToDictionary:_logDictionary[kSUBNODE_KEY][log.log_fileName] key:log.log_functionName];
    [_logDictionary[kSUBNODE_KEY][log.log_fileName][kSUBNODE_KEY][log.log_functionName][kCONTENT_KEY] addObject:log];
    
    if ([_delegate respondsToSelector:@selector(wrapper:didInsertLog:)]) {
        BOOL conditions1 = !_registerFileName && !_registerFunctionName;
        BOOL conditions2 = _registerFileName && !_registerFunctionName && [log.log_fileName isEqualToString:_registerFileName];
        BOOL conditions3 = _registerFileName && _registerFunctionName && [log.log_fileName isEqualToString:_registerFileName] && [log.log_functionName isEqualToString:_registerFunctionName];
        if (conditions1 || conditions2 || conditions3) {
            [_delegate wrapper:self didInsertLog:log];
        }
    }
}

- (NSArray *)registerLogWithDelegate:(id<FSLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName {
    NSAssert(!(!fileName && functionName), @"function name is not nil, file name cannot be nil");
    _delegate = delegate;
    _registerFileName = fileName;
    _registerFunctionName = functionName;
    if (fileName) {
        if (functionName) {
            return _logDictionary[kSUBNODE_KEY][fileName][kSUBNODE_KEY][functionName][kCONTENT_KEY] ?: @[];
        } else {
            return _logDictionary[kSUBNODE_KEY][fileName][kCONTENT_KEY] ?: @[];
        }
    } else {
        return _logDictionary[kCONTENT_KEY] ?: @[];
    }
}


- (NSArray *)registerKeyWithDelegate:(id<FSLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName {
    NSAssert(!(!fileName && functionName), @"function name is not nil, file name cannot be nil");
    _delegate = delegate;
    _registerFileName = fileName;
    _registerFunctionName = functionName;
    if (fileName) {
        if (functionName) {
            return [_logDictionary[kSUBNODE_KEY][fileName][kSUBNODE_KEY][functionName][kSUBNODE_KEY] allKeys];
        } else {
            return [_logDictionary[kSUBNODE_KEY][fileName][kSUBNODE_KEY] allKeys];
        }
    } else {
        return [_logDictionary[kSUBNODE_KEY] allKeys];
    }
}

- (void)writeToFileCallback:(void(^)())callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableData *data = [NSMutableData data];
        
        // bump
        const char bump[15] = {'f', 's', 'l'};
        [data appendBytes:bump length:sizeof(bump)];
        
        // compoment
        Float32 logVersion = 1.0;
        Float64 generateId = [NSDate timeIntervalSinceReferenceDate];
        UInt64 comSize = sizeof(logVersion) + sizeof(generateId);
        
        [data appendBytes:&comSize length:sizeof(comSize)];
        [data appendBytes:&logVersion length:sizeof(logVersion)];
        [data appendBytes:&generateId length:sizeof(generateId)];
        
        // header
        NSData *headerData = [_logInfo logInfo_data];
        UInt64 headSize = headerData.length;
        [data appendBytes:&headSize length:sizeof(headSize)];
        [data appendData:headerData];
        
        // body
        NSMutableData *logData = [NSMutableData data];
        NSArray *logList = _logDictionary[kCONTENT_KEY];
        for (FSBLELog *log in logList) {
            [logData appendData:[log BLETransferEncode]];
        }
        
        UInt64 bodySize = logData.length;
        [data appendBytes:&bodySize length:sizeof(bodySize)];
        [data appendData:logData];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *fileName = [[formatter stringFromDate:_logInfo.log_saveLogDate] stringByAppendingPathExtension:@"fsl"];
        
        NSString *fileFullPath = [FSUtilities FS_LogFilePathWithFileName:fileName UUIDString:_logInfo.log_deviceUUID bundleName:_logInfo.log_bundleName];
        if (![FSUtilities filePathExists:fileFullPath]) {
            [FSUtilities FS_CreatePathIfNeed:[FSUtilities FS_LogPeripheralPath:_logInfo.log_deviceUUID bundleName:_logInfo.log_bundleName]];
            [FSUtilities FS_CreateLogFileIfNeed:fileFullPath];
        }
        
        // save data
        [data writeToFile:fileFullPath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    });
}

@end
