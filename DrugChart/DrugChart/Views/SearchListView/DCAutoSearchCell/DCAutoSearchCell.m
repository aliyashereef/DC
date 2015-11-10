//
//  DCAUtoSearchCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/2/15.
//
//

#import "DCAutoSearchCell.h"

@implementation DCAutoSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSearchValue:(NSString *)searchValue {
    
    _searchValue = searchValue;
    CGFloat heightValue = [DCUtility heightValueForText:_searchValue withFont:[DCFontUtility getLatoRegularFontWithSize:16.0f] maxWidth:420];
    [_searchNameLabel setText:_searchValue];
    _nameLabelHeightConstraint.constant = heightValue + 10;
    [self layoutSubviews];
}

@end
