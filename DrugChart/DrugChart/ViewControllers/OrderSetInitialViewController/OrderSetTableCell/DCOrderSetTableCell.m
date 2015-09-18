//
//  DCOrderSetTableCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/30/15.
//
//

#import "DCOrderSetTableCell.h"

static float kStatusImageWidth              = 30.0f;
static float kStatusImageLeadingValue       = 10.0f;
static float kNameLeadingValue              = 15.0f;
static float kNameLeadingValueIfTick        = 10.0f;
static float kNameDefaultHeight             = 45.0f;
static float kOrderSetNameFieldMaxWidth     = 536.0f;

@interface DCOrderSetTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *severeWarningLabel;
@property (nonatomic, weak) IBOutlet UILabel *mildWarningLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusImageLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *medicineNameLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *medicineNameHeightConstraint;
@property (nonatomic, strong) DCMedicationDetails *medication;


@end

@implementation DCOrderSetTableCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureOrderSetCellForMedication:(DCMedicationDetails *)medication {
    
    _medication = medication;
    [self configureViewElements];
}

- (void)configureViewElements {
    
    if (_medication.addMedicationCompletionStatus) {
        _statusImageWidthConstraint.constant = kStatusImageWidth;
        _statusImageLeadingConstraint.constant = kStatusImageLeadingValue;
        _medicineNameLeadingConstraint.constant = kNameLeadingValueIfTick;
    } else {
        _statusImageWidthConstraint.constant = ZERO_CONSTRAINT;
        _statusImageLeadingConstraint.constant = ZERO_CONSTRAINT;
        _medicineNameLeadingConstraint.constant = kNameLeadingValue;
    }
    [self configureWarningsElements];
    CGFloat medicineNameHeight = [DCUtility getHeightValueForText:_medication.name withFont:[DCFontUtility getLatoRegularFontWithSize:14.0f] maxWidth:kOrderSetNameFieldMaxWidth];
    _medicineNameHeightConstraint.constant = medicineNameHeight > kNameDefaultHeight ? medicineNameHeight : kNameDefaultHeight;
}

- (void)configureWarningsElements {
    
    //populate warnings elements
    _medication.severeWarningCount = 1;
    _medication.mildWarningCount = 2;
    _medication.hasWarning = YES;
    self.medicineNameLabel.text = _medication.name;

    if (_medication.hasWarning) {
        self.severeWarningLabel.text = [NSString stringWithFormat:@"Severe(%ld)", (long)_medication.severeWarningCount];
        self.mildWarningLabel.text = [NSString stringWithFormat:@"Mild(%ld)", (long)_medication.mildWarningCount];
        [self.severeWarningLabel setHidden:NO];
        [self.mildWarningLabel setHidden:NO];
    } else {
        [self.severeWarningLabel setHidden:YES];
        [self.mildWarningLabel setHidden:YES];
    }
}

@end
