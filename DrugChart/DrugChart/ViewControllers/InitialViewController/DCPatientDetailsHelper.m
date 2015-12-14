
//
//  DCPatientDetailsHelper.m
//  DrugChart
//
//  Created by aliya on 08/10/15.
//
//

#import "DCPatientDetailsHelper.h"
#import "DCWard.h"
#import "DCPatient.h"
#import "DCBedsAndPatientsWebService.h"
#import "DCBed.h"

@implementation DCPatientDetailsHelper


- (void)fetchPatientsInWard:(DCWard *)ward ToGetPatientListwithCallBackHandler:(void (^)(NSError *error, NSMutableArray *patientsArray))callBackHandler  {
    
    _patientsListArray = [[NSMutableArray alloc] init];
    DCBedsAndPatientsWebService *bedWebService = [[DCBedsAndPatientsWebService alloc] init];
    [bedWebService getBedsPatientsDetailsFromUrl:ward.patientsUrl
                             withCallBackHandler:^(NSArray *responseObject, NSError *error) {
                                 
                                 if (!error) {
                                     [_patientsListArray removeAllObjects];
                                     for (NSDictionary *patientDictionary in responseObject) {
                                         DCPatient *patient = [[DCPatient alloc] initWithPatientDictionary:patientDictionary];
                                         [patient getAdditionalInformationAboutPatientFromUrlwithCallBackHandler:^(NSError *error) {
                                             if (!error) {
                                                 
                                             }
                                         }];
                                         [_patientsListArray addObject:patient];
                                     }
                                     if ([_patientsListArray count] > 0) {
                                         // we need not have to fetch the medication list here, instead we
                                         // now call it on selecting a particular patient.
                                         //[self sortPatientListArrayWithNextMedicationDate];
                                         callBackHandler(nil,_patientsListArray);
                                     } else {
                                         NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                         [details setValue:@"patientlist empty" forKey:NSLocalizedDescriptionKey];
                                         error = [NSError errorWithDomain:@"error" code:100 userInfo:details];
                                         callBackHandler(error,nil);
                                     }
                                 } else {
                                     [self handleErrorResponseForPatientList:error];
                                     callBackHandler(error,nil);
                                 }
                             }];
}

- (NSMutableArray *)categorizePatientListBasedOnEmergency:(NSMutableArray *)contentArray {
    
    //categorize patient list
    NSMutableArray *overDueArray = [[NSMutableArray alloc] init];
    NSMutableArray *immediateArray = [[NSMutableArray alloc] init];
    NSMutableArray *nonImmediateArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    NSArray *nextMedicationSortedArray = [DCUtility sortArray:contentArray
                                                   basedOnKey:NEXT_MEDICATION_DATE_KEY
                                                    ascending:YES];
    for (DCPatient *patient in nextMedicationSortedArray) {
        //split sorted array in to specific categories
        if (patient.emergencyStatus == kMedicationDue) {
            [overDueArray addObject:patient];
        } else if (patient.emergencyStatus == kMedicationInHalfHour || patient.emergencyStatus == kMedicationInOneHour) {
            [immediateArray addObject:patient];
        } else {
            [nonImmediateArray addObject:patient];
        }
    }
    [sortedArray addObject:@{OVERDUE_KEY : overDueArray}];
    [sortedArray addObject:@{IMMEDIATE_KEY : immediateArray}];
    [sortedArray addObject:@{NOT_IMMEDIATE_KEY : nonImmediateArray}];
    return sortedArray;
}

- (void)handleErrorResponseForPatientList:(NSError *)error {
    
    if (error.code == NETWORK_NOT_REACHABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
    } else if (error.code == WEBSERVICE_UNAVAILABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
    } 
}

- (void)setBedsArrayToWard:(DCWard *)ward GraphicalViewControllerwithCallBackHandler:(void (^)(NSError *error, NSMutableArray *array, NSMutableArray *bedsArray))callBackHandler  {
    bedsArray = [[NSMutableArray alloc] init];
    DCBedsAndPatientsWebService *bedWebService = [[DCBedsAndPatientsWebService alloc] init];
    [bedWebService getBedsPatientsDetailsFromUrl:ward.bedsUrl withCallBackHandler:^(NSArray *responseObject, NSError *error) {
        if (!error) {
            for (NSDictionary *bedDetailDictionary in responseObject) {
                DCBed *bed = [[DCBed alloc] initWithDictionary:bedDetailDictionary];
                DCPatient *patient = bed.patient;
                if (patient) {
                    for (DCPatient *occupyingPatient in _patientsListArray) {
                        if ([occupyingPatient.patientId isEqualToString:patient.patientId]) {
                            occupyingPatient.bedId = patient.bedId;
                            occupyingPatient.bedNumber = patient.bedNumber;
                            occupyingPatient.bedType = patient.bedType;
                            bed.patient = occupyingPatient;
                        }
                    }
                }
                [bedsArray addObject:bed];
            }
            callBackHandler(nil,_patientsListArray, bedsArray);
        } else {
            callBackHandler(error, nil, nil);
        }
    }];
}

-(void)displayAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:OK_BUTTON_TITLE otherButtonTitles: nil];
    [alertView show];
}

@end
