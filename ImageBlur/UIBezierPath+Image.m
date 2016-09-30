#import "UIBezierPath+Image.h"

@implementation UIBezierPath (Image)

- (UIImage*) strokeImageWithColor:(UIColor*)color
{
    // adjust bounds to account for extra space needed for lineWidth
    CGFloat width = 1024;
    //CGFloat width = self.bounds.size.width + self.lineWidth * 2;
    CGFloat height = 1024;
    //CGFloat height = self.bounds.size.height + self.lineWidth * 2;
    CGRect bounds = CGRectMake(0, 0, width, height);//CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithCGPath:self.CGPath];
    path.lineWidth = self.lineWidth;
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    view.backgroundColor = [UIColor whiteColor];
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // set color
    [color set];
    
    [path fill];
    
    [path stroke];
    
    [self fill];
    
    // draw the stroke
    [self stroke];
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (UIImage *)imageFromWithSize:(CGSize)size
                         scale:(CGFloat)scale
                       bgColor:(UIColor *)bgColor
                     pathColor:(UIColor *)color
{
    // adjust bounds to account for extra space needed for lineWidth
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithCGPath:self.CGPath];
    path.lineWidth = self.lineWidth;
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    view.backgroundColor = bgColor;
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // set color
    [color set];
    
    [path fill];
    
    [path stroke];
    
    [self fill];
    
    // draw the stroke
    [self stroke];
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
