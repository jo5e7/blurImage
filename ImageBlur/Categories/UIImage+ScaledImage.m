//
//  UIImage+ScaledImage.m
//  Smile HD
//
//  Created by Jorge Palacio on 8/20/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import "UIImage+ScaledImage.h"

@implementation UIImage (ScaledImage)

- (UIImage *)imageScaledToSize:(CGSize)newSize
{
    CGSize imageSize = self.size; // size in which you want to draw
    
    float hfactor = imageSize.width / newSize.width;
    float vfactor = imageSize.height / newSize.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = imageSize.width / factor;
    float newHeight = imageSize.height / factor;
    
    CGFloat offsetX = (newSize.width - newWidth) / 2;
    CGFloat offsetY = (newSize.height - newHeight) / 2;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(offsetX, offsetY, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImage (CompressedImage)

+ (NSData *)compressUIImage:(UIImage *)image
          compressionFactor:(CGFloat)compression
             maxCompression:(CGFloat)maxCompression
                maxFileSize:(int)maxFileSize
{
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    if (imageData) {
        
        while ([imageData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        
        return imageData;
    }

    return nil;
}

@end
