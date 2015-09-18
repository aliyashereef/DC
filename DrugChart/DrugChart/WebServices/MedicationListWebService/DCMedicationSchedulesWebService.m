//
//  DCMedicationSchedulesWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 07/07/15.
//
//

#import "DCMedicationSchedulesWebService.h"
#import "DCHTTPRequestOperationManager.h"

#define kDrugScheduleURL @"patients/%@/drugschedules/"

@implementation DCMedicationSchedulesWebService


- (void)getMedicationSchedulesForPatientId:(NSString *)patientId
                       withCallBackHandler:(void(^)(NSArray *medicationListArray, NSError *error))completionHandler {
    
    NSString *urlString = [NSString stringWithFormat:kDrugScheduleURL,patientId];
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:urlString
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            completionHandler (responseObject, nil);
                                                            
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            completionHandler (nil, error);
                                                        }];
}

- (void)cancelPreviousRequest {
    
    //cancel web request
    [[DCHTTPRequestOperationManager sharedOperationManager] cancelAllWebRequests];
}

@end
