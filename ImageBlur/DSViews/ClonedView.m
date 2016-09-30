//
//  ClonedView.m
//  Dentsio Smile
//
//  Created by Jorge Palacio on 6/24/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import "ClonedView.h"

@interface ClonedView()<UIGestureRecognizerDelegate>

@property (nonatomic, getter = gesturesAreLocked) BOOL      locked;
@property (nonatomic) CGFloat                               firstX, firstY, flipValue;
@property (nonatomic, strong) UIImage                   *   clonedImage;
@property (nonatomic, weak) IBOutlet  UIView          *   container;
@property (nonatomic, weak) IBOutlet  UIButton        *   flipButton;
@property (nonatomic, weak) IBOutlet  UIButton        *   lockButton;
@property (nonatomic, weak) IBOutlet  UIButton        *   deleteButton;
@property (nonatomic, weak) IBOutlet  UIImageView     *   clonedView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray   *   assetsViewsArray;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ClonedView
void *ClonedViewTransform = &ClonedViewTransform;
@synthesize locked;
@synthesize firstX, firstY, flipValue;
@synthesize clonedImage;
@synthesize container;
@synthesize flipButton;
@synthesize lockButton;
@synthesize deleteButton;
@synthesize clonedView;
@synthesize assetsViewsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (id)initWithClonedImage:(UIImage *)image
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect frame = CGRectMake(0, 0, image.size.width + 44, image.size.height + 44);
    
    if (scale > 1.0) {
        CGSize imageSize = image.size;
        imageSize.height = (imageSize.height / 2) + 44;
        imageSize.width  = (imageSize.width / 2) + 44;
        frame.size = imageSize;
    }
    frame.origin.x -= 22;
    frame.origin.y -= 22;
    if ((self  = [self initWithFrame:frame])) {
        clonedImage = image;
        [clonedView setImage:clonedImage];
        static int tag;
        tag++;
        self.tag = tag;
    }
    return self;
}

- (void)initializeSubviews
{
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    [container setFrame:self.bounds];
    [clonedView setFrame:self.bounds];
    [self addSubview:container];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(moveView:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(scaleView:)];
	[pinchRecognizer setDelegate:self];
	[self addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer * rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(rotateView:)];
    [rotationGesture setDelegate:self];
    [self addGestureRecognizer:rotationGesture];
    
    UITapGestureRecognizer  * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(tapView:)];
    [tapRecognizer setNumberOfTapsRequired:2];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    [self addGestureRecognizer:tapRecognizer];
    
    flipValue = -1.0;
    
    self.autoresizingMask = UIViewAutoresizingNone;
    self.autoresizesSubviews = NO;
    self.clipsToBounds = NO;
    [self addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:ClonedViewTransform];
}

- (void)shouldHideAssets:(BOOL)should
{
    [deleteButton setHidden:should];
    [flipButton setHidden:should];
    [lockButton setHidden:should];
    for (UIImageView * assetView in assetsViewsArray) {
        [assetView setHidden:should];
    }
}

- (void)setImage:(UIImage *)image
{
    clonedImage = image;
    [clonedView setImage:image];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"transform"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == ClonedViewTransform) {
        for (UIView *view in self.containerView.subviews) {
            if (![view isEqual:self.clonedView] && ![view isEqual:self.backgroundImageView]) {
                view.transform = CGAffineTransformInvert(self.transform);
            }
        }
    }
}

#pragma mark - UIGestureRecognizer Actions

- (void)moveView:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:self.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        firstX = [[gesture view] center].x;
		firstY = [[gesture view] center].y;
    }
    
    CGPoint translatedPoint = CGPointMake(firstX+point.x, firstY+point.y);
    
    [self setCenter:translatedPoint];
}

- (void)scaleView:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CGFloat scale = pinchRecognizer.scale;
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
    pinchRecognizer.scale = 1.0;
}

- (void)rotateView:(UIRotationGestureRecognizer *)recognizer
{
    CGAffineTransform transform = CGAffineTransformRotate(self.clonedView.transform, recognizer.rotation);
    self.clonedView.transform = transform;
    recognizer.rotation = 0;
}

- (void)tapView:(UITapGestureRecognizer *)tapRecognizer
{
    [self lockContainerView:flipButton];
}

#pragma mark - IBActions Methods

- (IBAction)flipClonedImage:(UIButton *)sender
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.clonedView.transform = CGAffineTransformScale(transform, flipValue, 1);
    flipValue = flipValue * -1;
}

- (IBAction)lockContainerView:(UIButton *)sender
{
    [sender setSelected:!sender.isSelected];
    locked = sender.isSelected;
    [self shouldHideAssets:locked];
}

- (IBAction)deleteClonedImage:(UIButton *)sender
{
    [self removeFromSuperview];
}

#pragma mark - UIGestureRecognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.gesturesAreLocked && ![gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
