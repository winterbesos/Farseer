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
@property (weak) IBOutlet NSTableView *logTableView;

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

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
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
    if (tableView == self.fileTableView) {
        return _fileArray.count;
    } else {
        return _logs.count;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.fileTableView) {
        NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fileArray[row] path] error:&error];
        return attributes[NSFileCreationDate];
    } else {
        return [_logs[row] description];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView == self.fileTableView) {
        _logs = [FSLogWrapper logsWithOriginalFilePath:_fileArray[row]];
        [self.logTableView reloadData];
        return YES;
    }
    
    return YES;
}

@end
