//
//  UIImage+ImageMask.m
//  Dentsio Smile
//
//  Created by Jorge Palacio on 6/18/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import "UIImage+ImageMask.h"

@implementation UIImage (ImageMask)

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
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

@end
