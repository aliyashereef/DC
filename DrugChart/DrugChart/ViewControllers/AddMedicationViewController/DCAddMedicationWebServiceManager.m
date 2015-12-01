//
//  DCAddMedicationWebServiceManager.m
//  DrugChart
//
//  Created by aliya on 10/09/15.
//
//

#import "DCAddMedicationWebServiceManager.h"

// constants
#define SELECTED_ADMINISTRATING_TIME @"selected"
#define TIME @"time"

@implementation DCAddMedicationWebServiceManager

- (void)addMedicationServiceCallWithParameters:(NSDictionary *)medicationDictionary
                             ForMedicationType:(NSString *)medicationType
                                 WithPatientId:(NSString *)patientId
                           withCallbackHandler:(void (^)(NSError *))callBackHandler {
    
    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [webService  addMedicationForMedicationType:medicationType
                                   forPatientId:patientId
                                 withParameters:medicationDictionary
                            withCallbackHandler:^(id response, NSError *error) {
                                
                                if (!error) {
                                    callBackHandler(nil);
                                } else {
                                    callBackHandler(error);
                                    if (error.code == NETWORK_NOT_REACHABLE) {
                                        [DCUtility displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                                                 message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
                                    } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                                        
                                        [DCUtility displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                                                 message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
                                    }
                                    else {
                                        [DCUtility displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                                                 message:NSLocalizedString(@"ADD_MEDICATION_FAILED", @"")];
                                    }
                                }
                            }];
}

- (NSDictionary *)medicationDetailsDictionaryForMedicationDetail:(DCMedicationScheduleDetails *)medication {
    
    NSString *startDateString = [DCDateUtility dateStringFromDate:[DCDateUtility dateFromSourceString:medication.startDate] inFormat:EMIS_DATE_FORMAT];
    NSString *endDateString = [DCDateUtility dateStringFromDate:[DCDateUtility dateFromSourceString:medication.endDate] inFormat:EMIS_DATE_FORMAT];
    NSMutableDictionary *medicationDictionary = [[NSMutableDictionary alloc] init];
    
    [medicationDictionary setValue:medication.medicationId forKey:PREPARATION_ID];
    [medicationDictionary setValue:medication.dosage forKey:DOSAGE_VALUE];
    [medicationDictionary setValue:medication.instruction forKey:INSTRUCTIONS];
    //TO DO : Currently hard cording the value for route code id, have to change it according to the route user chooses.
    NSString *routeCodeId = [self routeCodeIdForRoute:medication.route];
    [medicationDictionary setValue:routeCodeId forKey:ROUTE_CODE_ID];
    NSMutableArray *scheduleArray = [[NSMutableArray alloc] init];
    for (NSDictionary *timeSchedule in medication.timeArray) {
        if ([[timeSchedule valueForKey:SELECTED_ADMINISTRATING_TIME]  isEqual: @1]) {
            [scheduleArray addObject:[NSString stringWithFormat:@"%@:00.000",[timeSchedule valueForKey:TIME]]];
        }
    }
    if ([medication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        
        [medicationDictionary setValue:startDateString forKey:START_DATE_TIME];
        [medicationDictionary setValue:scheduleArray forKey:SCHEDULE_TIMES];
        if (medication.hasEndDate) {
            [medicationDictionary setValue:endDateString forKey:END_DATE_TIME];
        }
    } else if ([medication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        [medicationDictionary setValue:startDateString forKey:SCHEDULED_DATE_TIME];
    } else {
        [medicationDictionary setValue:startDateString forKey:START_DATE_TIME];
        if (medication.hasEndDate) {
            [medicationDictionary setValue:endDateString forKey:END_DATE_TIME];
        }
    }
    return medicationDictionary;
}

- (NSString *)routeCodeIdForRoute:(NSString *)routeString {
    
    if ([routeString isEqualToString:ORAL] || [routeString isEqualToString:@"Oral"]) {
        return ORAL_ID;
    } else if ([routeString isEqualToString:RECTAL] || [routeString isEqualToString:@"Rectal"]) {
        return RECTAL_ID;
    } else if ([routeString isEqualToString:INTRAMASCULAR] || [routeString isEqualToString:@"Intramuscular"]) {
        return INTRAMASCULAR_ID;
    } else if ([routeString isEqualToString:INTRATHECAL] || [routeString isEqualToString:@"Intrathecal"]) {
        return INTRATHECAL_ID;
    } else if ([routeString isEqualToString:INTRAVENOUS] || [routeString isEqualToString:@"Intravenous"]) {
        return INTRAVENOUS_ID;
    } else {
        return EMPTY_STRING;
    }
}

@end
