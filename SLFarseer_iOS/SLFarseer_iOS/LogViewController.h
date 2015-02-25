//
//  LogViewController.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController

- (void)insertLogWithLogNumber:(Byte)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content ;

@end
