//
//  DCErrorPopOverBackgroundView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/15.
//
//

#import "DCErrorPopOverBackgroundView.h"

#define CONTENT_INSET 5.0
#define ARROW_BASE 10.0
#define ARROW_HEIGHT 5.0

@implementation DCErrorPopOverBackgroundView


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ErrorArrow.png"]];
        [self addSubview:_arrowView];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
    }
    return self;
}

+(UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

+(CGFloat)arrowHeight{
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase{
    return ARROW_BASE;
}

-  (void)layoutSubviews {
    [super layoutSubviews];
    //set frame for down arrow
    CGFloat _height = self.frame.size.height;
    CGFloat _coordinate = 0.0;
    _height -= ARROW_HEIGHT;
    _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
    _arrowView.frame = CGRectMake(_coordinate, _height - 5, ARROW_BASE, ARROW_HEIGHT);
}


@end
