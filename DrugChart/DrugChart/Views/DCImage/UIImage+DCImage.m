//
//  UIImage+DCImage.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/3/15.
//
//

#import "UIImage+DCImage.h"

@implementation UIImage (DCImage)

- (UIImage *)imageWithColor:(UIColor *)color {
    
    //RETURNS UIImage object from the color given.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
