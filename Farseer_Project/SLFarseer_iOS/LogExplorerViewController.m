//
//  LogExplorerViewController.m
//  SLFarseer
//
//  Created by Go Salo on 15/4/1.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "LogExplorerViewController.h"
#import <objc/runtime.h>
#import "LogViewController.h"

static char AssociateLogArrayHandel;

@interface LogExplorerViewController ()

@end

@implementation LogExplorerViewController {
    NSMutableDictionary *_contentDictionary;
    NSArray *_keyPath;
    LogExplorerViewController *_sublogExplorerVC;
    LogViewController *_logViewController;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentDictionary = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(_contentDictionary, &AssociateLogArrayHandel, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN);
    _keyPath = @[@"log_fileName", @"log_functionName", @"log_content"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _logViewController = nil;
}

#pragma mark - Public Method

- (void)loadWithLogKeyPath:(NSArray *)keyPath dictionary:(NSDictionary *)dictionary {
    _keyPath = keyPath;
    _contentDictionary = [dictionary mutableCopy];
}

- (void)insertLog:(FSBLELog *)log {
    NSMutableArray *logArray = objc_getAssociatedObject(_contentDictionary, &AssociateLogArrayHandel);
    [logArray addObject:log];
    
    if ([self insertLog:log toContentDictionary:_contentDictionary keyPath:_keyPath]) {
        [self.tableView reloadData];
    };
    
    NSString *pathValue = [log valueForKey:_keyPath.firstObject];
    if ([_sublogExplorerVC.pathValue isEqualToString:pathValue]) {
        [_sublogExplorerVC insertLog:log];
    }
    
    if ([_logViewController.pathValue isEqualToString:pathValue]) {
        [_logViewController insertLogWithLog:log];
    }
    
}

- (BOOL)insertLog:(FSBLELog *)log toContentDictionary:(NSMutableDictionary *)dictionary keyPath:(NSArray *)keyPath {
    NSString *subPath = [log valueForKey:keyPath[0]];
    
    BOOL hasNewData = NO;
    if (!dictionary[subPath]) {
        [dictionary setObject:[NSMutableDictionary dictionary] forKey:subPath];
        hasNewData = YES;
    }
    
    NSMutableDictionary *logDictionary = dictionary[subPath];
    if (keyPath.count >= 2) {
        [self insertLog:log toContentDictionary:logDictionary keyPath:[keyPath subarrayWithRange:NSMakeRange(1, keyPath.count - 1)]];
    }
    
    NSMutableArray *logArray = objc_getAssociatedObject(logDictionary, &AssociateLogArrayHandel);
    if (!logArray) {
        logArray = [NSMutableArray array];
        objc_setAssociatedObject(logDictionary, &AssociateLogArrayHandel, logArray, OBJC_ASSOCIATION_RETAIN);
    }
    
    return hasNewData;
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
//    if (_keyPath.count >= 2) {
//        _sublogExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogExplorerViewController"];
//        [_sublogExplorerVC loadWithLogKeyPath:[_keyPath subarrayWithRange:NSMakeRange(1, _keyPath.count - 1)] dictionary:_contentDictionary[[_contentDictionary allKeys][indexPath.row]]];
//        [self.navigationController pushViewController:_sublogExplorerVC animated:YES];
//    }
    
    _logViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogViewController"];
    NSDictionary *subDictionary = _contentDictionary[[_contentDictionary allKeys][indexPath.row]];
    [_logViewController loagWithLogs:objc_getAssociatedObject(subDictionary, &AssociateLogArrayHandel) pathValue:[_contentDictionary allKeys][indexPath.row]];
    [self.navigationController pushViewController:_logViewController animated:YES];
}

@end
