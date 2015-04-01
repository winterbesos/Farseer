//
//  LogExplorerViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogExplorerViewController.h"

@interface LogExplorerViewController ()

@end

@implementation LogExplorerViewController {
    NSMutableDictionary *_fileDictionary;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _fileDictionary = [NSMutableDictionary dictionary];
}

#pragma mark - Public Method

- (void)insertLog:(FSBLELog *)log {
    BOOL newFile = NO;
    if (!_fileDictionary[log.log_fileName]) {
        [_fileDictionary setObject:[NSMutableDictionary dictionary] forKey:log.log_fileName];
        newFile = YES;
    }
    
    NSMutableDictionary *logDictionary = _fileDictionary[log.log_fileName];
    [logDictionary setObject:log forKey:log.log_fileName];
    
    if (newFile) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExplorerCell" forIndexPath:indexPath];
    cell.textLabel.text = [_fileDictionary allKeys][indexPath.row];
    return cell;
}

@end
