//
//  DCPatientListCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/18/15.
//
//

#import "DCPatientListCell.h"

#define NA_TEXT @"N/A"
#define DUMMY_DOCTOR @"KENNEDY, Frederick (Dr)"
#define BED_NUMBER @"0"

@interface DCPatientListCell ()

@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextMedicationLabel;
@property (weak, nonatomic) IBOutlet UILabel *consultantLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientIdLabel;
@property (nonatomic, strong) DCPatient *patient;

@end


@implementation DCPatientListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)populatePatientCellWithPatientDetails:(DCPatient *)patient {
    
    //populate view with patient details
    _patient = patient;
    if (patient) {
        @try {
            _patientNameLabel.text = _patient.patientName;
            _patientIdLabel.text = _patient.nhs;
           [self populateBedNumberLabel];
            [self manageBedNumberDisplayForPatient];
            [self manageNextMedicationDisplayForPatient];
            [self manageConsultantDisplayForPatient];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"An issue in  setting up patient model: %@", exception.description);
        }
    }
}

- (void)populateBedNumberLabel {
    
    //populate bed no label
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    NSDictionary *contentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:13.0f], NSFontAttributeName, [UIColor getColorForHexString:@"#878787"], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:[NSString stringWithFormat:@"Bed No  %@", _patient.bedNumber]];
    [attributedString setAttributes:titleAttributes range:NSMakeRange(0, 6)];
    [attributedString setAttributes:contentAttributes range:NSMakeRange(6, _patient.bedNumber.length)];
    _bedNumberLabel.attributedText = attributedString;
}

- (void)manageNextMedicationDisplayForPatient {
    
    if (!_patient.nextMedicationDate) {
        _nextMedicationLabel.text = NA_TEXT;
    } else {
        _nextMedicationLabel.text = [DCDateUtility getNextMedicationDisplayStringForPatientFromDate:_patient.nextMedicationDate];
    }
}

- (void)manageConsultantDisplayForPatient {
    if (!_patient.consultant) {
        //To Do : To handle the case with no consultant in the API , we are using a dummy value for doctor.
        _consultantLabel.text = DUMMY_DOCTOR;
    } else {
        _consultantLabel.text = _patient.consultant;
    }
}

- (void)manageBedNumberDisplayForPatient {
    if (!_patient.bedNumber) {
        //To Do : To handle the case with no bed number in the API , we are using a dummy value for number.
        _patient.bedNumber = BED_NUMBER;
    }
    [self populateBedNumberLabel];
}

@end
