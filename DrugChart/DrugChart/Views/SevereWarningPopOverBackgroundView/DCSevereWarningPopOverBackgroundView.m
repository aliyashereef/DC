//
//  DCSevereWarningPopOverBackgroundView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/22/15.
//
//

#import "DCSevereWarningPopOverBackgroundView.h"

#define ARROW_HEIGHT 8.0f
#define ARROW_BASE 16.0f

@implementation DCSevereWarningPopOverBackgroundView


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WarningArrow"]];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_popoverBackgroundImageView];
        [self addSubview:_arrowView];
        _popoverBackgroundImageView.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView.layer.borderWidth = 1.0f;
        _popoverBackgroundImageView.layer.cornerRadius = 12.0f;
        _popoverBackgroundImageView.layer.borderColor = [UIColor blueColor].CGColor;//[UIColor getColorForHexString:@"#b1b1b1"].CGColor;
        _popoverBackgroundImageView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

+(UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(10, 10, 10, 10);
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
    CGFloat arrowImageOriginX = roundf((self.bounds.size.width - ARROW_BASE) / 2.0f + self.arrowOffset);
    CGFloat arrowImageOriginY = 0.0f;
    _arrowView.frame = CGRectMake(arrowImageOriginX, arrowImageOriginY + 9 , ARROW_BASE, ARROW_HEIGHT);
    _popoverBackgroundImageView.frame = CGRectMake(9.0f, 17.0f, 365.0f, self.bounds.size.height - 26.0f);
    _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#d3d3d3"].CGColor;
}


@end
