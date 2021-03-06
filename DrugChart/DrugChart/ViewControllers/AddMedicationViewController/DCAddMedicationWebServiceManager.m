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
    NSString *routeCodeId = [self routeCodeIdForRoute:medication];
    [medicationDictionary setValue:routeCodeId forKey:ROUTE_CODE_ID];
    NSMutableArray *scheduleArray = [[NSMutableArray alloc] init];
    for (id content in medication.timeArray) {
        if ([content isKindOfClass:[NSDictionary class]]) {
            if ([[content valueForKey:SELECTED_ADMINISTRATING_TIME]  isEqual: @1]) {
                [scheduleArray addObject:[NSString stringWithFormat:@"%@:00.000",[content valueForKey:TIME]]];
            }
        } else {
            [scheduleArray addObject:content];
        }
    } 
    if ([medication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        
        [medicationDictionary setValue:startDateString forKey:START_DATE_TIME];
       // if (scheduleArray.count > 0) {
            [medicationDictionary setValue:scheduleArray forKey:SCHEDULE_TIMES];
      //  }
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

- (NSString *)routeCodeIdForRoute:(DCMedicationScheduleDetails *)medication {
    
    for (NSDictionary *routeDictionary in medication.routeArray) {
        for (NSString *key in routeDictionary.allKeys){
            NSString *route = routeDictionary[key];
            if ([route isEqualToString:medication.route]) {
                NSString *keyString = [[key componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                return keyString;
            }
        }
    }
    return nil;
}

@end
