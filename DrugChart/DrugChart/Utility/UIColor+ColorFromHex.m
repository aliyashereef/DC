//
//  UIColor+ColorFromHex.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "UIColor+ColorFromHex.h"

@implementation UIColor (ColorFromHex)

+ (UIColor *)getColorForHexString:(NSString *)hexString {
    
    uint hexValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&hexValue];
    UIColor *color = [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0
                                     green:((hexValue & 0xFF00) >> 8)/255.0
                                      blue:(hexValue & 0xFF)/255.0
                                     alpha:1.0];
    return color;
}

@end
