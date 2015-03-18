//
//  FSLogManager+Central.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/18.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FSLogManager.h"

@interface FSLogManager (Central)

- (void)saveLog:(NSArray *)logs peripheral:(CBPeripheral *)peripheral bundleName:(NSString *)bundleName callback:(void(^)(float percentage))callback;

@end
