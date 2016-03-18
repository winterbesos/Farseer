//
//  ViewController.m
//  FarseerMonitor
//
//  Created by Go Salo on 15/8/25.
//  Copyright (c) 2015年 eitdesign. All rights reserved.
//

#import "ViewController.h"
#import <Farseer_Mac/Farseer_Mac.h>
#import <FarseerBase_OSX/FarseerBase_OSX.h>

@interface ViewController ()

@property (weak) IBOutlet NSTextField *frequencyLabel;

@end

@implementation ViewController {
    NSTimer *_timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(testLog) userInfo:nil repeats:YES];
    openBLEDebug(^(NSError *error) {
        if (!error) {
        }
    });
    cleanLogBefore([NSDate dateWithTimeIntervalSinceNow:-100]);
}

#pragma mark - Private Method

- (void)testLog {
    int ran = arc4random() % 2;
    switch (ran) {
        case 0: {
//            FSRelationOperation *operation = [[FSRelationOperation alloc] initWithFromNodeName:@"UIViewController" toNodeName:@"VSViewController"];
//            FSSendLog(operation);
        }
            break;
        case 1: {
            FSLogLevel level = arc4random() % 4;
            switch (level) {
                case FSLogLevelLog:
                    FSLog(@"log level");
                    break;
                case FSLogLevelError:
                    FSError(kDefaultLogCode, @"error level", @{@"response" : [NSData data]});
                    break;
                case FSLogLevelFatal:
                    FSFatal(@"fatal level");
                    break;
                case FSLogLevelMinor:
                    FSMinor(@"minor level");
                    break;
                case FSLogLevelWarning:
                    FSWarning(@"warning level");
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
    
}

#pragma mark - Action

- (IBAction)frequencySliderAction:(NSSlider *)sender {
    [_timer invalidate];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:sender.doubleValue target:self selector:@selector(testLog) userInfo:nil repeats:YES];
    self.frequencyLabel.stringValue = [NSString stringWithFormat:@"%.2fs", sender.doubleValue];
}

@end
