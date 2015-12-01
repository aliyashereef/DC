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
        if (selectedMedication.timeArray.count == 0) {
            return !isValid;
        }
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

+ (CellType)cellTypeForSpecificTimesSchedulingAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the cell type corresponding to Specific times.
    CellType cellType;
    switch (indexPath.row) {
        case ADMINISTRATION_CELL_INDEX:
            cellType = eAdministratingTimeCell;
            break;
        case REPEAT_CELL_INDEX:
            cellType = eRepeatCell;
            break;
        default:
            break;
    }
    return cellType;
}

+ (AddMedicationDetailType)medicationDetailTypeForIndexPath:(NSIndexPath *)indexPath hasWarnings:(BOOL)showWarnings {
    
    switch (indexPath.section) {
        case eFirstSection: {
            if (showWarnings) {
                return eDetailWarning;
            } else {
                if (indexPath.row == ROUTE_INDEX) {
                    return eDetailRoute;
                } else {
                    return eDetailType;
                }
            }
        }
        case eSecondSection: {
            if (showWarnings) {
                if (indexPath.row == ROUTE_INDEX) {
                    return eDetailRoute;
                } else {
                    return eDetailType;
                }
            }
        }
        case eFourthSection: {
            if (showWarnings) {
                return eDetailSchedulingType;
            } else {
                return eDetailDosage;
            }
        }
        case eFifthSection:
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


@end
