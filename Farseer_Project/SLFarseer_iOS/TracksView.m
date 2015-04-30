//
//  LogoLabel.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 3/1/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "TracksView.h"

#define RADIUS 80.0f

@interface ImageMenuItem : UIImageView

@end

@implementation ImageMenuItem

- (instancetype)initWithImage:(UIImage *)image highlightImage:(UIImage *)highlightImage {
    self = [super initWithImage:image highlightedImage:highlightImage];
    if (self) {
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

@end

@interface BackgroundView : UIView

@end

@implementation BackgroundView {
    NSInteger _selectedIndex;
    UILabel *_selectedNameLabel;
    NSArray *_itemNames;
}

- (instancetype)initWithFrame:(CGRect)frame itemNames:(NSArray *)itemNames
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _itemNames = itemNames;
        _selectedNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height / 2 - 10, frame.size.width, 20)];
        _selectedNameLabel.textAlignment = NSTextAlignmentCenter;
        _selectedNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_selectedNameLabel];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (_selectedIndex != -1) {
        CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        
        CGFloat startAngle = _selectedIndex * M_PI_4 - M_PI / 8;
        CGFloat endAngle = startAngle + M_PI_4;
        
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:38 / 255.0 alpha:1].CGColor);

        CGContextAddArc(ctx, centerPoint.x, centerPoint.y, RADIUS * 1.41, endAngle, startAngle, 1);
        CGContextAddArc(ctx, centerPoint.x, centerPoint.y, RADIUS * 1.41 / 2, startAngle, endAngle, 0);
        CGContextClosePath(ctx);
        
        CGContextFillPath(ctx);
    }
}

- (void)selectIndex:(NSInteger)index {
    if (_selectedIndex != index) {
        _selectedIndex = index;
        
        if (index != -1) {
            _selectedNameLabel.text = _itemNames[index];
        } else {
            _selectedNameLabel.text = @"";
        }
        [self setNeedsDisplay];
    }
}

@end

@interface TracksView ()

@property (strong, nonatomic)UIVisualEffectView *effectView;

@end

@implementation TracksView {
    BOOL touchMoving;
    CGPoint startPoint;
    CGPoint currentPoint;

    NSInteger lastHighlight;
    NSMutableArray *items;
    BackgroundView *_backgroundView;
}

- (void)setImageItems:(NSArray *)imageItems highlightItemImages:(NSArray *)highlightImageItems itemNames:(NSArray *)itemNames {
    _backgroundView = [[BackgroundView alloc] initWithFrame:self.effectView.bounds itemNames:itemNames];
    [self.effectView addSubview:_backgroundView];
    
    items = [NSMutableArray array];
    for (int index = 0; index < 8; index ++) {
        ImageMenuItem *item = [[ImageMenuItem alloc] initWithImage:imageItems[index] highlightImage:highlightImageItems[index]];
        item.hidden = YES;
        [self addSubview:item];
        [items addObject:item];
    }
}

- (void)displayWithLocation:(CGPoint)location {
    if (lastHighlight != -1) {
        [items[lastHighlight] setHighlighted:NO];
        lastHighlight = -1;
        [_backgroundView selectIndex:-1];
    }
    
    startPoint = location;
    [self showMenu:YES];
    touchMoving = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (lastHighlight != -1) {
        [items[lastHighlight] setHighlighted:NO];
        lastHighlight = -1;
        [_backgroundView selectIndex:-1];
    }
    
    for (UITouch *touch in touches) {
        /*
        CGPoint touchLocation = [touch locationInView:self];
        if (touchLocation.x < RADIUS + 50
            ||
            touchLocation.x > self.frame.size.width - RADIUS - 50
            ||
            touchLocation.y > self.frame.size.height - RADIUS - 50
            ||
            touchLocation.y < RADIUS + 50) {
            return;
        }
         */
        
        startPoint = [touch locationInView:self];
        [self showMenu:YES];
        touchMoving = YES;
        break;
    }
}


- (void)touchesEnded {
    if (touchMoving) {
        [self showMenu:NO];
        touchMoving = NO;
        
        if (lastHighlight != -1) {
            if ([self.delegate respondsToSelector:@selector(tracksView:didSelectItemAtIndex:)]) {
                [self.delegate tracksView:self didSelectItemAtIndex:lastHighlight];
            }
        }
        
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled {
    if (touchMoving) {
        [self showMenu:NO];
        touchMoving = NO;
        lastHighlight = -1;
        
        [self setNeedsDisplay];
    }
}

- (void)touchesMovedToLocation:(CGPoint)location {
    
    if (touchMoving) {
        currentPoint = location;
        
        CGFloat distance = sqrt((currentPoint.x - startPoint.x) * (currentPoint.x - startPoint.x) + (currentPoint.y - startPoint.y) * (currentPoint.y - startPoint.y));
        if (distance > RADIUS) {
            int index = 0;
            CGFloat cx = (currentPoint.x - startPoint.x), cy = (currentPoint.y - startPoint.y);
            double radian = atan(cx / cy);
            if (cy <= 0 && cx <= 0) {
                if (radian < M_PI_4 / 2) {
                    index = 6;
                } else if (radian < M_PI_4 / 2 * 3) {
                    index = 5;
                } else {
                    index = 4;
                }
            } else if (cy >= 0 && cx <= 0) {
                if (-radian < M_PI_4 / 2) {
                    index = 2;
                } else if (-radian < M_PI_4 / 2 * 3) {
                    index = 3;
                } else {
                    index = 4;
                }
            } else if (cy <= 0 && cx >= 0) {
                if (-radian < M_PI_4 / 2) {
                    index = 6;
                } else if (-radian < M_PI_4 / 2 * 3) {
                    index = 7;
                } else {
                    index = 0;
                }
            } else if (cy >= 0 && cx >= 0) {
                if (radian < M_PI_4 / 2) {
                    index = 2;
                } else if (radian < M_PI_4 / 2 * 3) {
                    index = 1;
                } else {
                    index = 0;
                }
            }
            
            [_backgroundView selectIndex:index];
            
            if (lastHighlight != index) {
                if (lastHighlight != -1) {
                    [items[lastHighlight] setHighlighted:NO];
                }
                [items[index] setHighlighted:YES];
                lastHighlight = index;
            }
        } else {
            [_backgroundView selectIndex:-1];
            if (lastHighlight != -1) {
                [items[lastHighlight] setHighlighted:NO];
            }
            lastHighlight = -1;
        }
        
        [self setNeedsDisplay];
    }
}

- (void)showMenu:(BOOL)show {
    if (show) {
        self.effectView.center = startPoint;
        [self addSubview:self.effectView];
        [self sendSubviewToBack:self.effectView];
        
        for (int index = 0; index < items.count; index ++) {
            ImageMenuItem *item = items[index];
            item.hidden = NO;
            
            [item setCenter:CGPointMake(startPoint.x + cos(index * M_PI / 4) * RADIUS, startPoint.y + sin(index * M_PI / 4) * RADIUS)];
        }
    } else {
        for (int index = 0; index < items.count; index ++) {
            ImageMenuItem *item = items[index];
            item.hidden = YES;
        }
        [self.effectView removeFromSuperview];
    }
}


#pragma mark - Properties 

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.frame = CGRectMake(0, 0, RADIUS * 2 * 1.4, RADIUS * 2 * 1.4);
        _effectView.layer.cornerRadius = _effectView.bounds.size.width / 2;
        _effectView.layer.masksToBounds = YES;
    }
    
    return _effectView;
}

@end