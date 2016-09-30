//
//  UIImage+ScaledImage.h
//  Smile HD
//
//  Created by Jorge Palacio on 8/20/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScaledImage)

- (UIImage *)imageScaledToSize:(CGSize)newSize;

@end

@interface UIImage (CompressedImage)

+ (NSData *)compressUIImage:(UIImage *)image
          compressionFactor:(CGFloat)compression
             maxCompression:(CGFloat)compression
                maxFileSize:(int)fileSize;

@end
