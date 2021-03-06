//
//  DCMedicationScheduleDetails.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DCMedicationDetails.h"
#import "DCInactiveDetails.h"
#import "DCUser.h"
#import "DCMedicationStoppage.h"

@interface DCMedicationScheduleDetails : DCMedicationDetails

@property (nonatomic, strong) DCUser *prescribingUser;
@property (nonatomic, strong) NSString *scheduleId;
@property (nonatomic, strong) NSString *nextMedicationDate;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) DCMedicationStoppage *stoppage;
@property (nonatomic, strong) DCInactiveDetails *inactiveDetails;
@property (nonatomic, strong) NSMutableArray *administrationDetailsArray;
@property (nonatomic, strong) NSMutableArray *timeChart;

- (DCMedicationScheduleDetails *)initWithMedicationScheduleDictionary:(NSDictionary *)medicationDictionary forWeekStartDate:(NSDate *)weekStartDate weekEndDate:(NSDate *)weekEndDate;

@end
