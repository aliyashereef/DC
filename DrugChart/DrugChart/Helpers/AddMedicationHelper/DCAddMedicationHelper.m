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
        NSDictionary *dict = @{@"time" : dateString, @"selected" : @1};
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

@end
