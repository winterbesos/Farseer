//
//  FilePreviewViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/8/25.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "FilePreviewViewController.h"
#import <Farseer_Remote_iOS/Farseer_Remote_iOS.h>

@interface FilePreviewViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation FilePreviewViewController {
    NSString *_name;
    NSString *_size;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileNameLabel.text = _name;
    self.fileSizeLabel.text = _size;
}

#pragma mark - Public Method

- (void)setFileInfo:(NSDictionary *)info filePath:(NSString *)filePath {
    _name = info[@"name"];
    _size = [NSString stringWithFormat:@"%@Byte", info[@"size"]];
    self.fileNameLabel.text = _name;
    self.fileSizeLabel.text = _size;
    
    getSandBoxFile(filePath);
//    // TODO: 当前用notif传输文件效率过低
//    [FSBLECentralService getSandBoxFileWithPath:filePath callback:^(float progress, id object) {
//        self.progressView.progress = progress;
//        if (progress == 1) {
//            UIImage *image = [UIImage imageWithData:object scale:[UIScreen mainScreen].scale];
//            self.imageView.image = image;
//            self.imageView.frame = CGRectMake(100, 120, image.size.width, image.size.height);
//        }
//    }];
}

@end
