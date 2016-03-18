//
//  FSBLELogProtocol.h
//  SLFarseer
//
//  Created by Salo on 15/10/17.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSBLELogProtocol <NSObject>

@required
@property (nonatomic)UInt32 sequence;
- (NSData *)BLETransferEncode;
- (void)BLETransferDecodeWithData:(NSData *)data;

@end
