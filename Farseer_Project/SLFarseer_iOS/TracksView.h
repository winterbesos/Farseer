//
//  LogoLabel.h
//  SLFarseer_iOS
//
//  Created by Go Salo on 3/1/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TracksView;

@protocol TracksViewDelegate <NSObject>

- (void)tracksView:(TracksView *)TracksView didSelectItemAtIndex:(NSInteger)index;

@end

@interface TracksView : UIView

@property (nonatomic, weak)IBOutlet id<TracksViewDelegate> delegate;

- (void)setItemNames:(NSArray *)itemNames;
- (void)setImageItems:(NSArray *)imageItems;

@end
