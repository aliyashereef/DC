//
//  DCPatientAlertsNotificationTableViewCell.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCPatientAlertsNotificationTableViewCell.h"

#define SEVERE_TEXT_COLOR [UIColor getColorForHexString:@"#f00707"]
#define NOT_SEVERE_TEXT_COLOR [UIColor getColorForHexString:@"#292929"]
#define SEVERE_IMAGE [UIImage imageNamed:@"RedWarning"]
#define NOT_SEVERE_IMAGE [UIImage imageNamed:@"AlertsBlueIcon"]


@interface DCPatientAlertsNotificationTableViewCell ()

@end

@implementation DCPatientAlertsNotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configurePatientsAlertCell:(DCPatientAlert *)patientAlert {
    
    NSLog(@"the alert text : %@",patientAlert.alertText); // TODO: delete the
    // commented code on getting clarity on final API response.
    [self configureCellForSeverity:patientAlert.isSevere];
    // add spacing between the lines.
    NSString *alertString = patientAlert.alertText;
    self.alertTextLabel.text = alertString;
}

#pragma mark - private method implementation
- (void)configureCellForSeverity:(BOOL)isSevere {
    
    if (isSevere) {
        self.alertTextLabel.textColor = SEVERE_TEXT_COLOR;
        self.severityImageVIew.image = SEVERE_IMAGE;
    }
    else {
        self.alertTextLabel.textColor = NOT_SEVERE_TEXT_COLOR;
        self.severityImageVIew.image = NOT_SEVERE_IMAGE;
    }
}

@end
