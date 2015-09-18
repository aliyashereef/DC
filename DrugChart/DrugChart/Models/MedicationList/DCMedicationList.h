//
//  DCMedicationList.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/03/15.
//
//

#import <Foundation/Foundation.h>
#import "DCUser.h"

#define MEDICATION_TIME @"time"
#define MEDICATION_STATUS @"status"


#define NEXT_MEDICATION_DATE_KEY @"nextMedicationDate"

typedef enum : NSUInteger {
    kMedicationGiven,
    kMedicationToGive,
    kMedicationNotGiven,
    kMedicationRejected,
    kMedicationInvalidStatus
} MedicationConsumptionStatus;

@interface DCMedicationList : NSObject

@property (nonatomic, strong) NSString *name;//DCMedication
@property (nonatomic, strong) NSString *medicineCategory;//DCMedicationDetails
@property (nonatomic, strong) NSString *medicationId;//DCMedication
@property (nonatomic, strong) NSString *dosage;//DCMedication
@property (nonatomic, strong) NSString *prescribedBy;
@property (nonatomic, strong) NSString *startDate;//DCMedicationScheduleDetails
@property (nonatomic, strong) NSDate *medicationStartDate;
@property (nonatomic, strong) NSString *endDate;//DCMedicationScheduleDetails
@property (nonatomic, strong) NSMutableArray *timeChart;//DCMedicationScheduleDetails
@property (nonatomic, assign) MedicationConsumptionStatus medicationConsumptionStatus;
@property (nonatomic, strong) NSString *nextMedicationDate;//DCMedicationScheduleDetails
@property (nonatomic, strong) NSString *route;//DCMedicationDetails
@property (nonatomic, strong) NSString *instruction;//DCMedicationDetails
@property (nonatomic, strong) NSString *scheduleId;//DCMedicationScheduleDetails
@property (nonatomic) BOOL medicationStatus;
@property (nonatomic) BOOL addMedicationCompletionStatus;

//new
@property (nonatomic) BOOL isActive;//DCMedicationScheduleDetails
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) DCUser *prescribingUser;//DCMedicationScheduleDetails
@property (nonatomic, strong) NSMutableArray *scheduleTimesArray;//DCMedicationDetails

//@property (nonatomic, strong) NSString *resourceType;
//@property (nonatomic, strong) NSString *productText;

@property BOOL hasWarning;
@property (nonatomic, strong) NSNumber *severeWarningCount;
@property (nonatomic, strong) NSNumber *mildWarningCount;
@property (nonatomic, strong) NSString *warning; //for temp purpose

@property (nonatomic, strong) NSString *onceMedicationDate;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic) BOOL noEndDate;
@property (nonatomic) BOOL overiddenSevereWarning;

@property (nonatomic, strong) NSMutableArray *administrationDetailsArray;//DCMedicationScheduleDetails


- (DCMedicationList *)initWithMedicationScheduleDictionaryForAPI:(NSDictionary *)medicationDictionary;
- (DCMedicationList *)initWithOrderSetMedicationDictionary :(NSDictionary *)medicationDictionary;
- (DCMedicationList *)initWithSearchMedicationDictionary :(NSDictionary *)medicationDictionary ;

@end

