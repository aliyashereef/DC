//
//  DCMedicationList.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/03/15.
//
//

#import "DCMedicationList.h"
#import "DCMedicationSlot.h"
#import "DCMedicationAdministration.h"

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
#define RESOURCE_KEY @"resource"
//#define RESOURCE_TYPE_KEY @"resourceType"
#define RESOURCE_NAME_KEY @"name"
#define PRODUCT_KEY @"product"
#define FORM_KEY @"form"
#define TEXT_KEY @"text"
#define ID_KEY @"id"
#define EXTENSION_KEY @"extension"
#define VALUE_STRENGTH_KEY @"valueString"
#define MEDICINE_NAME @"medicineName"
#define MEDICINE_CATEGORY @"medicineCategory"
#define DOSAGE @"dosage"
#define PRESCRIBED_BY @"prescribedBy"
#define TIME_CHART @"timeChart"
#define START_DATE @"startDate"
#define END_DATE @"endDate"
#define ROUTE @"route"
#define INSTRUCTION @"instruction"
#define SCHEDULE_ID @"identifier"
#define PREPARATION_CODE_ID @"preparationCodeId"
#define NEXT_DRUG_TIME @"nextDrugDateTime"

// order set medication keys
#define DAYOFFSET_FROM_START @"dayOffsetFromStartOfCourse"
#define LENGTH_IN_DAYS @"lengthInDays"
#define PREPARATION_CODE_ID @"preparationCodeId"
#define PREPARATION_TERM @"preparationTerm"
#define DOSAGE_INSTRUCTIONS @"instructions"
#define ROUTE_CODE_TERM @"routeCodeTerm"
#define TIMES        @"times"

@implementation DCMedicationList

- (DCMedicationList *)initWithSearchMedicationDictionary :(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        
        NSDictionary *resourceDictionary = [medicationDictionary valueForKey:RESOURCE_KEY];
        if (resourceDictionary) {
            
            //self.resourceType = [resourceDictionary valueForKey:RESOURCE_TYPE_KEY];
            self.name = [resourceDictionary valueForKey:RESOURCE_NAME_KEY];
            self.medicationId = [resourceDictionary valueForKey:ID_KEY];
            NSArray *extensionArray = [resourceDictionary valueForKey:EXTENSION_KEY];
            @try {
                for (NSDictionary *dict in extensionArray) {
                    NSString *valueStrength = [dict valueForKey:VALUE_STRENGTH_KEY];
                    if (![valueStrength isEqualToString:EMPTY_STRING]) {
                        self.dosage = valueStrength;
                        break;
                    }
                }
            }
            @catch (NSException *exception) {
                DCDebugLog(@"exception : %@", exception.description);
            }
        }
//        NSDictionary *productDictionary = [resourceDictionary valueForKey:PRODUCT_KEY];
//        if (productDictionary) {
//            NSDictionary *formDictionary = [productDictionary valueForKey:FORM_KEY];
//            if (formDictionary) {
//                self.productText = [formDictionary valueForKey:TEXT_KEY];
//            }
//        }
    }
    return self;
}

- (DCMedicationList *)initWithOrderSetMedicationDictionary :(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        self.name = [medicationDictionary valueForKey:PREPARATION_TERM];
        self.medicationId = [medicationDictionary valueForKey:PREPARATION_CODE_ID];
        self.instruction = [medicationDictionary valueForKey:DOSAGE_INSTRUCTIONS];
        self.dosage = [medicationDictionary valueForKey:DRUG_DOSAGE];
        self.medicineCategory = [medicationDictionary valueForKey:DRUG_CATEGORY];
        self.route = [NSString stringWithFormat:@"%@ (PO)",[medicationDictionary valueForKey:ROUTE_CODE_TERM]];
        if ([self.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
            
            NSDictionary *scheduleDictionary = [[NSDictionary alloc] initWithDictionary:[medicationDictionary valueForKey:@"schedule"]];            
            self.scheduleTimesArray = [scheduleDictionary valueForKey:TIMES];
        }
    }
    return self;
}

- (DCMedicationList *)initWithMedicationScheduleDictionaryForAPI:(NSDictionary *)medicationDictionary {
    
    self = [[DCMedicationList alloc] init];
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
    return administrationDetailsArray;
}

- (NSMutableArray *)getMedicationScheduleTimeArrayFromScheduleDictionary:(NSDictionary *)scheduleDictionary
                                                           withStartDate:(NSString *)startDateString
                                                              andEndDate:(NSString *)endDateString
                                                        withActiveStatus:(BOOL)isActive {
    
    NSArray *timesArray = (NSArray *)[scheduleDictionary objectForKey:@"times"];
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
        NSString *medicationDateString = [shortDateFormatter stringFromDate:nextDate];
        
        [timeSlotsArray addObject:@{MED_DATE:medicationDateString,MED_DETAILS:medicationSlotsArray}];
    }
    return timeSlotsArray;
}

@end