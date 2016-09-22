//
//  TouchTrackerView.m
//  Dentsio Smile
//
//  Created by Jorge Palacio on 6/17/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import "TouchTrackerView.h"
#import "UIBezierPath-Smoothing.h"


@interface TouchTrackerView(){
    CGPoint pts[5];
    CGPoint initialPoint;
    uint ctr;
    
    
}

@property (nonatomic, assign) BOOL                    touchesDidMoved;

@property (nonatomic, strong) UIBezierPath        *   path;
@property (nonatomic, strong) UIImage             *   incrementalImage;
@property (nonatomic, strong) UIViewController    *   controller;

@end

@implementation TouchTrackerView

@synthesize path;
@synthesize incrementalImage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setupView];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self setMultipleTouchEnabled:NO];
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
}

- (void)setController:(UIViewController *)viewController
{
    _controller = viewController;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    CGFloat dashes[] = {6, 2};
    [path setLineDash:dashes count:2 phase:0];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    [self clearTrackerPath];
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    initialPoint = [touch locationInView:self];
    [path moveToPoint:initialPoint];
    self.touchesDidMoved = NO;
    if (self.trackTouchesInitiated) {
        self.trackTouchesInitiated();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        //[path moveToPoint:pts[0]];
        [path addLineToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    [self setNeedsDisplay];
    self.touchesDidMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    __block UIBezierPath *temppath = self.path;
    self.path = [UIBezierPath new];
    [self setNeedsDisplay];
    if (self.autoRemoveTrackOnFinish) {
        [self clearTrackerPath];
    }
    if (self.touchesDidMoved) {
        if (self.trackTouchesFinished) {
            self.trackTouchesFinished(temppath);
        }
    }
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)clearTrackerPath {
    self.path = [UIBezierPath new];
    [self setNeedsDisplay];
}

@end
