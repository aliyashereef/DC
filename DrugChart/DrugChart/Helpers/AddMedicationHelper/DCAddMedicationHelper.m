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

@implementation DCAddMedicationHelper

+ (BOOL)selectedMedicationDetailsAreValid:(DCMedicationDetails *)selectedMedication {
    
    BOOL isValid = YES;
    if ([selectedMedication.name isEqualToString:EMPTY_STRING] || selectedMedication.name == nil ||
        [selectedMedication.dosage isEqualToString:EMPTY_STRING] || selectedMedication.dosage == nil ||
        [selectedMedication.route isEqualToString:EMPTY_STRING] || selectedMedication.route == nil) {
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

+ (AddMedicationDetailType)medicationDetailTypeForIndexPath:(NSIndexPath *)indexPath hasWarnings:(BOOL)showWarnings medicationType:(NSString *)type {
    
    switch (indexPath.section) {
        case eSecondSection: {
            if (showWarnings) {
                return eDetailWarning;
            } else {
                return eDetailType;
            }
        }
        case eThirdSection: {
            if (showWarnings) {
                return eDetailType;
            }
        }
        case eFourthSection: {
            
            if (!showWarnings) {
                if (![type isEqualToString:REGULAR_MEDICATION]) {
                    return eDetailDosage;
                }
            }
        }
        case eFifthSection: {
            return eDetailDosage;
        }
        case eSixthSection:
            if (showWarnings) {
                return eDetailDosage;
            }
        default:
             return 0;
    }
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
    
    CGFloat height = [DCUtility heightValueForText:instructions withFont:[UIFont systemFontOfSize:15.0] maxWidth:289.0] + 2.0;
    if (height <= INSTRUCTIONS_ROW_HEIGHT) {
        return INSTRUCTIONS_ROW_HEIGHT;
    } else {
        return height;
    }
}

@end
