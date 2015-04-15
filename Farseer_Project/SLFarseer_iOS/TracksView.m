//
//  LogoLabel.m
//  SLFarseer_iOS
//
//  Created by Go Salo on 3/1/15.
//  Copyright (c) 2015 Qeekers. All rights reserved.
//

#import "TracksView.h"

#define RADIUS 120.0f

@interface MenuItem : UILabel

@end

@implementation MenuItem

- (instancetype)initWithText:(NSString *)text
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 20)];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.text = text;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightImage:(UIImage *)highlightImage {
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.textColor = [UIColor greenColor];
    } else {
        self.textColor = [UIColor whiteColor];
    }
}

@end

@interface TracksView ()

@property (strong, nonatomic)UIImageView *achor;

@end

@implementation TracksView {
    BOOL touchMoving;
    CGPoint startPoint;
    CGPoint currentPoint;

    NSInteger lastHighlight;
    NSMutableArray *items;
}

- (instancetype)initWithItems:(NSArray *)its
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    lastHighlight = -1;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setItemNames:(NSArray *)itemNames {
    items = [NSMutableArray array];
    for (int index = 0; index < 8; index ++) {
        MenuItem *item = [[MenuItem alloc] initWithText:itemNames[index]];
        item.hidden = YES;
        [self addSubview:item];
        [items addObject:item];
    }
}

- (void)setImage:(UIImage *)image asResponderPosition:(BOOL)as {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (lastHighlight != -1) {
        [items[lastHighlight] setHighlighted:NO];
        lastHighlight = -1;
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
        
        
        [self.achor setCenter:[touch locationInView:self]];
        [self addSubview:self.achor];
        startPoint = [touch locationInView:self];
        [self showMenu:YES];
        touchMoving = YES;
        break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (touchMoving) {
        [self.achor removeFromSuperview];
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

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (touchMoving) {
        [self.achor removeFromSuperview];
        [self showMenu:NO];
        touchMoving = NO;
        lastHighlight = -1;
        
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (touchMoving) {
        for (UITouch *touch in touches) {
            currentPoint = [touch locationInView:self];
            
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
                
                if (lastHighlight != index) {
                    if (lastHighlight != -1) {
                        [items[lastHighlight] setHighlighted:NO];
                    }
                    [items[index] setHighlighted:YES];
                    lastHighlight = index;
                }
            } else {
                if (lastHighlight != -1) {
                    [items[lastHighlight] setHighlighted:NO];
                }
                lastHighlight = -1;
            }
        }
        
        [self setNeedsDisplay];
    }
}

- (void)showMenu:(BOOL)show {
    if (show) {
        for (int index = 0; index < items.count; index ++) {
            MenuItem *item = items[index];
            item.hidden = NO;
            
            [item setCenter:CGPointMake(startPoint.x + cos(index * M_PI / 4) * RADIUS, startPoint.y + sin(index * M_PI / 4) * RADIUS)];
        }
    } else {
        for (int index = 0; index < items.count; index ++) {
            MenuItem *item = items[index];
            item.hidden = YES;
        }
    }
}

- (UIView *)achor {
    if (!_achor) {
        _achor = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _achor.image = [UIImage imageNamed:@"anchor"];
    }
    
    return _achor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (touchMoving) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(ctx, 2);
        CGContextSetRGBStrokeColor(ctx, 0.3, 0.3, 0.3, 1);
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
        
        CGContextStrokePath(ctx);
    }
}

@end
