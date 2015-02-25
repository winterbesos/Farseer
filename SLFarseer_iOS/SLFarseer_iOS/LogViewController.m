//
//  LogViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 2/25/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)popGesture:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertLogWithLogNumber:(Byte)logNumber logDate:(NSDate *)logDate logLevel:(Byte)logLevel content:(NSString *)content {
    self.logTextView.text = [self.logTextView.text stringByAppendingString:[NSString stringWithFormat:@"%d %@ %d %@\n", logNumber, logDate, logLevel, content]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
