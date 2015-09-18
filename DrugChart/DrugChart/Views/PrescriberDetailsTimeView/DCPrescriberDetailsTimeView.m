//
//  DCPrescriberDetailsTimeView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/12/15.
//
//

#import "DCPrescriberDetailsTimeView.h"

#define OMITTED_IMAGE @"DetailOmittedIcon"
#define OMITTED_IMAGE_SELECTED @"DetailOmittedOverIcon"
#define ADMINISTERED_IMAGE @"DetailAdministeredIcon"
#define ADMINISTERED_IMAGE_SELECTED @"DetailAdministeredOverIcon"
#define REFUSED_IMAGE @"DetailRefusedIcon"
#define REFUSED_IMAGE_SELECTED @"DetailRefusedOverIcon"
#define TO_GIVE_IMAGE @"DetailYetToGive"
#define TO_GIVE_IMAGE_SELECTED @"DetailYetToGiveOver"
#define SELF_ADMINISTERED_IMAGE @"DetailSelfAdministeredIcon"
#define SELF_ADMINISTERED_IMAGE_SELECTED @"DetailSelfAdministeredOverIcon"

#define TIME_LABEL_LEADING_YET_TO_GIVE 0.0f
#define TIME_LABEL_LEADING_NORMAL 29.0f

@interface DCPrescriberDetailsTimeView () {
    
    __weak IBOutlet UIImageView *statusImageView;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet NSLayoutConstraint *timeLabelLeadingConstraint;
    
}

@end

@implementation DCPrescriberDetailsTimeView



- (void)setMedicationSlotValuesForSelectedState:(BOOL)selected {
    
    NSString *medicationTime = [DCDateUtility convertDate:_medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:TWENTYFOUR_HOUR_FORMAT];
    timeLabel.text = medicationTime;
    if ([_medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        
        if (selected) {
             statusImageView.image = [self getPrescriberDetailStatusSelectedImageForMedicationStatus:YET_TO_GIVE];
            timeLabel.textColor = [UIColor whiteColor];
        } else {
             statusImageView.image = [self getPrescriberDetailStatusUnselectedImageForMedicationStatus:YET_TO_GIVE];
            timeLabel.textColor = [UIColor darkGrayColor];
        }
        timeLabelLeadingConstraint.constant = TIME_LABEL_LEADING_NORMAL;
    } else if ([_medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedAscending) {
        
        if (selected) {
            statusImageView.image = [self getPrescriberDetailStatusSelectedImageForMedicationStatus:_medicationSlot.status];
            timeLabel.textColor = [UIColor whiteColor];
        } else {
            statusImageView.image = [self getPrescriberDetailStatusUnselectedImageForMedicationStatus:_medicationSlot.status];
            timeLabel.textColor = [UIColor blackColor];
        }
        timeLabelLeadingConstraint.constant = TIME_LABEL_LEADING_NORMAL;
    } else {
        
        timeLabel.textColor = [UIColor darkGrayColor];
        if (selected) {
            statusImageView.image = [self getPrescriberDetailStatusSelectedImageForMedicationStatus:YET_TO_GIVE];
            timeLabel.textColor = [UIColor whiteColor];
        } else {
            statusImageView.image = [self getPrescriberDetailStatusUnselectedImageForMedicationStatus:YET_TO_GIVE];
            timeLabel.textColor = [UIColor darkGrayColor];
        }
        timeLabelLeadingConstraint.constant = TIME_LABEL_LEADING_NORMAL;
    }
    [self layoutIfNeeded];
}

- (UIImage *)getPrescriberDetailStatusUnselectedImageForMedicationStatus:(NSString *)status {
    
    UIImage *image;
    if ([status isEqualToString:OMITTED]) {
        image = [UIImage imageNamed:OMITTED_IMAGE];
    } else if ([status isEqualToString:IS_GIVEN]) {
        image = [UIImage imageNamed:ADMINISTERED_IMAGE];
    } else if ([status isEqualToString:REFUSED]) {
        image = [UIImage imageNamed:REFUSED_IMAGE];
    } else if ([status isEqualToString:YET_TO_GIVE]) {
        image = [UIImage imageNamed:TO_GIVE_IMAGE];
    } else if ([status isEqualToString:SELF_ADMINISTERED]) {
        image = [UIImage imageNamed:SELF_ADMINISTERED_IMAGE];
    } else {
        image = [UIImage imageNamed:ADMINISTERED_IMAGE];
    }
    return image;
}

- (UIImage *)getPrescriberDetailStatusSelectedImageForMedicationStatus:(NSString *)status {
    
    UIImage *image;
    if ([status isEqualToString:OMITTED]) {
        image = [UIImage imageNamed:OMITTED_IMAGE_SELECTED];
    } else if ([status isEqualToString:IS_GIVEN]) {
        image = [UIImage imageNamed:ADMINISTERED_IMAGE_SELECTED];
    } else if ([status isEqualToString:REFUSED]) {
        image = [UIImage imageNamed:REFUSED_IMAGE_SELECTED];
    } else if ([status isEqualToString:YET_TO_GIVE]) {
        image = [UIImage imageNamed:TO_GIVE_IMAGE_SELECTED];
    } else {
        image = [UIImage imageNamed:SELF_ADMINISTERED_IMAGE_SELECTED];
    }
    return image;
}

#pragma mark - Action Methods

- (IBAction)timeViewButtonClicked:(id)sender {
    
    [self setMedicationSlotValuesForSelectedState:YES];
    self.timeAction();
}


@end
