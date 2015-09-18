//
//  DCTimeView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/9/15.
//
//

#import "DCTimeView.h"
#import "DCAdministerMedication.h"

#define TIME_LABEL_CONSTRAINT_NORMAL        20.0f
#define TIME_LABEL_CONSTRAINT_YET_TO_GIVE   0.0f

@implementation DCTimeView

#pragma Action Methods

- (IBAction)calenderItemTapped:(UIButton *)sender {
    
    self.timeAction();
}

#pragma mark - Public Method

- (void)displayTimeViewForMedicationSlot:(DCMedicationSlot *)medicationSlot {
 
    _medicationSlot = medicationSlot;
    NSString *medicationTime = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:TWENTYFOUR_HOUR_FORMAT];
    _timeLabel.text = medicationTime;
    // checks if the medication time is less than current time.
    if ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        if (!medicationSlot.medicationAdministration.status) {
            _statusImageView.image = [DCUtility getMedicationStatusImageForMedicationStatus:YET_TO_GIVE];
            _timeLabelLeadingConstraint.constant = TIME_LABEL_CONSTRAINT_YET_TO_GIVE;
        }
    }
    else if ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedAscending) {
        _statusImageView.image = [DCUtility getMedicationStatusImageForMedicationStatus:medicationSlot.status];
        _timeLabelLeadingConstraint.constant = [medicationSlot.status isEqualToString:YET_TO_GIVE] ? TIME_LABEL_CONSTRAINT_YET_TO_GIVE: TIME_LABEL_CONSTRAINT_NORMAL;
    } else {
        _statusImageView.image = [DCUtility getMedicationStatusImageForMedicationStatus:YET_TO_GIVE];
        _timeLabelLeadingConstraint.constant = TIME_LABEL_CONSTRAINT_YET_TO_GIVE;
    }
    [self layoutIfNeeded];
}

@end
