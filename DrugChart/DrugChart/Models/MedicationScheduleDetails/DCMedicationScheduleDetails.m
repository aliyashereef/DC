//
//  DCMedicationScheduleDetails.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import "DCMedicationScheduleDetails.h"
#import "DCMedicationSlot.h"
#import "DCMedicationStoppage.h"

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
#define STOPPAGE @"stoppage"
#define USER @"user"


@implementation DCMedicationScheduleDetails

- (DCMedicationScheduleDetails *)initWithMedicationScheduleDictionary:(NSDictionary *)medicationDictionary forWeekStartDate:(NSDate *)weekStartDate weekEndDate:(NSDate *)weekEndDate {
    
    self = [[DCMedicationScheduleDetails alloc] init];
    self.name = [medicationDictionary valueForKey:DRUG_NAME];
    NSLog(@"****** Medicine is %@ *******", self.name);
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
    if ([medicationDictionary valueForKey:STOPPAGE]) {
        NSDictionary *stoppageDictionary = [medicationDictionary valueForKey:STOPPAGE];
        self.stoppage = [[DCMedicationStoppage alloc] init];
        self.stoppage.time = [stoppageDictionary valueForKey:TIME_KEY];
        if ([stoppageDictionary valueForKey:USER]) {
            NSDictionary *userDictionary = [stoppageDictionary valueForKey:USER];
            self.stoppage.stoppedBy = [[DCUser alloc] initWithUserDetails:userDictionary];
        }
    }
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
            NSMutableArray *slotsArray = [self medicationScheduleTimeArrayForWhenRequiredMedicationsForStartWeekDate:weekStartDate endWeekDate:weekEndDate];
            self.timeChart = slotsArray;
        } else {
            administrationArray = [[NSMutableArray alloc] initWithArray:[schedulesDictionary objectForKey:DRUG_ADMINISTRATIONS]];
            self.administrationDetailsArray = [self administrationDetailsForMedication:administrationArray];
            NSMutableArray *slotsArray = [self medicationScheduleTimeArrayFromScheduleDictionary:schedulesDictionary
                                                                                  withStartWeekDate:weekStartDate endWeekDate:weekEndDate];
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
            //start date set here as the midnight date since the slot creation logic adds one day to the previous date. If start date slot time is some time towards end of day, last day of the third week will be skipped 
            calculatedStartDate = [DCDateUtility midNightTimeForDate:medicationStartDate];
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
                                                          endWeekDate:(NSDate *)endWeekDate {
    
    
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.startDate];
    NSDate *endDate;
    if (self.isActive == false) {
        //discontinued medication
        if (self.stoppage) {
            endDate = [DCDateUtility dateFromSourceString:self.stoppage.time];
            NSLog(@"***** Stoppage time is %@", self.stoppage.time);
        }
    } else {
        //max limit to be displayed is end week date
        endDate = (self.endDate == nil) ? endWeekDate : [DCDateUtility dateFromSourceString:self.endDate];
    }
    NSDate *calculatedStartDate = [self startDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *calculatedEndDate = (self.stoppage) ? endDate :
                                [self endDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSLog(@"***** calculatedStartDate is %@", calculatedStartDate);
    NSLog(@"***** calculatedEndDate is %@", calculatedEndDate);
    NSDate *nextDate;
    if (calculatedStartDate != nil && calculatedEndDate != nil) {
        for (nextDate = calculatedStartDate ; [nextDate compare:calculatedEndDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
            NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
            NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
            [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
            //[shortDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:GMT]];
            NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
          //  NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"scheduledDateTime.description contains[cd] %@", medicationDateString];
            //TODO: Create a predicate to filter the array.
//            NSArray *resultsArray = [self.administrationDetailsArray filteredArrayUsingPredicate:datePredicate];
            NSArray *resultsArray = [self findDatesOfWhenRequiredAdministration:medicationDateString];
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

- (NSMutableArray *)findDatesOfWhenRequiredAdministration:(NSString *)nextDate {
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
    [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
    for (int i = 0 ; i<self.administrationDetailsArray.count; i++) {
        NSString *medicationDateString = [shortDateFormatter stringFromDate:[[self.administrationDetailsArray objectAtIndex:i] valueForKey:@"scheduledDateTime"]];
        if ([medicationDateString isEqualToString:nextDate]) {
            [timeArray addObject:[self.administrationDetailsArray objectAtIndex:i]];
        }
    }
    return timeArray;
}

- (NSMutableArray *)medicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
                                                           withStartWeekDate:(NSDate *)startWeekDate
                                                              endWeekDate:(NSDate *)endWeekDate {
    
    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:DRUG_SCHEDULE_TIMES];
    NSMutableArray *timeSlotsArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.startDate];
    NSDate *endDate;
    if (self.isActive == false) {
        //discontinued medication
        if (self.stoppage) {
            endDate = [DCDateUtility dateFromSourceString:self.stoppage.time];
            NSLog(@"***** stoppage time is %@", self.stoppage.time);
        }
    } else {
        endDate = (self.endDate == nil) ? [self dayEndTimeForDate:endWeekDate] : [DCDateUtility dateFromSourceString:self.endDate];
    }
    NSDate *calculatedStartDate = [self startDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSDate *calculatedEndDate = (self.stoppage) ? endDate :
                                [self endDateForMedicationStartdate:startDate medicationEndDate:endDate startWeekDate:startWeekDate endWeekDate:endWeekDate];
    NSLog(@"***** calculatedStartDate is %@ *******", calculatedStartDate);
    NSLog(@"****** calculatedEndDate is %@ ****", calculatedEndDate);
     NSLog(@"Timea rray is %@", timesArray);
    NSDate *nextDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (calculatedStartDate != nil && calculatedEndDate != nil) {
        for (nextDate = calculatedStartDate ; [nextDate compare:calculatedEndDate] <= 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
            NSMutableArray *medicationSlotsArray = [[NSMutableArray alloc] init];
            NSInteger timeSlotsCount = 0;
            NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:nextDate];
            NSString *currentDateString = [DCDateUtility dateStringFromDate:[NSDate date] inFormat:SHORT_DATE_FORMAT];
            NSString *startDateString = [DCDateUtility dateStringFromDate:calculatedStartDate inFormat:SHORT_DATE_FORMAT];
            BOOL medicationStartsToday = NO;
            if ([currentDateString isEqualToString:startDateString]) {
                // both falls on the same day
                medicationStartsToday = YES;
            }
            while (timeSlotsCount < [timesArray count]) {
                BOOL addTimeSlot = YES;
                NSString *timeString = [timesArray objectAtIndex:timeSlotsCount];
                NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
                NSDate *medicationDateTime = nil;
                if ([timeComponents count] >= 3 ) {
                    [components setDay:components.day];
                    [components setHour:[[timeComponents objectAtIndex:0] integerValue]];
                    [components setMinute:[[timeComponents objectAtIndex:1] integerValue]];
                    [components setSecond:[[timeComponents objectAtIndex:2] integerValue]];
                    medicationDateTime = [calendar dateFromComponents:components];
                    if (medicationStartsToday) {
                        if ([startDate compare:medicationDateTime] == NSOrderedDescending) {
                            // If medication starts today, create medication slots having medication time after the start date
                            addTimeSlot = NO;
                        }
                    }
                    if (self.stoppage.time) {
                        if ([medicationDateTime compare:endDate] == NSOrderedDescending) {
                            // medication slots after stoppage time shouldn't be created
                            addTimeSlot = NO;
                        }
                    }
                }
                
                if (addTimeSlot == YES) {
                    DCMedicationSlot *medicationSlot = [[DCMedicationSlot alloc] init];
                    medicationSlot.time = medicationDateTime;
                    medicationSlot.status = IS_GIVEN;
                    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"scheduledDateTime == %@",medicationDateTime];
                    NSArray *resultsArray = [self.administrationDetailsArray filteredArrayUsingPredicate:datePredicate];
                    if ([resultsArray count] > 0) {
                        DCMedicationAdministration *medicationAdministration = (DCMedicationAdministration *)[resultsArray objectAtIndex:0];
                        medicationSlot.status = medicationAdministration.status;
                        medicationSlot.medicationAdministration = medicationAdministration;
                    }
                    [medicationSlotsArray addObject:medicationSlot];
                }
                timeSlotsCount++;
            }
            NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
            [shortDateFormatter setDateFormat:SHORT_DATE_FORMAT];
            NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
            [timeSlotsArray addObject:@{MED_DATE:medicationDateString,MED_DETAILS:medicationSlotsArray}];
        }
    }
    return timeSlotsArray;
}

- (NSDate *)dayEndTimeForDate:(NSDate *) date {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:23];
    [components setMinute:59];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [currentCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:UTC]];
    NSDate *endDate = [currentCalendar dateByAddingComponents:components toDate:date options:0];
    return endDate;
}

@end
