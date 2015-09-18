//
//  DCMedicationDisplayCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/20/15.
//
//

#import "DCMedicationDisplayCell.h"

@interface DCMedicationDisplayCell ()

@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *routeAndInstructionLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *startDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *medicationTypeLabel;
@property (nonatomic, strong) DCMedicationScheduleDetails *medicationList;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *medicineNameHeightConstraint;

@end

@implementation DCMedicationDisplayCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithMedicationDetails:(DCMedicationScheduleDetails *)medicationList {
    
    self.medicationList = medicationList;
    if(medicationList.isActive) {
        self.discontinuedLabelHeightConstraint.constant = 0.0f;
    } else {
         self.discontinuedLabelHeightConstraint.constant = 18.0f;
    }
    [self populateMedicineLabelName];
    [self populateRouteAndInstructionLabel];
    [self populateStartDateLabel];
    [self populateMedicationTypeLabel];
}

- (void)configureCellForNoMedicationDetails:(NSString *)message {
    
    self.medicineNameLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
    self.medicineNameLabel.textColor = [UIColor getColorForHexString:@"#313131"];
    self.medicineNameLabel.text = message;
    self.medicationNameLabelTopSpaceConstraint.constant = 23.0f;
    [_startDateLabel setHidden:YES];
    [_startDateTitleLabel setHidden:YES];
    [_medicationTypeLabel setHidden:YES];
    [_routeAndInstructionLabel setHidden:YES];
    _discontinuedLabelHeightConstraint.constant = 0.0f;
}

- (void)populateMedicineLabelName {
    
    NSString *medicineName = self.medicationList.name;
    NSDictionary *nameAttributes = @{
                                     NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:15.0f],
                                     NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#313131"]
                                     };
    NSMutableAttributedString *medicationNameAttributedString = [[NSMutableAttributedString alloc] initWithString:medicineName];
    [medicationNameAttributedString setAttributes:nameAttributes range:NSMakeRange(0, [medicineName length])];
    self.medicineNameLabel.attributedText = medicationNameAttributedString;
    
    CGSize constrain = CGSizeMake(266, FLT_MAX);
    CGRect textRect;
    textRect = [medicineName   boundingRectWithSize:constrain
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[DCFontUtility getLatoRegularFontWithSize:17.0f]}
                                                           context:nil];
    _medicineNameHeightConstraint.constant = textRect.size.height;
    [self layoutIfNeeded];
}

- (void)populateRouteAndInstructionLabel {
    
    //populate route and instructions
    [_routeAndInstructionLabel setHidden:NO];
    NSDictionary *dosageAttributes = @{
                                       NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:15.0f],
                                       NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#3b3b3b"]
                                       };
    NSMutableAttributedString *dosageAttributedString = [[NSMutableAttributedString alloc] initWithString:self.medicationList.route];
    [dosageAttributedString setAttributes:dosageAttributes range:NSMakeRange(0, [dosageAttributedString length])];
    NSString *medicineInstruction = self.medicationList.instruction;
    NSString *instructionDisplayString = medicineInstruction.length?[NSString stringWithFormat:@" (%@)", medicineInstruction]:@"";
    NSMutableAttributedString *medicineInstructionAttributedString = [[NSMutableAttributedString alloc]
                                                                      initWithString:instructionDisplayString];
    NSDictionary *instructionAttributes = @{
                                            NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:14.0f],
                                            NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#676767"]
                                            };
    [medicineInstructionAttributedString setAttributes:instructionAttributes range:NSMakeRange(0, [instructionDisplayString length])];
    [dosageAttributedString appendAttributedString:medicineInstructionAttributedString];
    _routeAndInstructionLabel.attributedText = dosageAttributedString;
}

- (void)populateStartDateLabel {
    
    //get start date
    [_startDateLabel setHidden:NO];
    [_startDateTitleLabel setHidden:NO];
    _startDateLabel.text = [DCDateUtility dateStringFromSourceString:_medicationList.startDate];
}

- (void)populateMedicationTypeLabel {
    
    [_medicationTypeLabel setHidden:NO];
    if ([_medicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
        _medicationTypeLabel.text = WHEN_REQ_DISPLAY_STRING;
    } else {
        _medicationTypeLabel.text = _medicationList.medicineCategory;
    }
}

@end
