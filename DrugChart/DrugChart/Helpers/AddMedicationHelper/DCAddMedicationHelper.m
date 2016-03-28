//
//  SCAddMedicationHelper.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/10/15.
//
//

#import "DCAddMedicationHelper.h"

#define MEDICINE_NAME_FIELD_MAX_WIDTH   310
#define OFFSET_VALUE 15
#define INSTRUCTION_OFFSET_VALUE 18.0

@implementation DCAddMedicationHelper

+ (BOOL)selectedMedicationDetailsAreValid:(DCMedicationDetails *)selectedMedication {
    
    BOOL isValid = YES;
    if ([selectedMedication.name isEqualToString:EMPTY_STRING] || selectedMedication.name == nil ||
        [selectedMedication.dosage isEqualToString:EMPTY_STRING] || selectedMedication.dosage == nil ||
        [selectedMedication.route isEqualToString:EMPTY_STRING] || selectedMedication.route == nil ||
        ![self dosageIsValidForSelectedMedication:selectedMedication.dose]) {
        return !isValid;
    }
    if ([selectedMedication.medicineCategory isEqualToString:EMPTY_STRING] || selectedMedication.medicineCategory == nil) {
        return !isValid;
    }
    if (![self isDateAndTimeSectionValidForMedicationDetails:selectedMedication]) {
        //validate added medication type view
        return !isValid;
    }
    return isValid;
}

+ (BOOL)isDateAndTimeSectionValidForMedicationDetails:(DCMedicationDetails *)selectedMedication {
    
    BOOL isValid = YES;
    NSString *selectedMedicationType = selectedMedication.medicineCategory;
    if ([selectedMedicationType isEqualToString:ONCE_MEDICATION]) {
        if ([selectedMedication.startDate isEqualToString:EMPTY_STRING]) {
            return !isValid;
        }
    } else {
        if (![self isRegularOrWhenRequiredTimeFieldsValidForSelectedMedication:selectedMedication]) {
            return !isValid;
        }
    }
    return isValid;
}

