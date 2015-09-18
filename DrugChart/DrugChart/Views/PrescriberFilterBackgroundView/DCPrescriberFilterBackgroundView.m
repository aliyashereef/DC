//
//  DCPrescriberFilterBackgroundView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/6/15.
//
//

#import "DCPrescriberFilterBackgroundView.h"

#define CONTENT_INSET 5.0
#define ARROW_BASE 21.0
#define ARROW_HEIGHT 12.0

@implementation DCPrescriberFilterBackgroundView


-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //add pointer image, background image view to Popover background view
        self.clipsToBounds = YES;
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FilterArrow"]];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_popoverBackgroundImageView];
        [self addSubview:_arrowView];
        _popoverBackgroundImageView.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView.layer.borderWidth = 1.0f;
        _popoverBackgroundImageView.layer.cornerRadius = 5.0f;
        _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#b1b1b1"].CGColor;
        _popoverBackgroundImageView.backgroundColor = [UIColor whiteColor];
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
    CGFloat _coordinate = 0.0;
    CGFloat popoverImageOriginX = 3.0f;
    CGFloat popoverImageOriginY = 15.0f;
    CGFloat popoverImageWidth = 184;
    CGFloat popoverImageHeight = 153;
    _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE/2);
    _arrowView.frame = CGRectMake(_coordinate, 5, ARROW_BASE, ARROW_HEIGHT);
    _popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#b1b1b1"].CGColor;
    _popoverBackgroundImageView.layer.cornerRadius = 5.0f;
}

@end
