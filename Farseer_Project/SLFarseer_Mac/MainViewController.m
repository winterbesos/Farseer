//
//  MainViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 eitdesign. All rights reserved.
//

#import "MainViewController.h"
#import <Farseer_Remote_Mac/Farseer_Remote_Mac.h>

#define kSELECTED_URL_KEY @"kSELECTED_URL_KEY"

@interface MainViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTableView *fileTableView;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation MainViewController {
    NSArray *_fileArray;
    NSArray *_logs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:kSELECTED_URL_KEY];
    if (url) {
        self.pathControl.URL = url;
        
        NSError *error;
        _fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.pathControl.URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    }
}

#pragma mark - Actions

- (IBAction)selectFileButtonAction:(id)sender {
    NSOpenPanel *openDlg = [[NSOpenPanel alloc] init];
    openDlg.canChooseFiles = NO;
    openDlg.canChooseDirectories = YES;
    if ([openDlg runModal] == NSModalResponseOK) {

        NSArray *files = openDlg.URLs;
        self.pathControl.URL = files.firstObject;
        
        NSError *error;
        _fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.pathControl.URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        [self.fileTableView reloadData];
        
        [[NSUserDefaults standardUserDefaults] setURL:self.pathControl.URL forKey:kSELECTED_URL_KEY];
    }
}

#pragma mark - NSTableView DataSource and Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _fileArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fileArray[row] path] error:&error];
    return attributes[NSFileCreationDate];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    _logs = [FSLogWrapper logsWithOriginalFilePath:_fileArray[row]];
    NSMutableString *logString = [NSMutableString string];
    for (FSBLELog *log in _logs) {
        [logString appendFormat:@"%@\n", log];
    }
    self.logTextView.string = logString;
    return YES;
}

@end
