//
//  DCMedicineNameCellTableViewCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/28/15.
//
//

#import "DCMedicineNameCell.h"

@implementation DCMedicineNameCell

- (void)awakeFromNib {
    // Initialization code
    self.layoutMargins = UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (void)setMedicineName:(NSString *)medicineName {
    
    _medicineName = medicineName;
    if ([_medicineName isEqualToString:NSLocalizedString(@"NO_MEDICATIONS", @"")]) {
        self.userInteractionEnabled = NO;
    } else {
        self.userInteractionEnabled = YES;
    }
    CGSize constrain = CGSizeMake(420, FLT_MAX);
    CGRect textRect;
    textRect = [_medicineName  boundingRectWithSize:constrain
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:[DCFontUtility getLatoRegularFontWithSize:16.0f]}
                                                             context:nil];
    [_medicineNameLabel setText:_medicineName];
    _labelHeightConstraint.constant = textRect.size.height + 10;
    [self layoutSubviews];
}

@end
