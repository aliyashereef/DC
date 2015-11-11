//
//  SCAddMedicationHelper.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/10/15.
//
//

#import <Foundation/Foundation.h>
#import "DCMedicationDetails.h"

#define INITIAL_SECTION_COUNT                   1
#define MEDICATION_NAME_ROW_COUNT               1
#define PICKER_ROW_COUNT                        1
#define COMPLETE_MEDICATION_SECTION_COUNT       5
#define WARNINGS_ROW_COUNT                      1
#define MEDICATION_DETAILS_ROW_COUNT            3
#define INSTRUCTIONS_ROW_COUNT                  1
#define REGULAR_DATEANDTIME_ROW_COUNT           4
#define ONCE_DATEANDTIME_ROW_COUNT              1
#define WHEN_REQUIRED_DATEANDTIME_ROW_COUNT     3
#define DOSAGE_INDEX                            0
#define ROUTE_INDEX                             1
#define TYPE_INDEX                              2
#define START_DATE_ROW_INDEX                    0
#define NO_END_DATE_ROW_INDEX                   1
#define END_DATE_ROW_INDEX                      2
#define ADMINISTRATING_TIME_ROW_INDEX           3
#define INSTRUCTIONS_ROW_HEIGHT                 78
#define TABLE_CELL_DEFAULT_ROW_HEIGHT           42
#define ADD_MEDICATION_INDEX                    0
#define DATE_PICKER_INDEX_START_DATE            1
#define DATE_PICKER_INDEX_END_DATE              3
#define ADMINISTRATING_TITLE_LABEL_WIDTH        150.0f
#define TIME_TITLE_LABEL_WIDTH                  100.0f
#define HEADER_VIEW_HEIGHT                      10.0f
#define PICKER_VIEW_CELL_HEIGHT                 200.0f
#define WARNINGS_CELL_INDEX                     0
#define MEDICATION_DETAILS_CELL_INDEX           1
#define ADMINISTRATION_CELL_INDEX               2
#define MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE 15             

//Constants
static NSString *kDateCellID = @"datecell";
static NSString *kDatePickerID = @"pickercell";
static NSString *kDosageMultiLineCellID = @"DosageMultiLineCell";
typedef enum : NSInteger {
    
    eZerothSection,
    eFirstSection,
    eSecondSection,
    eThirdSection,
    eFourthSection,
} SectionCount;

@interface DCAddMedicationHelper : NSObject

+ (BOOL)selectedMedicationDetailsAreValid:(DCMedicationDetails *)selectedMedication;

+ (CGFloat)heightForMedicineName:(NSString *)medicine;

+ (NSMutableArray *)getTimesArrayFromScheduleArray:(NSArray *)scheduleArray ;

@end
