//
//  DCPatient.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/03/15.
//
//

#import "DCPatient.h"
#import "DCPatientAlert.h"
#import "DCPatientAllergy.h"

#import "DCAlertsWebService.h"
#import "DCPatientAllergyWebService.h"
#import "DCBedsAndPatientsWebService.h"

#define MEDICATION_DUE 0
#define MEDICATION_IN_HALF_HOUR 1800
#define MEDICATION_IN_ONE_HOUR 3600
#define MEDICATION_IN_ONE_AND_HALF_HOUR 5400
#define MEDICATION_IN_TWO_HOURS 7200


#define MEDICATION_DUE_COLOR @"#ff2c2c"
#define MEDICATION_HALF_HOUR_COLOR @"#ff5e2c"
#define MEDICATION_ONE_HOUR_COLOR @"#ff762c"
#define MEDICATION_ONE_AND_HALF_HOUR_COLOR @"#ff9e2c"
#define MEDICATION_TWO_HOUR_COLOR @"#ffbc2c"
#define MEDICATION_DEFAULT_COLOR @"#f3c217"
#define NO_MEDICATION_COLOR @"#8d8d8d"

#define AGE @"ageDescription"
#define IDENTIFIER @"identifier"
#define DOB @"dateOfBirth"
#define DESCRIPTION @"description"
#define VALUE @"value"

//constants
#define URL_HEADER_PATH @"http://localhost:8080/api/patients/"
#define YEARS @"y"
#define TIME_DOB @"T00:00:00"

@implementation DCPatient

- (DCPatient *)initWithPatientDictionary:(NSDictionary *)patientDictionary {
    
    self = [super init];
    if (self) {
        @try {
            self.patientId = [NSString stringWithFormat:@"%@",[patientDictionary valueForKey:PATIENT_ID]];
            self.patientName = [[patientDictionary objectForKey:PATIENT]valueForKey:DISPLAY_NAME];
            self.consultant = [[patientDictionary objectForKey:CONSULTANT] valueForKey:DISPLAY_NAME];
            self.sex = [patientDictionary valueForKey:PATIENT_SEX_KEY];
           
            self.patientNumber = [NSString stringWithFormat:@"%@",[patientDictionary valueForKey:PATIENT_NUMBER]];
            if ([patientDictionary valueForKey:NEXT_DUE_MEDICATION] &&
                ![[patientDictionary valueForKey:NEXT_DUE_MEDICATION] isEqual:[NSNull null]]) {
                self.nextMedicationDate = [self nextMedicationDateFromDateString:
                                           [[patientDictionary objectForKey:NEXT_DUE_MEDICATION]valueForKey:NEXT_DUE_ADMINISTRATION_DATE_TIME]];
            }
        
            NSString *requestUrl = [[patientDictionary objectForKey:PATIENT]valueForKey:PATIENT_URL];
            self.patientId = [requestUrl stringByReplacingOccurrencesOfString:URL_HEADER_PATH withString:EMPTY_STRING];
            DCAppDelegate *appDelegate = DCAPPDELEGATE;
            requestUrl = [requestUrl stringByReplacingOccurrencesOfString:LOCALHOST_PATH withString:appDelegate.baseURL];
            self.url  = requestUrl;
            [self setPatientsAlerts];
            [self setPatientsAllergies];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"Exception in patient model class: %@", exception.description);
        }
    }
    return self;
}

- (void)setPatientBedIdFromBedNumber:(NSNumber *)bedNumber {
    
    self.bedId = [NSString stringWithFormat:@"%@",bedNumber];
}

- (void)setPatientBedType:(NSString *)bedType {
    
    self.bedType = bedType;
}

- (NSDate *)nextMedicationDateFromDateString:(NSString *)dateString {
    
    NSString *formatterString = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDate *nextMedicationDate = [DCDateUtility dateForDateString:dateString
                                                    withDateFormat:formatterString];
    return nextMedicationDate;
}


//TODO: this function contains the logic to calculate the medication status.
- (MedicationStatus)getMedicationStatus {
    
    if (self.nextMedicationDate == nil) {
        return kMedicationDue;
    } else {
        
        NSTimeInterval timeInterval = [self.nextMedicationDate timeIntervalSinceDate:[DCDateUtility dateInCurrentTimeZone:[NSDate date]]];
        if (timeInterval < MEDICATION_DUE) {
            return kMedicationDue;
        }
        else if (timeInterval < MEDICATION_IN_HALF_HOUR) {
            return kMedicationInHalfHour;
        }
        else if (timeInterval < MEDICATION_IN_ONE_HOUR) {
            return kMedicationInOneHour;
        }
        else if (timeInterval < MEDICATION_IN_ONE_AND_HALF_HOUR) {
            return kMedicationInOneAndHalfHour;
        }
        else if (timeInterval < MEDICATION_IN_TWO_HOURS) {
            return kMedicationInTwoHours;
        }
        else {
            return kMedicationInTwoHours;
        }
    }
 }

