//
//  DCMedicationScheduleDetails.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import "DCMedicationScheduleDetails.h"
#import "DCMedicationSlot.h"

#define MED_DATE @"medDate"
#define MED_DETAILS @"medDetails"

#define DRUG_NAME @"originalTerm"
#define DRUG_DOSAGE @"dosage"
#define DRUG_INSTRUCTION @"instructions"
#define DRUG_ROUTE @"route"
#define DRUG_START_DATE @"startDateTime"
#define DRUG_CATEGORY @"drugScheduleType"
#define DRUG_ENDDATE @"endDateTime"
#define DRUG_SCHEDULES @"schedules"
#define DRUG_ADMINISTRATIONS @"administrations"
#define DRUG_SCHEDULE_TIMES @"times"
#define DRUG_IDENTIFIER @"identifier"
#define DRUG_IS_ACTIVE @"isActive"
#define DRUG_PRESCRIBING_USER @"prescribingUser"
#define DOSAGE @"dosage"
#define ROUTE @"route"
#define SCHEDULE_ID @"identifier"
#define NEXT_DRUG_TIME @"nextDrugDateTime"



@implementation DCMedicationScheduleDetails

- (DCMedicationScheduleDetails *)initWithMedicationScheduleDictionary:(NSDictionary *)medicationDictionary {
    
    self = [[DCMedicationScheduleDetails alloc] init];
    self.name = [medicationDictionary valueForKey:DRUG_NAME];
    self.medicineCategory = [medicationDictionary valueForKey:DRUG_CATEGORY];
    if ([medicationDictionary valueForKey:DRUG_PRESCRIBING_USER]) {
        NSDictionary *userDictionary = [medicationDictionary valueForKey:DRUG_PRESCRIBING_USER];
        DCUser *prescriber = [[DCUser alloc] initWithUserDetails:userDictionary];
        self.prescribingUser = prescriber;
    }
    NSString *startDateString = [medicationDictionary valueForKey:DRUG_START_DATE];
    self.startDate = [startDateString stringByReplacingOccurrencesOfString:@"T"
                                                                withString:@" "];
    NSString *endDateString = [medicationDictionary valueForKey:DRUG_ENDDATE];
    self.endDate = [endDateString stringByReplacingOccurrencesOfString:@"T"
                                                            withString:@" "];
    self.dosage = [medicationDictionary valueForKey:DRUG_DOSAGE];
    self.route = [medicationDictionary valueForKey:DRUG_ROUTE];
    self.instruction = [medicationDictionary valueForKey:DRUG_INSTRUCTION];
    self.medicationId = [medicationDictionary valueForKey:DRUG_IDENTIFIER];
    self.scheduleId = [medicationDictionary valueForKey:SCHEDULE_ID];
    self.nextMedicationDate = [medicationDictionary valueForKey:NEXT_DRUG_TIME];
    
    NSNumber *activeValue = [NSNumber numberWithInt:[[medicationDictionary valueForKey:DRUG_IS_ACTIVE] intValue]];
    self.isActive = [activeValue boolValue];
    NSArray *scheduleArray = (NSArray *)[medicationDictionary objectForKey:DRUG_SCHEDULES];
    if ([scheduleArray count] > 0) {
        NSDictionary *schedulesDictionary = [scheduleArray objectAtIndex:0];
        NSMutableArray *administrationArray = [[NSMutableArray alloc] initWithArray:[schedulesDictionary objectForKey:DRUG_ADMINISTRATIONS]];
        self.administrationDetailsArray = [self getAdministrationDetailsForMedication:administrationArray];
        NSMutableArray *slotsArray = [self getMedicationScheduleTimeArrayFromScheduleDictionary:schedulesDictionary
                                                                                  withStartDate:self.startDate
                                                                                     andEndDate:self.endDate
                                                                               withActiveStatus:self.isActive];
        self.timeChart = slotsArray;
        NSLog(@"the slots array: %@", slotsArray);
        if ([schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES]) {
            self.scheduleTimesArray = [schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES];
        }
    }
    return self;
}

#pragma mark - Private methods

- (NSMutableArray *)getAdministrationDetailsForMedication:(NSArray *)administrationArray {
    
    NSMutableArray *administrationDetailsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *administrationDictionary in administrationArray) {
        DCMedicationAdministration *medicationAdministration = [[DCMedicationAdministration alloc] initWithAdministrationDetails:administrationDictionary];
        [administrationDetailsArray addObject:medicationAdministration];
    }
    NSLog(@"the administer array: %@", administrationDetailsArray);
    return administrationDetailsArray;
}

//TODO: this method need to be re verified.
- (NSMutableArray *)getMedicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
                                                           withStartDate:(NSString *)startDateString
                                                              andEndDate:(NSString *)endDateString
                                                        withActiveStatus:(BOOL)isActive {
    
    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:DRUG_SCHEDULE_TIMES];
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate * startDate = [DCDateUtility dateFromSourceString:startDateString];
    NSDate *endDate;
    if (endDateString == nil) {
        endDate = [[NSDate date] dateByAddingTimeInterval:21*24*60*60];
    }
    else {
        endDate = [DCDateUtility dateFromSourceString:endDateString];
    }
    NSDate *nextDate;
    for ( nextDate = startDate ; [nextDate compare:endDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
        
        NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
        NSInteger timeSlotsCount = 0;
        while (timeSlotsCount < [timesArray count]) {

            NSCalendar *calendar = [NSCalendar currentCalendar];
            //TODO: Error in setting time chart. Timezone commented to fix the display issue in calendar
            [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:nextDate];
            NSString *timeString = [timesArray objectAtIndex:timeSlotsCount];
            NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
            if ([timeComponents count] >= 3 ) {
                [components setDay:components.day];
                [components setHour:[[timeComponents objectAtIndex:0] integerValue]];
                [components setMinute:[[timeComponents objectAtIndex:1] integerValue]];
                [components setSecond:[[timeComponents objectAtIndex:2] integerValue]];
            }
            NSDate *medicationDateTime = [calendar dateFromComponents:components];
            DCMedicationSlot *medicationSlot = [[DCMedicationSlot alloc] init];
            medicationSlot.time = medicationDateTime;
            //TODO:set for demo purpose since there is no value for medication slot status
            medicationSlot.status = IS_GIVEN;

            NSLog(@"the predicate string is: %@", [NSString stringWithFormat:@"scheduledDateTime == %@",medicationDateTime]);
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"scheduledDateTime == %@",medicationDateTime];
            NSArray *resultsArray = [self.administrationDetailsArray filteredArrayUsingPredicate:datePredicate];
            
            //TODO: this is not actual medication status value
            if ([resultsArray count] > 0) {
                DCMedicationAdministration *medicationAdministration = (DCMedicationAdministration *)[resultsArray objectAtIndex:0];
                medicationSlot.status = medicationAdministration.status;
                medicationSlot.medicationAdministration = medicationAdministration;
            }
            
            [medicationSlotsArray addObject:medicationSlot];
            timeSlotsCount++;
        }
        NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
        [shortDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
        NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
        
        [timeSlotsArray addObject:@{MED_DATE:medicationDateString,MED_DETAILS:medicationSlotsArray}];
    }
    return timeSlotsArray;
}



@end
