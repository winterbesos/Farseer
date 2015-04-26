//
//  SLLogWrapper.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "SLLogWrapper.h"
#import "FSBLELog.h"
#import "FSBLELogInfo.h"

#define kCONTENT_KEY @"kCONTENT_KEY"
#define kSUBNODE_KEY @"kSUBNODE_KEY"

@implementation SLLogWrapper {
    /* ******************************************************************************************************************
     * [                                                                                                                *
     *  key: content value: [logs]                                                                                      *
     *  key: subNode value: [                                                                                           *
     *                       key: fileName value: [                                                                     *
     *                                             key: content value: [logs]                                           *
     *                                             key: subNode value: [                                                *
     *                                                                  functionName value: [                           *
     *                                                                                       key: content value: [logs] *
     *                                                                                      }                           *
     *                                            ]                                                                     *
     * ]                                                                                                                *
     * ******************************************************************************************************************/
    NSMutableDictionary *_logDictionary;
    id<SLLogWrapperDelegate> _delegate;
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

- (NSArray *)registerLogWithDelegate:(id<SLLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName {
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


- (NSArray *)registerKeyWithDelegate:(id<SLLogWrapperDelegate>)delegate fileName:(NSString *)fileName functionName:(NSString *)functionName {
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

- (void)writeToFileCallback:(void(^)(float percentage))callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fileName = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        
        NSArray *totalLogs = _logDictionary[kCONTENT_KEY];
        for (FSBLELog *log in totalLogs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUInteger index = [totalLogs indexOfObject:log];
                if (index % 50 == 0) {
                    callback(1.0 * index / totalLogs.count);
                }
            });
            
            // TODO: UUID
//            [self inputLog:log UUIDString:@"UUID" bundleName:_logInfo.log_bundleName fileName:fileName];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(1);
        });
    });
}

@end
