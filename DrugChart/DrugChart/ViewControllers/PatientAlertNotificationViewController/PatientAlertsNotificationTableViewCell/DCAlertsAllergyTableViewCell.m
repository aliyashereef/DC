//
//  DCAlertsAllergyTableViewCell.m
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import "DCAlertsAllergyTableViewCell.h"


@implementation DCAlertsAllergyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configurePatientsAlertCell:(DCPatientAlert *)patientAlert {
    
    NSString *alertString = patientAlert.alertText;
    self.alertsAllergyLabel.text = alertString;
}

- (void)configurePatientsAllergyCell:(DCPatientAllergy *)patientAllergy {
    
    NSString *allergyString = patientAllergy.allergyName;
    self.alertsAllergyLabel.text = allergyString;
}

@end
