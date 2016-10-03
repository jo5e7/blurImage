//
//  RubberImageViewController.m
//  RubberImage
//
//  Created by Dale Thomas on 10/4/11.
//  Copyright 2011 Scylla Games. All rights reserved.
//  www.scylla-games.com
//  scyllagames@gmail.com
//

#import <QuartzCore/QuartzCore.h>
#import "RubberImageViewController.h"
#import "EAGLView.h"
#import "v2.h"
#import "RubberImage.h"
#import "TouchTrackerView.h"
#import "ClonedView.h"

#import "UIImage+ImageMask.h"
#import "UIBezierPath+Image.h"
#import "UIImage+ScaledImage.h"
#import "UIImage+StackBlur.h"

// *** global variables ***
v2 SCREEN_SIZE = v2(480,320);
v2 IMAGE_SIZE = SCREEN_SIZE*2;
const float GRIDSIZE = 10; 


@interface RubberImageViewController (){
    RubberImage *myRubberImage;
}

@property (nonatomic) int touchRadius;

@property (nonatomic, strong) UIImage       *   clonedImage;
@property (nonatomic, strong) UIImage       *   maskImage;
@property (nonatomic, strong) UIImageView   *   whiteView;

@property (nonatomic, strong) TouchTrackerView  *   trackerView;
@property (nonatomic, retain) EAGLContext       *   context;
@property (nonatomic, assign) CADisplayLink     *   displayLink;

@end

@implementation RubberImageViewController

@synthesize animating, context, displayLink;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)loadView {
    self.view = [[EAGLView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.blurRadio = 15;
    self.blurArray = [[NSMutableArray alloc]init];
}

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;

}

- (void)dealloc
{
    // Tear down context.
    if ([EAGLContext currentContext] == context) [EAGLContext setCurrentContext:nil];
    
    // *** DELETE RUBBER IMAGE OBJECT ***
    delete myRubberImage;

    [context release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)setTouchRadius:(int)radius
{
    _touchRadius = radius;
}

- (GLuint)loadTexture
{
    // *** this code taken from apple's "GLSprite" sample ***
    GLuint texture_handle;

    // Creates a Core Graphics image from an image file
    
    CGSize newSize = [UIScreen mainScreen].bounds.size;
    //To solve status bar height desphase when adding to contentview
    float barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    newSize.height -= barHeight;
    //    CGRect rubberNewFrame = self.rubberController.view.frame;
    //    rubberNewFrame.origin.y += barHeight;

    
    CGImageRef spriteImage = [self.selectedImage imageScaledToSize:newSize].CGImage;
    // Get the width and height of the image
    size_t width = 1024;//CGImageGetWidth(spriteImage);
    size_t height = 1024;//CGImageGetHeight(spriteImage);
    // Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
    // you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.

    if(spriteImage) {
        // Allocated memory needed for the bitmap context
        GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Uses the bitmap creation function provided by the Core Graphics framework. 
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, newSize.width, newSize.height, 8, newSize.width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the sprite image to the context.
        CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, newSize.width, newSize.height), spriteImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(spriteContext);
    
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texture_handle);
        // Bind the texture name. 
        glBindTexture(GL_TEXTURE_2D, texture_handle);
        glTexParameteri( GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        // Release the image data
        free(spriteData);
    
        // Enable use of the texture
        glEnable(GL_TEXTURE_2D);
        // Set a blending function to use
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        // Enable blending
        glEnable(GL_BLEND);
    }
    return texture_handle;
}

- (void)viewDidLoad 
{
    // *** this is ipad ***
    SCREEN_SIZE = v2(1024,768);    
    IMAGE_SIZE = SCREEN_SIZE;
    self.receiveTouches = NO;
    self.cloningArea = NO;
    self.touchRadius = 50;
}

- (void)setSelectedImage:(UIImage *)image
{
    _selectedImage = image;

    // *** load texture ***
    GLuint texture_handle;
    texture_handle = [self loadTexture];
    
    // *** CREATE RUBBER IMAGE OBJECT ***
    myRubberImage = new RubberImage();
    
    // *** set resolution and size of grid ***
    const int num_points_x = (int)(SCREEN_SIZE[0]/GRIDSIZE);
    const int num_points_y = (int)(SCREEN_SIZE[1]/GRIDSIZE);
    myRubberImage->init( num_points_x, num_points_y, SCREEN_SIZE );
    
    // *** load texture and pass handle to rubber image object ***
    myRubberImage->setTextureHandle(texture_handle);
}

- (void)setupTrackerViewWithBool:(BOOL)track FinishBlock:(void(^)(UIBezierPath *))block
{
    if (self.trackerView) {
        [self.trackerView removeFromSuperview];
        self.trackerView = nil;
    }
    if (track) {
        self.trackerView = [[TouchTrackerView alloc] initWithFrame:self.view.bounds];
        self.trackerView.backgroundColor = [UIColor clearColor];
        
        self.trackerView.autoRemoveTrackOnFinish = self.isCloningArea;
        
        [self.trackerView setTrackTouchesFinished:^(UIBezierPath *path) {
            [self.trackerView setHidden:YES];
            if (block) {
                block(path);
            }
            [self.trackerView setHidden:NO];
        }];
        
        [self.trackerView setTrackTouchesInitiated:^{
            if (self.trackTouchesInitiated) {
                self.trackTouchesInitiated();
            }
        }];
        
        [self.view insertSubview:self.trackerView atIndex:1];
        //[self.view bringSubviewToFront:self.trackerView];
        
    }
}

- (void)setCloningArea:(BOOL)cloning
{
    _cloningArea = cloning;
    _whiteningArea = NO;
    [self setupTrackerViewWithBool:cloning FinishBlock:^(UIBezierPath *path) {
        [self cloneImageInPath:path];
    }];
}

- (void)setWhiteningArea:(BOOL)whitening
{
    _whiteningArea = whitening;
    _cloningArea = NO;
    [self setupTrackerViewWithBool:whitening FinishBlock:^(UIBezierPath *path) {
        [self blurImageInPath:path];
    }];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    // Tear down context.
    if ([EAGLContext currentContext] == context) [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (CGRect)updateRectForCurrentScale:(CGRect)bounds
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = bounds;
    
    if (scale > 1.0) {
        
        rect.origin.x = rect.origin.x * 2;
        rect.origin.y = rect.origin.y * 2;
        rect.size.width = rect.size.width * 2;
        rect.size.height = rect.size.height * 2;
        
    }
    
    return rect;
}

- (UIImage *)createSelectedImageFromPath:(UIBezierPath *)path
{
    UIImage * maskImage = [path strokeImageWithColor:[UIColor blackColor]];
    CGSize size = CGSizeMake(1024, 1024);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage * newImage = [UIImage maskImage:image withMask:maskImage];
    
    UIGraphicsBeginImageContext(path.bounds.size);
    CGRect bounds = [self updateRectForCurrentScale:path.bounds];
    
    // Draw new image in current graphics context
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], bounds);
    UIImage *screenImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    
    maskImage = nil; image = nil; newImage = nil;
    
    return screenImage;
}

