//
//  DCWarningsPopoverCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/23/15.
//
//

#import "DCWarningsPopoverCell.h"

static CGFloat kTitleLabelMaxWidth     =    300.0f;
static CGFloat kTitleLabelMinHeight    =    35.0f;

@interface DCWarningsPopoverCell ()

@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleWidthConstraint;


@end

@implementation DCWarningsPopoverCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureWarningsCellForWarningsObject:(DCWarning *)warning {
    
    CGFloat titleWidth;
    UIFont *titleFont;
    if ([warning.severity isEqualToString:SEVERE_KEY]) {
        //handle severe warning case
        self.backgroundColor = [UIColor getColorForHexString:@"#ffe0e0"];
        _statusImageView.image = [UIImage imageNamed:SEVERE_WARNING_IMAGE];
        _titleLabel.textColor = [UIColor getColorForHexString:@"#f11616"];
        titleFont = [DCFontUtility getLatoRegularFontWithSize:15.0];
    } else if ([warning.severity isEqualToString:MILD_KEY]) {
        //handle mild warning case
        self.backgroundColor = [UIColor getColorForHexString:@"#faf0cd"];
        _statusImageView.image = [UIImage imageNamed:MILD_WARNING_IMAGE];
        _titleLabel.textColor = [UIColor getColorForHexString:@"#0c0c0c"];
        titleFont = [DCFontUtility getLatoRegularFontWithSize:13.0];
    }
     [_titleLabel setFont:titleFont];
    _titleLabel.text = [NSString stringWithFormat:@"%@ ", warning.title];
    titleWidth = [DCUtility getRequiredSizeForText:_titleLabel.text font:titleFont maxWidth:kTitleLabelMaxWidth].width;
    _descriptionLabel.text = warning.detail;
    _titleWidthConstraint.constant = titleWidth > kTitleLabelMaxWidth ? kTitleLabelMaxWidth : titleWidth;
    CGFloat titleHeight = [DCUtility getRequiredSizeForText:_titleLabel.text font:titleFont maxWidth:_titleWidthConstraint.constant].height;
    _titleHeightConstraint.constant = titleHeight < kTitleLabelMinHeight ? titleHeight + 2 : titleHeight;
    CGFloat descriptionHeight = [DCUtility getRequiredSizeForText:warning.detail
                                                                           font:[DCFontUtility getLatoRegularFontWithSize:13.0]
                                                                       maxWidth:262.0f].height;
    _descriptionHeightConstraint.constant = descriptionHeight < kTitleLabelMinHeight ? descriptionHeight + 2 : descriptionHeight;
    [self layoutIfNeeded];
}

@end
