//
//  DCAlertsWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/06/15.
//
//

#import "DCAlertsWebService.h"

@implementation DCAlertsWebService

static NSString *const kAlertsUrl = @"patients/%@/warnings";


- (void)patientAlertsForId:(NSString *)patientId
          withCallBackHandler:(void (^)(NSArray *alertsArray, NSError *error))callBackHandler {
    
    NSString *alertsUrl = [NSString stringWithFormat:kAlertsUrl, patientId];
    DDLogInfo(@"The alerts url is: %@", alertsUrl);
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:alertsUrl
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            callBackHandler (responseObject, nil);
                                                            
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            callBackHandler (nil, error);
                                                        }
     ];
}

@end
