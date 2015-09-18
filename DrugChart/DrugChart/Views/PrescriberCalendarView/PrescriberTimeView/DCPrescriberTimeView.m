//
//  DCPrescriberTimeView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import "DCPrescriberTimeView.h"

#define PRESCRIBER_OMITTED_IMAGE @"PrescriberOmittedIcon"
#define PRESCRIBER_GIVEN_IMAGE @"PrescriberAdmisteredIcon"
#define PRESCRIBER_REFUSED_IMAGE @"PrescriberRefusedIcon"
#define PRESCRIBER_SELF_ADMINISTERED_IMAGE @"PrescriberSelfAdministeredIcon"
#define PRESCRIBER_TOBE_GIVEN_IMAGE @"ToGiveIcon"


@implementation DCPrescriberTimeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImage *)getMedicationStatusImageForMedicationStatus:(NSString *)status {
    
    UIImage *image = [UIImage imageNamed:PRESCRIBER_GIVEN_IMAGE];
    if ([status isEqualToString:OMITTED]) {
        image = [UIImage imageNamed:PRESCRIBER_OMITTED_IMAGE];
    } else if ([status isEqualToString:IS_GIVEN]) {
        image = [UIImage imageNamed:PRESCRIBER_GIVEN_IMAGE];
    } else if ([status isEqualToString:REFUSED]) {
        image = [UIImage imageNamed:PRESCRIBER_REFUSED_IMAGE];
    } else if ([status isEqualToString:YET_TO_GIVE]) {
        image = [UIImage imageNamed:PRESCRIBER_TOBE_GIVEN_IMAGE];
    } else if ([status isEqualToString:SELF_ADMINISTERED]) {
        image = [UIImage imageNamed:PRESCRIBER_SELF_ADMINISTERED_IMAGE];
    }
    return image;
}

- (void)setMedicationSlot:(DCMedicationSlot *)medicationSlot {
    _medicationSlot = medicationSlot;
    self.timeLabel.text = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"HH:mm"];
    if ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        if (!medicationSlot.medicationAdministration.status) {
            self.statusImageView.image = [self getMedicationStatusImageForMedicationStatus:YET_TO_GIVE];
        }
    } else {
        
        self.statusImageView.image = [self getMedicationStatusImageForMedicationStatus:medicationSlot.status];
    }
}

@end
