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
        NSDictionary *schedulesDictionary = [scheduleArray objectAtIndex:0];
        NSMutableArray *administrationArray = [[NSMutableArray alloc] initWithArray:[schedulesDictionary objectForKey:DRUG_ADMINISTRATIONS]];
        self.administrationDetailsArray = [self getAdministrationDetailsForMedication:administrationArray];
        NSMutableArray *slotsArray = [self getMedicationScheduleTimeArrayFromScheduleDictionary:schedulesDictionary
                                                                                  withStartWeekDate:weekStartDate andEndWeekDate:weekEndDate withActiveStatus:self.isActive];

        self.timeChart = slotsArray;
        if ([schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES]) {
            self.scheduleTimesArray = [schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES];
        }
    }
    return self;
}


//- (void)updateDrugScheduleTimeChartForSchedule:(DCMedicationScheduleDetails *)medicationScheduleDetails
//                  withScheduleDetailDictionary:(NSDictionary *)medicationDictionary
//                                  forStartDate:(NSString *)startDateString
//                                    andEndDate:(NSString *)endDateString{
//    
//    // here get the new administration details added to the timeChart array.
//    // no other objet need to be touched,
//    if ([[medicationDictionary allKeys] containsObject:DRUG_SCHEDULES]) {
//        NSArray *scheduleArray = (NSArray *)[medicationDictionary objectForKey:DRUG_SCHEDULES];
//        if ([scheduleArray count] > 0) {
//            NSDictionary *schedulesDictionary = [scheduleArray objectAtIndex:0];
//            NSMutableArray *administrationArray = [[NSMutableArray alloc] initWithArray:[schedulesDictionary objectForKey:DRUG_ADMINISTRATIONS]];
//            medicationScheduleDetails.administrationDetailsArray = [self getAdministrationDetailsForMedication:administrationArray];
//            NSMutableArray *slotsArray = [self getMedicationScheduleTimeArrayFromScheduleDictionary:schedulesDictionary
//                                                                                      withStartDate:self.startDate
//                                                                                         andEndDate:self.endDate
//                                                                                   withActiveStatus:self.isActive];
//            
//            
//            
//            self.timeChart = slotsArray;
//            if ([schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES]) {
//                self.scheduleTimesArray = [schedulesDictionary valueForKey:DRUG_SCHEDULE_TIMES];
//            }
//        }
//        
//        
//    }
//    
//    
//}

#pragma mark - Private methods

- (NSMutableArray *)getAdministrationDetailsForMedication:(NSArray *)administrationArray {
    
    NSMutableArray *administrationDetailsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *administrationDictionary in administrationArray) {
        DCMedicationAdministration *medicationAdministration = [[DCMedicationAdministration alloc] initWithAdministrationDetails:administrationDictionary];
        [administrationDetailsArray addObject:medicationAdministration];
    }
    return administrationDetailsArray;
}


