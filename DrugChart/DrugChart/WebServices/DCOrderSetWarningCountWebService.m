//
//  DCOrderSetWarningCountWebService.m
//  DrugChart
//
//  Created by aliya on 11/08/15.
//
//

#import "DCOrderSetWarningCountWebService.h"
#import "DCOrderSetWarningCount.h"

@implementation DCOrderSetWarningCountWebService
static NSString *const kDCWarningCountUrl = @"patients/%@/interactions/ordersetsummary/%@";

- (void)getOrderSetWarningCountForPatientWithId:(NSString *)patientId
                              forOrderSetWithId:(NSString *)orderSetId
                            withCallBackHandler:(void (^)(NSArray *warningsArray, NSError *error))callBackHandler {
    NSString *requestUrl = [NSString stringWithFormat:kDCWarningCountUrl, patientId, orderSetId];
    [[DCHTTPRequestOperationManager sharedMedicationOperationManager] GET:requestUrl
                                                               parameters:nil
                                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
                                                                      NSMutableArray *warningsArray = [[NSMutableArray alloc] init];
                                                                      NSArray *orderSetWarningArray = [[NSArray alloc] initWithArray:responseObject];
                                                                      for (NSDictionary *warningDictionary in orderSetWarningArray) {
                                                                          
                                                                          DCOrderSetWarningCount *warningCount = [[DCOrderSetWarningCount alloc] initWithDictionary:warningDictionary];
                                                                          [warningsArray addObject:warningCount];
                                                                      }
                                                                      callBackHandler (warningsArray, nil);
                                                                  }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 
                                                                      callBackHandler (nil, error);
                                                                  }
     ];
}

@end
