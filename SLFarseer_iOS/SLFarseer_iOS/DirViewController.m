//
//  DirViewController.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 15/3/5.
//  Copyright (c) 2015年 Qeekers. All rights reserved.
//

#import "DirViewController.h"
#import "FSLogManager.h"

@interface DirViewController ()

@end

@implementation DirViewController {
    NSArray *_contents;
    NSString *_path;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_path == nil) {
        assert(false);
    } else {
        _contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:nil];
    }
}

- (void)setPath:(NSString *)path {
    _path = path;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _contents[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DirViewController *dirVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DirViewController"];
    [dirVC setPath:[_path stringByAppendingPathComponent:_contents[indexPath.row]]];
    [self.navigationController pushViewController:dirVC animated:YES];
}

@end
