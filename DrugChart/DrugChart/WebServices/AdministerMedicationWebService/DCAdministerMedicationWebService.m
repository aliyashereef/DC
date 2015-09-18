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
    
    //NSLog(@"administerDictionary : %@", administerDictionary);
    
    NSString *requestUrl = [NSString stringWithFormat:@"patients/%@/drugschedules/%@/administrations", patientId, scheduleId];
    [[DCHTTPRequestOperationManager sharedAdministerMedicationManager] POST:requestUrl
                                                      parameters:administerDictionary
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             
                                                             callBackHandler(responseObject,nil);
                                                         }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             //NSLog(@"operation response string is %@", operation.responseString);
                                                             callBackHandler(nil, error);
                                                         }
     ];
}

- (void)initWithBaseURLForAdministerMedication {
    

}

@end
