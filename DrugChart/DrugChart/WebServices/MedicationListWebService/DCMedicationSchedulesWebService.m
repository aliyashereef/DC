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
#define kWeeklyDrugScheduleURL @"patients/%@/drugschedules?administrationsstartdatetime=%@&administrationsEndDateTime=%@"

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

- (void)getMedicationSchedulesForPatientId:(NSString *)patientId
                             fromStartDate:(NSString *)startDate
                                 toEndDate:(NSString *)endDate
                       withCallBackHandler:(void (^)(NSArray *, NSError *))completionHandler {
    
    NSString *urlString = [NSString stringWithFormat:kWeeklyDrugScheduleURL, patientId, startDate, endDate];
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
