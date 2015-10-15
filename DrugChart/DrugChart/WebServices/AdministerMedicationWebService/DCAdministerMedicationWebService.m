//
//  DCAdministerMedicationWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/5/15.
//
//

#import "DCAdministerMedicationWebService.h"

@implementation DCAdministerMedicationWebService

- (void)administerMedicationForScheduleId:(NSString *)scheduleId
                             forPatientId:(NSString *)patientId
                           withParameters:(NSDictionary *)administerDictionary
                      withCallbackHandler:(void (^)(id response, NSError *error))callBackHandler {
        
    NSString *requestUrl = [NSString stringWithFormat:@"patients/%@/drugschedules/%@/administrations", patientId, scheduleId];
    [[DCHTTPRequestOperationManager sharedAdministerMedicationManager] POST:requestUrl
                                                      parameters:administerDictionary
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             
                                                             callBackHandler(responseObject,nil);
                                                         }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             callBackHandler(nil, error);
                                                         }
     ];
}

@end
