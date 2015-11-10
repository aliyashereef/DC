//
//  DCAddMedicationContentCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/2/15.
//
//

#import "DCAddMedicationContentCell.h"

@interface DCAddMedicationContentCell () {
    
    __weak IBOutlet UIView *warningsView;
    __weak IBOutlet UILabel *warningsCountLabel;

}

@end

@implementation DCAddMedicationContentCell

- (void)awakeFromNib {
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
     // Configure the view for the selected state
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods

- (void)configureMedicationContentCellWithWarningsCount:(NSInteger)warningsCount {
    
    [warningsView setHidden:NO];
    [_descriptionLabel setHidden:YES];
    [warningsCountLabel setText:[NSString stringWithFormat:@"%ld", (long)warningsCount]];
}

- (void)configureContentCellWithContent:(NSString *)content {
    
    [warningsView setHidden:YES];
    [_descriptionLabel setHidden:NO];
    [_descriptionLabel setText:content];
}

- (void)configureMedicationAdministratingTimeCell {
    
    [warningsView setHidden:YES];
    [_descriptionLabel setHidden:YES];
}

@end