- (UIImage *)createSelectedBlurImageFromPath:(UIBezierPath *)path
{
    UIImage * maskImage = [path strokeImageWithColor:[UIColor blackColor]];
    CGSize size = CGSizeMake(1024, 1024);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *imagetoBlur = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *blurImage = [imagetoBlur stackBlur:self.blurRadio];
    
    UIImage * newImage = [UIImage maskImage:blurImage withMask:maskImage];
    
    UIGraphicsBeginImageContext(path.bounds.size);
    CGRect bounds = [self updateRectForCurrentScale:path.bounds];
    
    // Draw new image in current graphics context
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], bounds);
    UIImage *screenImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    
    maskImage = nil; blurImage = nil; newImage = nil;
    
    return screenImage;
}

- (void)cloneImageInPath:(UIBezierPath *)path
{
    UIImage *screenImage = [self createSelectedImageFromPath:path];
    ClonedView * cloned = [[ClonedView alloc] initWithClonedImage:screenImage];
    CGRect frame = cloned.frame;
    frame.origin = path.bounds.origin;
    [cloned setFrame:frame];
    
    [self.view addSubview:cloned];
}

- (void)blurImageInPath:(UIBezierPath*)path{
    
    UIImage *screenImage = [self createSelectedBlurImageFromPath:path];
    //UIImage *blurImage = [screenImage stackBlur:15];
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0) {
        
        CGSize newSize = CGSizeMake(screenImage.size.width/2, screenImage.size.height/2);
        screenImage = [self imageWithImage:screenImage scaledToSize:newSize];
    }

    
    UIImageView * blurView = [[UIImageView alloc]initWithImage:screenImage];
    CGRect frame = blurView.frame;
    frame.origin = path.bounds.origin;
    [blurView setFrame:frame];
    //[self.view addSubview:blurView];
    [self.view insertSubview:blurView belowSubview:self.trackerView];
    [self.blurArray addObject:blurView];
    
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setWhiteningFactor:(CGFloat)factor
{
    if (self.whiteView) {
        [self.trackerView clearTrackerPath];
        //Convert the cloned image to CIImage object
        CIImage * ciimage = [CIImage imageWithCGImage:self.clonedImage.CGImage];
        
        CGImageRef ref = NULL;
        
        //Creates a new CIFilter object (this is the one in charge of applying the filter to the image)
        CIFilter *controlsFilter = [CIFilter filterWithName:@"CIColorControls"];
        [controlsFilter setValue:ciimage forKey:kCIInputImageKey];
        [controlsFilter setValue:[NSNumber numberWithFloat:factor]  forKey:kCIInputSaturationKey];
        
        //we get the image with the applied filter
        CIImage * filtered = [controlsFilter outputImage];
        
        //Creates a CIContext in which we will draw the filtered image on
        CIContext *ctext = [CIContext contextWithOptions:nil];
        ref = [ctext createCGImage:filtered fromRect:[filtered extent]];
        
        //Retreive the CGImage from the context
        UIImage * newImg = [UIImage imageWithCGImage:ref];
        
        //Releases the CGImageRef in order to clean memory
        CGImageRelease(ref);
        
        //Finally we mask the filtered image
        UIImage * finalImage = [UIImage maskImage:newImg withMask:self.maskImage];
        [self.whiteView setImage:finalImage];
        
        //Clears all the variables we will no use any longer
        ciimage = nil;
        newImg = nil; finalImage = nil;
        ctext  = nil; controlsFilter = nil;
    }
}

