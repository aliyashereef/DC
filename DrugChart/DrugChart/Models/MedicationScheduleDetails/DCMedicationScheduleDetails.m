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

- (DCMedicationScheduleDetails *)initWithMedicationScheduleDictionary:(NSDictionary *)medicationDictionary forWeekStartDate:(NSDate *)weekStartDate weekEndDate:(NSDate *)weekEndDate {
    
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
        NSMutableArray *administrationArray;
        NSDictionary *schedulesDictionary = [scheduleArray objectAtIndex:0];
        if ([self.medicineCategory isEqualToString:WHEN_REQUIRED]) {
            NSMutableArray *adminDetails = [[NSMutableArray alloc] init];
            for (NSDictionary *scheduleDict in scheduleArray) {
                [adminDetails addObject:[[scheduleDict objectForKey:DRUG_ADMINISTRATIONS] objectAtIndex:0]];
            }
            administrationArray = adminDetails;
            self.administrationDetailsArray = [self administrationDetailsForMedication:administrationArray];
            NSMutableArray *slotsArray = [self medicationScheduleTimeArrayForWhenRequiredMedicationsForStartWeekDate:weekStartDate endWeekDate:weekEndDate withActiveStatus:self.isActive];
            self.timeChart = slotsArray;
        } else {
            administrationArray = [[NSMutableArray alloc] initWithArray:[schedulesDictionary objectForKey:DRUG_ADMINISTRATIONS]];
            self.administrationDetailsArray = [self administrationDetailsForMedication:administrationArray];
            NSMutableArray *slotsArray = [self medicationScheduleTimeArrayFromScheduleDictionary:schedulesDictionary
                                                                                  withStartWeekDate:weekStartDate endWeekDate:weekEndDate withActiveStatus:self.isActive];
            self.timeChart = slotsArray;
        }
      
        if ([schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES]) {
            self.scheduleTimesArray = [schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES];
        }
    }
    return self;
}

#pragma mark - Private methods

- (NSMutableArray *)administrationDetailsForMedication:(NSArray *)administrationArray {
    
    NSMutableArray *administrationDetailsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *administrationDictionary in administrationArray) {
        DCMedicationAdministration *medicationAdministration = [[DCMedicationAdministration alloc] initWithAdministrationDetails:administrationDictionary];
        [administrationDetailsArray addObject:medicationAdministration];
    }
    return administrationDetailsArray;
}


- (NSDate *)startDateForMedicationStartdate:(NSDate *)medicationStartDate
                                                    medicationEndDate:(NSDate *)medicationEndDate
                                                        startWeekDate:(NSDate *)startWeekDate
                                                          endWeekDate:(NSDate *)endWeekDate {
    
    NSDate *calculatedStartDate;
    if ([medicationEndDate compare:startWeekDate] == NSOrderedAscending) {
        // medication has ended before current week
        calculatedStartDate = nil;
    } else {
        if ([medicationStartDate compare:startWeekDate] == NSOrderedAscending ||
            [medicationStartDate compare:startWeekDate] == NSOrderedSame) {
            // medication has started before current week
            calculatedStartDate = startWeekDate;
        } else {
            // medication has started some where between the selected week schedules
            calculatedStartDate = medicationStartDate;
        }
    }
    return calculatedStartDate;
}

- (NSDate *)endDateForMedicationStartdate:(NSDate *)medicationStartDate
                             medicationEndDate:(NSDate *)medicationEndDate
                                 startWeekDate:(NSDate *)startWeekDate
                                 endWeekDate:(NSDate *)endWeekDate {
    
    NSDate *calculatedEndDate;
    if ([medicationEndDate compare:startWeekDate] == NSOrderedAscending) {
        // medication has ended before current week
        calculatedEndDate = nil;
    } else {
        if ([medicationEndDate compare:endWeekDate] == NSOrderedAscending ||
            [medicationEndDate compare:endWeekDate] == NSOrderedSame) {
            //medication end date is coming before week end date
            calculatedEndDate = medicationEndDate;
       } else {
            //medication extends even after the current 3 weeks schedule
            calculatedEndDate = endWeekDate;
        }
    }
    return calculatedEndDate;
}


- (NSMutableArray *)medicationScheduleTimeArrayForWhenRequiredMedicationsForStartWeekDate:(NSDate *)startWeekDate
                                                          endWeekDate:(NSDate *)endWeekDate
                                                        withActiveStatus:(BOOL)isActive {
    
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.startDate];
    NSDate *endDate;
    if (self.endDate == nil) {
        endDate = endWeekDate; //max limit to be displayed is end week date
    } else {
        endDate = [DCDateUtility dateFromSourceString:self.endDate];
    }
    NSDate *calculatedStartDate = [self startDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *calculatedEndDate = [self endDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *nextDate;
    if (calculatedStartDate != nil && calculatedEndDate != nil) {
        for (nextDate = calculatedStartDate ; [nextDate compare:calculatedEndDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
            NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
            NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
            [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
            [shortDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
            NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"scheduledDateTime.description contains[cd] %@", medicationDateString];
            NSArray *resultsArray = [self.administrationDetailsArray filteredArrayUsingPredicate:datePredicate];
            for (DCMedicationAdministration *administration  in resultsArray) {
                DCMedicationSlot *medicationSlot = [[DCMedicationSlot alloc] init];
                medicationSlot.time = administration.scheduledDateTime;
                medicationSlot.status = IS_GIVEN;
                medicationSlot.medicationAdministration = administration;
                [medicationSlotsArray addObject:medicationSlot];
            }
            [timeSlotsArray addObject:@{MED_DATE:medicationDateString,MED_DETAILS:medicationSlotsArray}];
        }
    }
    return timeSlotsArray;
}


- (NSMutableArray *)medicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
                                                           withStartWeekDate:(NSDate *)startWeekDate
                                                              endWeekDate:(NSDate *)endWeekDate
                                                        withActiveStatus:(BOOL)isActive {
    
    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:DRUG_SCHEDULE_TIMES];
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.startDate];
    NSDate *endDate;
    if (self.endDate == nil) {
        endDate = endWeekDate; //max limit to be displayed is end week date
    }
    else {
        endDate = [DCDateUtility dateFromSourceString:self.endDate];
    }
    
    NSDate *calculatedStartDate = [self startDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *calculatedEndDate = [self endDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *nextDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
    if (calculatedStartDate != nil && calculatedEndDate != nil) {
        for (nextDate = calculatedStartDate ; [nextDate compare:calculatedEndDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
            NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
            NSInteger timeSlotsCount = 0;
            NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:nextDate];
            while (timeSlotsCount < [timesArray count]) {
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
    }
    return timeSlotsArray;
}

@end
