//
//  ViewController.m
//  ImageBlur
//
//  Created by Jose Maestre on 17/09/16.
//  Copyright © 2016 Jose Maestre. All rights reserved.
//


#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+StackBlur.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.originalImage = [UIImage imageNamed:@"imagen"];
    //self.mainImage.image = self.originalImage;
    
    
    [self initBlurResouces];
    [self initRubberResouces];

    CGFloat scale = [UIScreen mainScreen].scale;
    NSLog(@" %f", scale);
    
    [self setupTrackerViewWithBool:true FinishBlock:^(UIBezierPath *path) {
    
        UIImage *mask = [[UIImage alloc]init];
        mask = [self createMaskFromPath:path];
        UIImage *image = [[UIImage alloc]init];
        image = [self createImageFromPath:path];
        
        UIImage *maskedImage = [[UIImage alloc]init];
        maskedImage = [self maskImage:image withMask:mask];
        
        UIImageView *iv = [[UIImageView alloc]initWithImage:maskedImage];
        CGPoint centre = CGPointMake(path.bounds.origin.x, path.bounds.origin.y);
        [iv setCenter:centre];
        
        CGRect newFrame = iv.frame;
        newFrame = path.bounds;
        iv.frame = newFrame;
        
        [self.contentView addSubview:iv];
        [self.blurArray addObject:iv];
        }];
}

- (void)setupTrackerViewWithBool:(BOOL)track FinishBlock:(void(^)(UIBezierPath *))block
{
    if (self.trackerView) {
        [self.trackerView removeFromSuperview];
        self.trackerView = nil;
    }
    if (track) {
        self.trackerView = [[TouchTrackerView alloc] initWithFrame:self.contentView.bounds];
        self.trackerView.backgroundColor = [UIColor clearColor];
        
        self.trackerView.autoRemoveTrackOnFinish = true;
        
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
        
        //To solve status bar height desphase when adding to contentview
        float barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect trackerNewFrame = self.trackerView.frame;
        trackerNewFrame.origin.y += barHeight;
        self.trackerView.frame = trackerNewFrame;
        
        //Add trackerview
        //[self.view addSubview:self.trackerView];
        [self.view insertSubview:self.trackerView aboveSubview:self.contentView];
    }
}

- (UIImage*)createMaskFromPath:(UIBezierPath*)path{

    UIView *view = [[UIView alloc] initWithFrame:self.contentView.bounds];
    view.backgroundColor = [UIColor whiteColor];
    UIGraphicsBeginImageContext(self.contentView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddPath(context, path.CGPath);
    [path fill];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], path.bounds);
    UIImage *screenImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return screenImage;
}


- (UIImage*)createImageFromPath:(UIBezierPath*)path{
    
    UIGraphicsBeginImageContext(self.contentView.bounds.size);
    //[self.mainImage.image drawAtPoint:CGPointZero];
    // Clip to the bezier path and fill that portion of the image.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.contentView.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *blurImage = [screenShot stackBlur:self.blurRadio];
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([blurImage CGImage], path.bounds);
    UIImage *screenImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    return screenImage;
    
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, YES);

    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    
    CGImageRelease(mask);
    
    UIImage * maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
    
    return maskedImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Helper methods

- (IBAction)blurStepperChanged:(UIStepper *)sender {
    [self updateBlurValues];
}


- (void)updateBlurValues{
    self.blurRadio = self.blurStepper.value;
    self.blurLabel.text = [NSString stringWithFormat:@" %.00f", self.blurStepper.value] ;
    
}

- (IBAction)undoPressed {
    
    UIImageView *lastBlurImage = [[UIImageView alloc]init];
    lastBlurImage = [self.blurArray lastObject];
    [lastBlurImage removeFromSuperview];
    [self.blurArray removeLastObject];
}

- (void)initBlurResouces {
    [self updateBlurValues];
    self.blurArray = [[NSMutableArray alloc]init];
}

- (void)initRubberResouces {
                                                           
    self.rubberController = (RubberImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"rubberViewController"];
    [self.rubberController setSelectedImage:self.originalImage];
    [self.rubberController.view setFrame:self.view.frame];
    [self.rubberController beginAppearanceTransition:YES animated:YES];
    //To solve status bar height desphase when adding to contentview
//    float barHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
//    CGRect rubberNewFrame = self.rubberController.view.frame;
//    rubberNewFrame.origin.y += barHeight;
//    self.rubberController.view.frame = rubberNewFrame;
    [self.view addSubview:self.rubberController.view];
    [self.rubberController endAppearanceTransition];
    
    self.rubberController.receiveTouches = true;
    //[self.rubberController setWhiteningArea:true];
}


@end
