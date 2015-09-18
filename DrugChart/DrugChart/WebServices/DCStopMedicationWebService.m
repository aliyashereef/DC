//
//  DCStopMedicationWebService.m
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import "DCStopMedicationWebService.h"

@implementation DCStopMedicationWebService

static NSString *const kDCStopMedicationURL = @"patients/%@/drugschedules/%@/stop";

- (void)stopMedicationForPatientWithId:(NSString *)patientId drugWithScheduleId:(NSString *)scheduleId withCallBackHandler:(void (^)(id response, NSError *))callBackHandler {
    NSString *requestUrl = [NSString stringWithFormat:kDCStopMedicationURL, patientId ,scheduleId];
    
    [[DCHTTPRequestOperationManager sharedOperationManager] PUT:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        callBackHandler(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callBackHandler(nil,error);
    }];    
}

@end
