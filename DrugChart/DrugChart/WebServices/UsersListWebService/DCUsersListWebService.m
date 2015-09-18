//
//  DCUsersListWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/7/15.
//
//

#import "DCUsersListWebService.h"
#import "DCHTTPRequestOperationManager.h"

static NSString *const kUsersURL = @"users";

@implementation DCUsersListWebService



- (void)getUsersListWithCallback:(void (^)(NSArray *usersList, NSError *error))callBackHandler {
    
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:kUsersURL
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callBackHandler (responseObject, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        callBackHandler(nil, error);
    }];
}

@end
