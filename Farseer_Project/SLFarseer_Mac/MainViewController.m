//
//  MainViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 eitdesign. All rights reserved.
//

#import "MainViewController.h"
#import "ConfigurationViewController.h"
#import <Farseer_Remote_Mac/Farseer_Remote_Mac.h>
#import <FarseerBase_OSX/FarseerBase_OSX.h>

#define kSELECTED_URL_KEY @"kSELECTED_URL_KEY"

@interface MainViewController () <NSTableViewDataSource, NSTableViewDelegate, ConfigurationViewControllerDelegate>

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTableView *fileTableView;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (strong, nonatomic) NSWindowController *configurationWC;

@end

@implementation MainViewController {
    NSArray *_fileArray;
    NSArray *_logs;
    
    ConfigurationFilterType _filterType;
    NSDateFormatter *_dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    _filterType = ConfigurationFilterTypeAll;
    
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:kSELECTED_URL_KEY];
    if (url) {
        self.pathControl.URL = url;
        
        NSError *error;
        _fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.pathControl.URL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    }
}

#pragma mark - Private Method

- (void)filterLogs {
    NSMutableString *logString = [NSMutableString string];
    for (id log in _logs) {
        [logString appendFormat:@"%@\n", log];
    }
    self.logTextView.string = logString;
}

#pragma mark - Properties

- (NSWindowController *)configurationWC {
    if (_configurationWC == nil) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSWindowController *configurationWC = [storyboard instantiateControllerWithIdentifier:@"ConfigurationWindowController"];
        _configurationWC = configurationWC;
    }
    
    return _configurationWC;
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

- (IBAction)filterButtonAction:(id)sender {
    ConfigurationViewController *configurationVC = (ConfigurationViewController *)self.configurationWC.contentViewController;
    [configurationVC loadType:_filterType];
    configurationVC.delegate = self;
    [self.configurationWC showWindow:self];
}

#pragma mark - ConfigurationViewController Delegate

- (void)viewController:(ConfigurationViewController *)viewController didSelectedFilterType:(ConfigurationFilterType)type {
    _filterType = type;
    [self filterLogs];
}

#pragma mark - NSTableView DataSource and Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _fileArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fileArray[row] path] error:&error];
    return [_dateFormatter stringFromDate:attributes[NSFileCreationDate]];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    _logs = [FSLogWrapper logsWithOriginalFilePath:_fileArray[row]];
    [self filterLogs];
    return YES;
}

@end
