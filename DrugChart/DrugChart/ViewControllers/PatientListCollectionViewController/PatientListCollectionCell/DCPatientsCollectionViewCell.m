//
//  DCPatientsCollectionViewCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/19/15.
//
//

#import "DCPatientsCollectionViewCell.h"

#define NA_TEXT @"N/A"

@interface DCPatientsCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextMedicationDateLabel;
@property (nonatomic, strong) DCPatient *patient;

@end

@implementation DCPatientsCollectionViewCell

- (void)awakeFromNib {
    
    CGFloat borderWidth = 1.0f;
    self.layer.borderColor = [UIColor getColorForHexString:@"#ccd5db"].CGColor;
    self.layer.borderWidth = borderWidth;
}


- (void)populatePatientCellWithPatientDetails:(DCPatient *)patient {
    
    //populate view with patient details
    _patient = patient;
    if (patient) {
        @try {
            _patientNameLabel.text = patient.patientName;
            _patientIdLabel.text = patient.nhs;
            _bedNumberLabel.text = patient.bedNumber;
            [self manageNextMedicationDisplayForPatient];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"An issue in  setting up patient model: %@", exception.description);
        }
    }
}

- (void)manageNextMedicationDisplayForPatient {
    
    if (!_patient.nextMedicationDate) {
        _nextMedicationDateLabel.text = NA_TEXT;
    } else {
        _nextMedicationDateLabel.text = [DCDateUtility getNextMedicationDisplayStringForPatientFromDate:_patient.nextMedicationDate];
    }
}

@end
