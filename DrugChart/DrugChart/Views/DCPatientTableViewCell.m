//
//  DCPatientTableViewCell.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "DCPatientTableViewCell.h"

#import "DCPatient.h"
#import "UIImage+DCImage.h"

#define DISPLAY_DATE_FORMAT @"HH:mm, dd MMMM"

#define NA_TEXT_COLOR @"#313131"
#define NA_TEXT @"N/A"

@interface DCPatientTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIdLabel;
@property (weak, nonatomic) IBOutlet UIView *patientMedicationStatusView;
@property (weak, nonatomic) IBOutlet UILabel *bedNumberTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextMedicationDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *patientMedicationStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextMedicationTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextMedicationClockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bedImageView;

@end


@implementation DCPatientTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configurePatientCellWithPatientDetails:(DCPatient *)patient {
    
    if (patient) {
        @try {
            self.patientNameLabel.font = [DCFontUtility getLatoRegularFontWithSize:20.0f];
            self.patientNameLabel.text = patient.patientName;
            self.patientIdTitleLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
            self.patientIdLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
            self.patientIdLabel.text = patient.nhs;
            self.bedNumberTitleLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
            self.bedNumberLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
            self.bedNumberLabel.text = patient.bedNumber;
            self.nextMedicationTitleLabel.font = [DCFontUtility getLatoRegularFontWithSize:15.0f];
            self.nextMedicationDateLabel.font = [DCFontUtility getLatoBoldFontWithSize:15.0f];
            [self manageNextMedicationDisplayForPatient:patient];
            [self configureMeditationStatusView:patient];
            self.bedImageView.image = [DCUtility getBedTypeImageForBedType:patient.bedType];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"An issue in  setting up patient model: %@", exception.description);
        }
    }
}

#pragma mark - private methods
// the view on the left has to be configured as per the mask
- (void)configureMeditationStatusView:(DCPatient *)patient {
    
    UIColor *statusColor = [patient getDisplayColorForMedicationStatus];
    [self.patientMedicationStatusImageView setImage:[self.patientMedicationStatusImageView.image imageWithColor:statusColor]];
}

- (void)manageNextMedicationDisplayForPatient:(DCPatient *)patient {
    
    if (!patient.nextMedicationDate) {
        self.nextMedicationDateLabel.text = NA_TEXT;
        self.nextMedicationDateLabel.textColor = [UIColor getColorForHexString:NA_TEXT_COLOR];
    }
    else {
        [self setFormattedDisplayMedicationDateForPatient:patient];
    }
}

- (void)setFormattedDisplayMedicationDateForPatient:(DCPatient *) patient{
    // function format and display the  next medication date.
    // also set the color
    NSMutableAttributedString *attributedDateString = [patient getFormattedDisplayMedicationDateForPatient];
    if (attributedDateString) {
        self.nextMedicationDateLabel.attributedText =  attributedDateString;
        self.nextMedicationDateLabel.textColor = [patient getDisplayColorForMedicationStatus];
    }
}


@end
