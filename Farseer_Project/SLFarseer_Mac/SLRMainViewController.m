//
//  MainViewController.m
//  SLFarseer_Mac
//
//  Created by Go Salo on 2/3/15.
//  Copyright (c) 2015 eitdesign. All rights reserved.
//

#import <Farseer_Remote_Mac/Farseer_Remote_Mac.h>
#import <FarseerBase_OSX/FarseerBase_OSX.h>
#import "SLRMainViewController.h"
#import "SLRConfigurationViewController.h"
#import "SLRLogDetailViewController.h"

#define kSELECTED_URL_KEY @"kSELECTED_URL_KEY"

@interface SLRMainViewController () <
                                     NSTableViewDataSource,
                                     NSTableViewDelegate,
                                     ConfigurationViewControllerDelegate
                                    >

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTableView *fileTableView;
@property (weak) IBOutlet NSTableView *logTableView;
@property (strong, nonatomic) NSWindowController *configurationWC;
@property (strong, nonatomic) NSWindowController *logDetailWC;
@property (nonatomic, strong) NSArray *filters;

@end

@implementation SLRMainViewController {
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

- (NSArray *)filterLogs {
    NSMutableArray *filters = [NSMutableArray array];
    for (id log in _logs) {
        [filters addObject:log];
    }
    
    return filters;
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
    SLRConfigurationViewController *configurationVC = (SLRConfigurationViewController *)self.configurationWC.contentViewController;
    [configurationVC loadType:_filterType];
    configurationVC.delegate = self;
    [self.configurationWC showWindow:self];
}

#pragma mark - ConfigurationViewController Delegate

- (void)viewController:(SLRConfigurationViewController *)viewController didSelectedFilterType:(ConfigurationFilterType)type {
    _filterType = type;
    self.filters = [self filterLogs];
    [self.logTableView reloadData];
}

#pragma mark - NSTableView DataSource and Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _fileArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.fileTableView) {
        NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fileArray[row] path] error:&error];
        return [_dateFormatter stringFromDate:attributes[NSFileCreationDate]];
    } else if (tableView == self.logTableView) {
        return [self.filters[row] description];
    }
    
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView == self.fileTableView) {
        _logs = [FSLogWrapper logsWithOriginalFilePath:_fileArray[row]];
        self.filters = [self filterLogs];
        [self.logTableView reloadData];
        return YES;
    } else if (tableView == self.logTableView) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSWindowController *logDetailWC = [storyboard instantiateControllerWithIdentifier:@"SLRLogDetailWindowController"];
        SLRLogDetailViewController *logDetailVC = (SLRLogDetailViewController *)[logDetailWC contentViewController];
        [logDetailVC setupLog:self.filters[row]];
        self.logDetailWC = logDetailWC;
        [logDetailWC showWindow:self];
        
        return YES;
    }
    
    return NO;
}

@end
