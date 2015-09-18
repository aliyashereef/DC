//
//  DCDosagePopOverBackgroundView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/17/15.
//
//

#import "DCDosagePopOverBackgroundView.h"

#define CONTENT_INSET 5.0
#define ARROW_BASE 19.0
#define ARROW_HEIGHT 10.0

@implementation DCDosagePopOverBackgroundView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        //add pointer image, background image view to Popover background view
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreyUpArrow"]];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_popoverBackgroundImageView];
        [self addSubview:_arrowView];
        _popoverBackgroundImageView.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView.layer.borderWidth = 1.0f;
        _popoverBackgroundImageView.layer.cornerRadius = 3.0f;
        _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#e8eeef"].CGColor;
        _popoverBackgroundImageView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(CONTENT_INSET, 0, CONTENT_INSET, 0);
}

+ (CGFloat)arrowHeight{
    return ARROW_HEIGHT;
}

+ (CGFloat)arrowBase{
    return ARROW_BASE;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat popoverImageOriginX;
    CGFloat popoverImageOriginY;
    CGFloat popoverImageWidth = self.frame.size.width + 2;
    CGFloat popoverImageHeight = self.frame.size.height - 18;
    if (_arrowDirection == UIPopoverArrowDirectionDown) {
        popoverImageOriginX = -1.0f;
        popoverImageOriginY = 0.0f;
        CGFloat arrowImageOriginX = roundf((self.bounds.size.width - ARROW_BASE) / 2.0f + self.arrowOffset);
        _arrowView.frame = CGRectMake(arrowImageOriginX, self.bounds.size.height - ARROW_HEIGHT - 3, ARROW_BASE, ARROW_HEIGHT);
        [_arrowView setImage:[UIImage imageNamed:@"GreyDownArrow"]];
        _popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    } else {
        popoverImageOriginX = -1.0f;
        popoverImageOriginY = 14.0f;
        CGFloat _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
        _arrowView.frame = CGRectMake(_coordinate, 5, ARROW_BASE, ARROW_HEIGHT);
        [_arrowView setImage:[UIImage imageNamed:@"GreyUpArrow"]];
    }
    _popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#e8eeef"].CGColor;
}


@end