+ (BOOL)isRegularOrWhenRequiredTimeFieldsValidForSelectedMedication:(DCMedicationDetails *)selectedMedication {
    
    BOOL isValid = YES;
    if ([selectedMedication.startDate isEqualToString:EMPTY_STRING] || selectedMedication.startDate == nil) {
        return !isValid;
    }
    if (selectedMedication.hasEndDate) {
        if ([selectedMedication.endDate isEqualToString:EMPTY_STRING] || selectedMedication.endDate == nil) {
            return !isValid;
        }
    }
    if ([selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        if (![self frequencyIsValidForSelectedMedication:selectedMedication]) {
            return !isValid;
        }
//        if (selectedMedication.timeArray.count == 0) {
//            return !isValid;
//        }
    }
    return isValid;
}

+ (CGFloat)heightForMedicineName:(NSString *)medicine {
    
    //get the height of medicine name to set the corresponding cell height
    CGFloat height = [DCUtility heightValueForText:medicine withFont:SYSTEM_FONT_SIZE_FIFTEEN maxWidth:MEDICINE_NAME_FIELD_MAX_WIDTH] + OFFSET_VALUE;
    return height;
}

+ (NSMutableArray *)timesArrayFromScheduleArray:(NSArray *)scheduleArray {
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    for (NSString *time in scheduleArray) {
        NSString *dateString = [DCUtility convertTimeToHourMinuteFormat:time];
        NSDictionary *dict = @{TIME : dateString, SELECTED : @1};
        [timeArray addObject:dict];
    }
    return timeArray;
}

+ (NSInteger)numberOfSectionsInMedicationTableViewForSelectedMedication:(DCMedicationScheduleDetails *)selectedmedication
                                                           showWarnings:(BOOL)showWarnings {
    
    //If medicine name is not selected, the number of sections in tableview will be 1 , On medicine name selection, the section count vary based on warnings presence
    if ([selectedmedication.name isEqualToString:EMPTY_STRING] || selectedmedication.name == nil) {
        return INITIAL_SECTION_COUNT;
    } else {
        if ([selectedmedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
            return (showWarnings ? REGULAR_MEDICATION_SECTION_COUNT : REGULAR_MEDICATION_SECTION_COUNT - 1);
        } else {
            return (showWarnings ? ONCE_WHEN_REQUIRED_SECTION_COUNT : ONCE_WHEN_REQUIRED_SECTION_COUNT - 1);
        }
    }
    return INITIAL_SECTION_COUNT;
}

+ (BOOL)frequencyIsValidForSelectedMedication:(DCMedicationDetails *)selectedMedication {
    
    //scheduling field is valid for selected medication
    BOOL isValid = true;
    if (selectedMedication.scheduling.type == nil || ([selectedMedication.scheduling.type isEqualToString:SPECIFIC_TIMES] && selectedMedication.timeArray.count == 0) || ([selectedMedication.scheduling.type isEqualToString:INTERVAL] && selectedMedication.scheduling.interval.hasStartAndEndDate && selectedMedication.timeArray.count == 0)) {
        isValid = false;
    }
    return isValid;
}

+ (NSString *)considatedFrequencyDescriptionFromString:(NSString *)description {
    
    NSString *substring = NSLocalizedString(@"SCHEDULING_GENERAL_DESCRIPTION", "");
    description = [DCUtility removeSubstring:substring FromOriginalString:[NSMutableString stringWithString:description]];
    //capitalise first character
    description = [DCUtility capitaliseFirstCharacterOfString:description];
    description = [NSMutableString stringWithString:[DCUtility removeLastCharacterFromString:description]];
    return description;
}

+ (CGFloat)textContentHeightForDosage:(NSString *)dosage {
    
    CGSize textSize = [DCUtility textViewSizeWithText:dosage maxWidth:258 font:[UIFont systemFontOfSize:15]];
    return textSize.height + 40; // padding size of 40
}

+ (void)configureAddMedicationCellLabel:(UILabel *)label
                         forContentText:(NSString *)content
                    forSaveButtonAction:(BOOL)clicked {
    
    //configure medication cell label text
    if (clicked) {
        if ([content isEqualToString:EMPTY_STRING] || content == nil) {
            label.textColor = [UIColor redColor];
        } else {
            label.textColor = [UIColor blackColor];
        }
    } else {
        label.textColor = [UIColor blackColor];
    }
}

+ (NSInteger)routesTableViewSectionCountForSelectedRoute:(NSString *)route {
    
    if ([self routeIsIntravenousOrSubcutaneous:route]) {
        return 2;
    } else {
        return 1;
    }
}

+ (BOOL)routeIsIntravenousOrSubcutaneous:(NSString *)route {
    
    return ([route containsString:@"Intravenous"]|| [route containsString:@"Subcutaneous"]);
}

+ (CGFloat)instructionCellHeightForInstruction:(NSString *)instructions {
    
    CGFloat height = [DCUtility heightValueForText:instructions withFont:[UIFont systemFontOfSize:15.0] maxWidth:289.0];
    if (height <= INSTRUCTIONS_ROW_HEIGHT) {
        return INSTRUCTIONS_ROW_HEIGHT;
    } else {
        return height + INSTRUCTION_OFFSET_VALUE;
    }
}

+ (BOOL)dosageIsValidForSelectedMedication:(DCDosage *)dosage {

    if ([dosage.type isEqualToString:DOSE_SPLIT_DAILY]) {
        NSMutableArray *selectedDoseArray;
        if (dosage.splitDailyDose.timeArray != nil) {
            selectedDoseArray = [self configureDoseArray:dosage.splitDailyDose.timeArray];
            //
            NSString *valueStringForRequiredDailyDose = dosage.splitDailyDose.dailyDose;
            float valueForRequiredDailyDose = (valueStringForRequiredDailyDose).floatValue;
            if (![valueStringForRequiredDailyDose  isEqual: @""] && valueForRequiredDailyDose != 0 && selectedDoseArray.count != 0) {
                float totalValueForDose = 0;
                float valueOfDoseAtIndex = 0;
                int countOfItemsWithDoseValueSelected = 0;
                for(int index=0;index<selectedDoseArray.count;index++) {
                    if (![selectedDoseArray[index]  isEqual: @""]) {
                        valueOfDoseAtIndex = [NSString stringWithFormat:@"%@",selectedDoseArray[index]].floatValue;
                        totalValueForDose += valueOfDoseAtIndex;
                        countOfItemsWithDoseValueSelected++;
                    }
                }
                if (totalValueForDose == valueForRequiredDailyDose && countOfItemsWithDoseValueSelected == selectedDoseArray.count) {
                    return true;
                } else if (totalValueForDose == valueForRequiredDailyDose && countOfItemsWithDoseValueSelected < selectedDoseArray.count) {
                    return false;
                } else if (totalValueForDose < valueForRequiredDailyDose) {
                    return false;
                } else {
                    return false;
                }
            } else {
                return true;
            }
        } else {
            return true;
        }
    } else {
        return true;
    }
}

+ (NSMutableArray *)configureDoseArray:(NSArray *)timeArray {
    
    NSMutableArray *doseArray = [[NSMutableArray alloc] init];
    //Extract the selected times and update time array and dose array.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == 1"];
    timeArray = [timeArray filteredArrayUsingPredicate:predicate];
    if (timeArray.count != 0) {
        for (NSDictionary *timeDictionary in timeArray) {
            NSString *value = timeDictionary[@"dose"];
            if (value != nil) {
                    //Value is present for the key "dose".
                [doseArray addObject:value];
            } else {
                //key "dose" is not present in dict
                [doseArray addObject:@"" ];
            }
        }
    }
    return doseArray;
}

@end
