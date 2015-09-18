//
//  DCPatientGraphicalRepresentationView.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/06/15.
//
//

#import "DCPatientGraphicalRepresentationView.h"
#import "DCGraphicalViewHelper.h"

#define MALE @"Male"
#define FEMALE @"Female"

@interface DCPatientGraphicalRepresentationView () {
    
    IBOutlet UILabel *bedNumberLabel;
    IBOutlet UILabel *patientNameLabel;
    IBOutlet UILabel *patientSexLabel;
    IBOutlet UILabel *consultantLabel;
    IBOutlet UILabel *nextMedicationDateLabel;
    IBOutlet UIImageView *bedImageView;
    IBOutlet UIView *medicationStatusView;
    IBOutlet UIView *separatorView;
    IBOutlet UIButton *detailViewButton;
    
}
@property (nonatomic, strong) DCPatient *patient;
@property (nonatomic, strong) DCBed *bed;

@end

@implementation DCPatientGraphicalRepresentationView

- (id)initWithBedDetails:(DCBed *)bedShown {
    
    NSString *nibName = [bedShown getNibFileForHeadDirection];
    self = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
    self.patient = bedShown.patient;
    self.bed = bedShown;
    return self;
}

- (void)populateValuesToViewElements {
    
    BOOL hasPatient = NO;
    if (self.patient) {
        [detailViewButton setUserInteractionEnabled:YES];
        hasPatient = YES;
    } else {
        [detailViewButton setUserInteractionEnabled:NO];
    }
    patientNameLabel.text = self.patient.patientName;
    bedNumberLabel.text = [NSString stringWithFormat:@"%@",self.bed.bedNumber];
    if (self.patient.sex) {
        patientSexLabel.text = self.patient.sex;
    }
    consultantLabel.text = self.patient.consultant;
    nextMedicationDateLabel.attributedText = [self.patient getFormattedDisplayMedicationDateForPatient];
    medicationStatusView.backgroundColor = [self.patient getDisplayColorForMedicationStatus];
    bedImageView.image = [DCGraphicalViewHelper getBedImageForBedType:self.bed.bedType
                                                andBedOperationStatus:self.bed.bedStatus
                                                        andHasPatient:hasPatient];
    self.backgroundColor = self.bed.bedColor;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1] CGColor];
    if (self.patient.nextMedicationDate == nil) {
        medicationStatusView.hidden = YES;
        nextMedicationDateLabel.hidden = YES;
        separatorView.hidden = YES;
    }
 }

- (void)adjustViewFrame {
    
    if (self.patient.nextMedicationDate == nil) {
        patientNameLabel.frame = CGRectMake(10.0, 10.0, patientNameLabel.fsw, patientNameLabel.fsh);
        patientSexLabel.frame = CGRectMake(10.0, 38.0, patientSexLabel.fsw, patientSexLabel.fsh);
        consultantLabel.frame = CGRectMake(10.0, 66.0, consultantLabel.fsw, consultantLabel.fsh);
        [self layoutIfNeeded];
    }
}

- (void)addPatientDetailButton {
    
    UIButton *patientButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [patientButton addTarget:self
                      action:@selector(gotoPatientDetails:)
            forControlEvents:UIControlEventTouchUpInside];
    [patientButton setFrame:self.frame];
    [self addSubview:patientButton];
}

- (IBAction)gotoPatientDetails:(id)sender {
    if (self.delegate ) {
        [self.delegate goToPatientDetailView:self.patient];
    }
    
}

@end
