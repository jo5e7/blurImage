//
//  RubberImageViewController.h
//  RubberImage
//
//  Created by Dale Thomas on 10/4/11.
//  Copyright 2011 Scylla Games. All rights reserved.
//  www.scylla-games.com
//  scyllagames@gmail.com
//
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface RubberImageViewController : UIViewController {
@private
    EAGLContext *context;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
}

@property (nonatomic, getter = isCloningArea)       BOOL    cloningArea;
@property (nonatomic, getter = isWhiteningArea)     BOOL    whiteningArea;
@property (nonatomic, getter=isReceivingTouches)    BOOL    receiveTouches;
@property (readonly, nonatomic, getter=isAnimating) BOOL    animating;
@property (nonatomic) NSInteger                             animationFrameInterval;
@property (nonatomic, strong) UIImage   *                   selectedImage;

@property (nonatomic, copy) void (^trackTouchesInitiated)();

//Blur radio
@property int blurRadio;
@property (strong, nonatomic) NSMutableArray *blurArray;

- (void)startAnimation;
- (void)stopAnimation;

- (void)setTouchRadius:(int)radius;
- (void)setWhiteningFactor:(CGFloat)factor;

@end
