//
//  UIImage+ImageMask.h
//  Dentsio Smile
//
//  Created by Jorge Palacio on 6/18/14.
//  Copyright (c) 2014 Jorge Palacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageMask)

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end
