//
//  DCWardWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/04/15.
//
//

#import "DCWardWebService.h"

static NSString *const kWardURL = @"bedmanagement/wards";

@implementation DCWardWebService

- (void)getAllWardsForUser:(NSString *)user
               withCallBackHandler:(void (^)(id response, NSError *error))callBackHandler {
    
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:kWardURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callBackHandler (responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callBackHandler(nil, error);
    }];
}

@end