- (UIColor *)displayColorForMedicationStatus {
    
    MedicationStatus status = [self getMedicationStatus];
    self.emergencyStatus = status;
    UIColor *statusColor;
    if (!self.nextMedicationDate) {
        statusColor = [UIColor colorForHexString:NO_MEDICATION_COLOR];
    }
    else {
        switch (status) {
            case kMedicationDue:
                statusColor = [UIColor colorForHexString:MEDICATION_DUE_COLOR];
                break;
                
            case kMedicationInHalfHour:
                statusColor = [UIColor colorForHexString:MEDICATION_HALF_HOUR_COLOR];
                break;
                
            case kMedicationInOneHour:
                statusColor = [UIColor colorForHexString:MEDICATION_ONE_HOUR_COLOR];
                break;
                
            case kMedicationInOneAndHalfHour:
                statusColor = [UIColor colorForHexString:MEDICATION_ONE_AND_HALF_HOUR_COLOR];
                break;
                
            case kMedicationInTwoHours:
                statusColor = [UIColor colorForHexString:MEDICATION_TWO_HOUR_COLOR];
                break;
                
            default:
                statusColor = [UIColor colorForHexString:MEDICATION_DEFAULT_COLOR];
                break;
        }
    }
    return statusColor;
}

- (NSMutableAttributedString *)formattedDisplayMedicationDateForPatient {
    
    if (self.nextMedicationDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:DISPLAY_DATE_FORMAT];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:GMT]];
        NSString *displayDateString = [formatter stringFromDate:self.nextMedicationDate];
        if (![displayDateString isEqualToString:EMPTY_STRING]) {
            NSArray *splittedDateArray = [displayDateString componentsSeparatedByString:COMMA];
            if ([splittedDateArray count] > 0) {
                NSString *timeString = [splittedDateArray objectAtIndex:0];
                NSString *dateString = [splittedDateArray objectAtIndex:1];
                NSDictionary *timeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [DCFontUtility latoBoldFontWithSize:20.0f], NSFontAttributeName,
                                                nil];
                NSDictionary *dateAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [DCFontUtility latoRegularFontWithSize:15.0f], NSFontAttributeName, nil];
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:displayDateString];
                [attributedString setAttributes:timeAttributes range:NSMakeRange(0, timeString.length+1)];
                [attributedString setAttributes:dateAttributes range:NSMakeRange(timeString.length, dateString.length)];
                return attributedString;
            }
        }
    }
    return nil;
}


- (void)setPatientsAlerts {
    
    DCAlertsWebService *webService = [[DCAlertsWebService alloc] init];
    [webService patientAlertsForId:self.patientId withCallBackHandler:^(NSArray *alertsArray, NSError *error) {
        DCDebugLog(@"the patients alerts Array: %@", alertsArray);
        NSMutableArray *patientAlertsArray = [[NSMutableArray alloc] init];        
        if ([alertsArray count] > 0) {
            for (NSMutableDictionary *alertsDictionary in alertsArray) {
                DCPatientAlert *patientAlert =
                [[DCPatientAlert alloc] initWithAlertDictionary:alertsDictionary];
                [patientAlertsArray addObject:patientAlert];
            }
        }
        self.patientsAlertsArray = patientAlertsArray;
    }];
}

- (void)getPatientsAllergies {
    
    DCPatientAllergyWebService *webService = [[DCPatientAllergyWebService alloc] init];
    [webService getPatientAllergiesForId:self.patientId withCallBackHandler:^(NSArray *alergiesArray, NSError *error) {
        DCDebugLog(@"the patients alerts Array: %@", alergiesArray);
        NSMutableArray *patientAlergiesArray = [[NSMutableArray alloc] init];
        if ([alergiesArray count] > 0) {
            for (NSMutableDictionary *alertsDictionary in alergiesArray) {
                DCPatientAllergy *patientAlert =
                [[DCPatientAllergy alloc] initWithAllergyDictionary:alertsDictionary];
                [patientAlergiesArray addObject:patientAlert];
            }
        }
        self.patientsAlergiesArray = patientAlergiesArray;
    }];
}

- (void)getAdditionalInformationAboutPatientFromUrlwithCallBackHandler:(void (^)(NSError *error))callBackHandler {
    DCBedsAndPatientsWebService *bedWebService = [[DCBedsAndPatientsWebService alloc] init];
    [bedWebService getBedsPatientsDetailsFromUrl:self.url
                             withCallBackHandler:^(NSArray *responseObject, NSError *error) {
        if (!error) {
            NSDictionary *patientDetail = (NSDictionary *)responseObject;
            self.dob = [self patientDateOfBirth:[patientDetail valueForKey:DOB]];
            NSString *age = [patientDetail valueForKey:AGE];
            self.age = [age stringByReplacingOccurrencesOfString:YEARS withString:EMPTY_STRING];
            self.nhs = [[patientDetail objectForKey:IDENTIFIER] valueForKey:VALUE];
            // To Do : Hard coding a value, have to be changed when a API starts to return sex.
            self.sex = @"Male";
            callBackHandler(nil);
        } else {
            callBackHandler(error);
        }
    }];
}

#pragma mark - Private methods

// function converts date string to NSDate object.
- (NSDate *)patientDateOfBirth:(NSString *)dobString {
    dobString = [dobString stringByReplacingOccurrencesOfString:TIME_DOB withString:EMPTY_STRING];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DOB_DATE_FORMAT];
    NSDate *birthDate = [dateFormatter dateFromString:dobString];
    return birthDate;
}


@end
