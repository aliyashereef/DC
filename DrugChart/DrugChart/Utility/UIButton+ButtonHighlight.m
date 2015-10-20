//
//  UIButton+ButtonHighlight.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 10/20/15.
//
//

#import "UIButton+ButtonHighlight.h"

@implementation UIButton (ButtonHighlight)

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = YES; }];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(resetHighlightColor) withObject:nil afterDelay:0.1];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(resetHighlightColor) withObject:nil afterDelay:0.1];
}

- (void)resetHighlightColor {
    
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = NO; }];
}


@end
