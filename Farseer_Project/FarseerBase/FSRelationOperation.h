//
//  FSRelationOperation.h
//  SLFarseer
//
//  Created by Salo on 15/10/23.
//  Copyright © 2015年 Qeekers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBLELogProtocol.h"

@interface FSRelationOperation : NSObject <FSBLELogProtocol>

@property (nonatomic, copy)NSString *fromNodeName;
@property (nonatomic, copy)NSString *toNodeName;
@property (nonatomic)UInt32 sequence;

- (instancetype)initWithFromNodeName:(NSString *)fromNodeName toNodeName:(NSString *)toNodeName;

@end
