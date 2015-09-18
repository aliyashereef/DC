//
//  DCPopOverBaseBackgroundView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/28/15.
//
//

#import "DCPopOverBaseBackgroundView.h"

@implementation DCPopOverBaseBackgroundView

- (UIPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
}

- (CGFloat) arrowOffset {
    return _arrowOffset;
}

- (void) setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
}

@end