- (NSDate *)getStartDateForMedicationStartdate:(NSDate *)medicationStartDate
                                                    medicationEndDate:(NSDate *)medicationEndDate
                                                        startWeekDate:(NSDate *)startWeekDate
                                                          endWeekDate:(NSDate *)endWeekDate {
    
    NSDate *calculatedStartDate = nil;
    if ([medicationEndDate compare:startWeekDate] == NSOrderedAscending) {
        // medication has ended before current week
        
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

- (NSDate *)getEndDateForMedicationStartdate:(NSDate *)medicationStartDate
                             medicationEndDate:(NSDate *)medicationEndDate
                                 startWeekDate:(NSDate *)startWeekDate
                                 endWeekDate:(NSDate *)endWeekDate {
    
    NSDate *calculatedEndDate = nil;
    if ([medicationEndDate compare:startWeekDate] == NSOrderedAscending) {
        // medication has ended before current week
        
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

- (NSMutableArray *)getMedicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
                                                           withStartWeekDate:(NSDate *)startWeekDate
                                                              andEndWeekDate:(NSDate *)endWeekDate
                                                        withActiveStatus:(BOOL)isActive {
    
    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:DRUG_SCHEDULE_TIMES];
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.startDate];
    NSDate *endDate;
    if (self.endDate == nil) {
        endDate = [[NSDate date] dateByAddingTimeInterval:21*24*60*60];
    }
    else {
        endDate = [DCDateUtility dateFromSourceString:self.endDate];
    }
    
    NSDate *calculatedStartDate = [self getStartDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *calculatedEndDate = [self getEndDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *nextDate;
    if (calculatedStartDate != nil && calculatedEndDate != nil) {
        for (nextDate = calculatedStartDate ; [nextDate compare:calculatedEndDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
            NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
            NSInteger timeSlotsCount = 0;
            while (timeSlotsCount < [timesArray count]) {
                NSCalendar *calendar = [NSCalendar currentCalendar];
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


//- (NSMutableArray *)getMedicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
//                                                           withStartDate:(NSString *)startDateString
//                                                              andEndDate:(NSString *)endDateString withAdministrationStartDate:(NSDate *)startAdminDate andAdministrationEndDate:(NSDate *)endAdminDate
//                                                        withActiveStatus:(BOOL)isActive {
//    
//    // check if the start date and endDate is less than the actualStartDate, do nothing.
//    // start date is less, but end date is greater make actualMedicationStartDate as startdate.
//    // if startdate and endDate are normal, then things are good. normal case.
//    
//    // if today has changed we need to reset the whole thing. not to be thought in here.
//    
//    
//    // if startDate and endDate greater than actualMedEndDate, no more action. its over.
//    //
//    
//    
//    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:DRUG_SCHEDULE_TIMES];
//    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
//    NSDate * startDate = [DCDateUtility dateFromSourceString:startDateString];
//    NSDate *endDate;
//    if (endDateString == nil) {
//        endDate = [[NSDate date] dateByAddingTimeInterval:21*24*60*60];
//    }
//    else {
//        endDate = [DCDateUtility dateFromSourceString:endDateString];
//    }
//    if ([startDate compare:startAdminDate] == NSOrderedDescending) {
//        NSLog(@"the start date is less than admin start date");
//    }
//    if ([endDate compare:endAdminDate] == NSOrderedAscending) {
//        NSLog(@"the end date is greater than admin end date");
//    }
//
//    
//    
//    if ([startAdminDate compare:startDate] == NSOrderedAscending ) {
//        if ([startAdminDate compare:endDate] == NSOrderedAscending) {
//            // start date and end date is greater than actual end date.  No medicatio slots.
//        }
//        else {
//            if ([endAdminDate compare:endDate] == NSOrderedDescending || NSOrderedSame) {
//                // administer start date and end date lies within the limit.
//                // i.e., within the actual start date and enddate.
//                startDate = startAdminDate;
//                endDate = endAdminDate;
//            }
//            else {
//                // administer date startDate is within the limit, but the end date is somewhere within the limit.
//                startDate = startAdminDate;
//                endDate = endDate;
//            }
//        }
//    }
//    else {
//        
//        if ([endAdminDate compare:startDate] == NSOrderedAscending || NSOrderedSame) {
//            
//            // administer start date is before actual start date, but end date lies within the limit.
//            startDate = startDate;
//            endDate = endAdminDate;
//        }
//        else {
//            // both the admin start date and date are before the medication start date. no slots here.
//        }
//    }
//
//    
//    
//    
//    
//    
//    NSDate *nextDate;
//    for ( nextDate = startDate ; [nextDate compare:endDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
//        
//        NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
//        NSInteger timeSlotsCount = 0;
//        while (timeSlotsCount < [timesArray count]) {
//            
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
//            NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:nextDate];
//            NSString *timeString = [timesArray objectAtIndex:timeSlotsCount];
//            NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
//            if ([timeComponents count] >= 3 ) {
//                [components setDay:components.day];
//                [components setHour:[[timeComponents objectAtIndex:0] integerValue]];
//                [components setMinute:[[timeComponents objectAtIndex:1] integerValue]];
//                [components setSecond:[[timeComponents objectAtIndex:2] integerValue]];
//            }
//            NSDate *medicationDateTime = [calendar dateFromComponents:components];
//            DCMedicationSlot *medicationSlot = [[DCMedicationSlot alloc] init];
//            medicationSlot.time = medicationDateTime;
//            //TODO:set for demo purpose since there is no value for medication slot status
//            medicationSlot.status = IS_GIVEN;
//            
//            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"scheduledDateTime == %@",medicationDateTime];
//            NSArray *resultsArray = [self.administrationDetailsArray filteredArrayUsingPredicate:datePredicate];
//            
//            //TODO: this is not actual medication status value
//            if ([resultsArray count] > 0) {
//                DCMedicationAdministration *medicationAdministration = (DCMedicationAdministration *)[resultsArray objectAtIndex:0];
//                medicationSlot.status = medicationAdministration.status;
//                medicationSlot.medicationAdministration = medicationAdministration;
//            }
//            
//            [medicationSlotsArray addObject:medicationSlot];
//            timeSlotsCount++;
//        }
//        NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
//        [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
//        [shortDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
//        NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
//        
//        // if the current timechart array has this date, dont add it. otherwise add it.
//        // so that check has to be made here.
//        
//        [timeSlotsArray addObject:@{MED_DATE:medicationDateString,MED_DETAILS:medicationSlotsArray}];
//    }
//    return timeSlotsArray;
//}




@end
