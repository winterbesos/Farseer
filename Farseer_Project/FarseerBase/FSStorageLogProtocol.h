//
//  FSStorageLogProtocol.h
//  SLFarseer
//
//  Created by Salo on 16/3/18.
//  Copyright © 2016年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSStorageLogProtocol <NSObject>

- (NSData *)storageEncode;
- (void)storageDecodeWithData:(NSData *)data;

@optional
- (void)log_print;
- (void)log_printToConsole;

@end
