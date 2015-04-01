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
    NSMutableDictionary *_contentDictionary;
    NSArray *_keyPath;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentDictionary = [NSMutableDictionary dictionary];
}

#pragma mark - Public Method

- (void)loadWithLogKeyPath:(NSArray *)keyPath dictionary:(NSDictionary *)dictionary {
    _keyPath = keyPath;
    _contentDictionary = [dictionary mutableCopy];
}

- (void)insertLog:(FSBLELog *)log {
    BOOL newFile = NO;
    if (!_contentDictionary[log.log_fileName]) {
        [_contentDictionary setObject:[NSMutableDictionary dictionary] forKey:log.log_fileName];
        newFile = YES;
    }
    
    NSMutableDictionary *logDictionary = _contentDictionary[log.log_fileName];
    [logDictionary setObject:log forKey:log.log_fileName];
    
    if (newFile) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExplorerCell" forIndexPath:indexPath];
    cell.textLabel.text = [_contentDictionary allKeys][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LogExplorerViewController *logExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogExplorerViewController"];
    [logExplorerVC loadWithLogKeyPath:[_keyPath subarrayWithRange:NSMakeRange(1, _keyPath.count - 1)] dictionary:[_contentDictionary allKeys][indexPath.row]];
    [self.navigationController pushViewController:logExplorerVC animated:YES];
}

@end
