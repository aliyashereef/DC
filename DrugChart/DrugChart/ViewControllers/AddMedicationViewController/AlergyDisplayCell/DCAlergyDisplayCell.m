//
//  DCAlergyDisplayCell.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 20/04/15.
//
//

#import "DCAlergyDisplayCell.h"

#define SEVERITY_IMAGE_DEFAULT_WIDTH            17.0f
#define SEVERITY_IMAGE_TRAILING_VALUE           10.0f
#define SEVERITY_IMAGE_TRAILING_NO_ALLERGIES    4.0f

@interface DCAlergyDisplayCell ()

@property (weak, nonatomic) IBOutlet UIImageView *warningSeverityImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *severityImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *severityImageTrailingConstraint;

@property (strong, nonatomic) DCPatientAllergy *patientAllergy;


@end

@implementation DCAlergyDisplayCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configurePatientAllergyCell:(DCPatientAllergy *)patientAllergy {
    
    _patientAllergy = patientAllergy;
    _severityImageWidthConstraint.constant = SEVERITY_IMAGE_DEFAULT_WIDTH;
    _severityImageTrailingConstraint.constant = SEVERITY_IMAGE_TRAILING_VALUE;
    if ([patientAllergy.warningType isEqualToString:SEVERE_WARNING]) {
        self.warningSeverityImageView.image = [UIImage imageNamed:SEVERE_WARNING_IMAGE];
    } else {
        self.warningSeverityImageView.image = [UIImage imageNamed:MILD_WARNING_IMAGE];
    }
    self.warningLabel.text =  patientAllergy.allergyName;
}

- (void)configurePatientAllergyCellForNoAllergies:(NSString *)message {
    
    //no allergy condition
    _severityImageWidthConstraint.constant = ZERO_CONSTRAINT;
    _severityImageTrailingConstraint.constant = SEVERITY_IMAGE_TRAILING_NO_ALLERGIES;
    self.warningLabel.text = message;
}

- (void)configureWarningLabel {
    
    NSDictionary *warningLabelAttributes = @{
                                             NSFontAttributeName : [DCFontUtility latoRegularFontWithSize:15.0f],
                                             NSForegroundColorAttributeName : [UIColor colorForHexString:@"#313131"]
                                             };
    NSMutableAttributedString *warningAttributedString = [[NSMutableAttributedString alloc] initWithString:_patientAllergy.allergyName];
    [warningAttributedString setAttributes:warningLabelAttributes range:NSMakeRange(0, [warningAttributedString length])];
    NSMutableAttributedString *severityAttributedString = [[NSMutableAttributedString alloc]
                                                           initWithString:_patientAllergy.warningType];
    NSString *severityColorHex = [_patientAllergy.warningType isEqualToString:SEVERE_WARNING] ? @"#f00707" : @"#d5a601";
    NSDictionary *severityAttributes = @{
                                         NSFontAttributeName : [DCFontUtility latoRegularFontWithSize:14.0f],
                                         NSForegroundColorAttributeName : [UIColor colorForHexString:severityColorHex]
                                         };
    [severityAttributedString setAttributes:severityAttributes range:NSMakeRange(0, [severityAttributedString length])];
    [warningAttributedString appendAttributedString:severityAttributedString];
    self.warningLabel.attributedText = warningAttributedString;
    
}

@end