- (void)showImageInPath:(UIBezierPath *)path
{
    UIImage * screenImage = [self createSelectedImageFromPath:path];
    
    UIImage * maskImage = [path strokeImageWithColor:[UIColor blackColor]];
    
    CGRect bounds = [self updateRectForCurrentScale:path.bounds];
    
    CGImageRef maskRef = CGImageCreateWithImageInRect([maskImage CGImage], bounds);
    UIImage *maskForImage = [UIImage imageWithCGImage:maskRef];
    CGImageRelease(maskRef);
    UIGraphicsEndImageContext();
    
    self.clonedImage = screenImage;
    self.maskImage = maskForImage;
    
    UIImage * finalImage = [UIImage maskImage:screenImage withMask:maskForImage];
    
    screenImage = nil;
    maskImage = nil;
    
    self.whiteView = [[UIImageView alloc] initWithImage:finalImage];
    CGRect frame =  [self.view convertRect:path.bounds fromView:self.trackerView];
    [self.whiteView setFrame:frame];
    [self.view addSubview:self.whiteView];
    
    finalImage = nil;
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //glOrthof(1024 - (SCREEN_SIZE[0]*zoomFactor), SCREEN_SIZE[0]*zoomFactor, SCREEN_SIZE[1]*zoomFactor, 768 - (SCREEN_SIZE[1]*zoomFactor), 1, -1);
    glOrthof(0, SCREEN_SIZE[0], SCREEN_SIZE[1], 0, 1, -1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    
    // *** these need only be set in initialisation, but here we read values from sliders every frame ***
    myRubberImage->setElasticity(0.0f);
    myRubberImage->setDamping(10.0f);
    
    // *** every frame, update and draw ***
    myRubberImage->update(1.f/60); // pass in framerate. can get away with fixed value
    myRubberImage->draw();
    
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)prepareForUndoOrRedoAction
{
    RubberImage *rubber     = new RubberImage();
    rubber->_num_points_x   = myRubberImage->_num_points_x;
    rubber->_num_points_y   = myRubberImage->_num_points_y;
    rubber->_texture_handle = myRubberImage->_texture_handle;
    rubber->_elasticity     = myRubberImage->_elasticity;
    rubber->_damping        = myRubberImage->_damping;
    rubber->_vertices       = myRubberImage->_vertices;
    rubber->_index_array    = myRubberImage->_index_array;
    
    [[self.undoManager prepareWithInvocationTarget:self] restoreToPreviousRubber:rubber];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isReceivingTouches) {
        [self prepareForUndoOrRedoAction];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    // *** for any moving touch, use position and velocity to distort rubber image ***
    if (self.isReceivingTouches) {
        for( UITouch *touch in touches){
            CGPoint currentpos = [touch locationInView:touch.view];
            CGPoint previouspos = [touch previousLocationInView:touch.view];
            const v2 position = v2(currentpos.x,currentpos.y);
            const v2 velocity = v2(currentpos.x-previouspos.x,currentpos.y-previouspos.y)*200;
            const float radius = self.touchRadius;//SCREEN_SIZE[1]*0.2f;
            myRubberImage->applySmudgeForce(1.f/60,position,velocity,radius);
        }
    }
}

- (void)restoreToPreviousRubber:(RubberImage *)rubber
{
    [self prepareForUndoOrRedoAction];
    myRubberImage = rubber;
}

@end
