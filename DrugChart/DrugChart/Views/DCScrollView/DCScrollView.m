//
//  DCScrollView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/15/15.
//
//

#import "DCScrollView.h"

@implementation DCScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    [self sendScrollViewTouchToSuperView:touch];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    [self sendScrollViewTouchToSuperView:touch];
    [super touchesEnded:touches withEvent:event];
}

- (void)sendScrollViewTouchToSuperView:(UITouch *)touch {
    
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(touchedScrollView:)]) {
        
        [self.scrollDelegate touchedScrollView:touch];
    }
}

@end
