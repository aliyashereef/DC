//
//  DCSettingsPopOverBackgroundView.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCSettingsPopOverBackgroundView.h"

#define ARROW_HEIGHT 8.0f
#define ARROW_BASE 16.0f

#define ARROW_IMAGE @"SettingsArrowImage"

@implementation DCSettingsPopOverBackgroundView


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ARROW_IMAGE]];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView = [[UIImageView alloc] initWithImage:nil];
        [self addSubview:_popoverBackgroundImageView];
        [self addSubview:_arrowView];
        _popoverBackgroundImageView.layer.shadowColor = [UIColor clearColor].CGColor;
        _popoverBackgroundImageView.layer.borderWidth = 1.0f;
        _popoverBackgroundImageView.layer.cornerRadius = 5.0f;
        _popoverBackgroundImageView.layer.borderColor =
        [UIColor getColorForHexString:@"#4dc8e9"].CGColor;
        _popoverBackgroundImageView.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
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
    if (self.bounds.size.width < 200.0f) {
        arrowImageOriginX -= 6.0f;
    }
    CGFloat backgroundImageViewHeight = self.bounds.size.height;
    if (backgroundImageViewHeight > 200.0f) {
        backgroundImageViewHeight -= 25.0f;
    } else {
        backgroundImageViewHeight -= 24.0f;
    }
    _arrowView.frame = CGRectMake(arrowImageOriginX - 1, arrowImageOriginY + 10 , ARROW_BASE, ARROW_HEIGHT);
    CGFloat backgroundImageViewWidth = self.bounds.size.width;
    backgroundImageViewWidth -= 18.0f;
    _popoverBackgroundImageView.frame = CGRectMake(9.0f, 17.0f, backgroundImageViewWidth, backgroundImageViewHeight);
    _popoverBackgroundImageView.layer.borderColor = [UIColor getColorForHexString:@"#4dc8e9"].CGColor;
}



@end
