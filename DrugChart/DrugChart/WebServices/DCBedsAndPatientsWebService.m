//
//  DCBedsAndPatientsWebService.m
//  DrugChart
//
//  Created by aliya on 11/09/15.
//
//

#import "DCBedsAndPatientsWebService.h"

@implementation DCBedsAndPatientsWebService

- (void)getBedsPatientsDetailsFromUrl:(NSString *)requestUrl
        withCallBackHandler:(void (^)(NSArray *responseObject, NSError *error))callBackHandler {
    
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:requestUrl
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            callBackHandler (responseObject, nil);
                                                            
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            callBackHandler (nil, error);
                                                        }];
}
@end
