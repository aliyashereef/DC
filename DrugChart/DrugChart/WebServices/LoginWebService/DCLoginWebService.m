//
//  DCLoginWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCLoginWebService.h"
#import "DCWardWebService.h"
#import "DCUser.h"

@implementation DCLoginWebService

- (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                  callback:(void (^)(id response, NSDictionary *error))callback {
    
    //replace this with actual values
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", @"", _urlString];
    [[DCHTTPRequestOperationManager sharedOperationManager] POST:requestUrl
                parameters:@{@"username":email, @"password":password}
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       callback(responseObject,nil);
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       DCAppDelegate *appDelegate = (DCAppDelegate *)[[UIApplication sharedApplication] delegate];
                       if ([email isEqualToString:ROLE_DOCTOR] && [password isEqualToString:ROLE_DOCTOR]) {
                           appDelegate.userRole = ROLE_DOCTOR;
                           NSDictionary *userDictionary = @{USER_KEY:ROLE_DOCTOR, STATUS_KEY:STATUS_OK};
                           callback(nil, userDictionary);
                       }
                       else if ([email isEqualToString:ROLE_NURSE] && [password isEqualToString:ROLE_NURSE]) {
                           appDelegate.userRole = ROLE_NURSE;
                           NSDictionary *userDictionary = @{USER_KEY:ROLE_NURSE, STATUS_KEY:STATUS_OK};
                           callback(nil, userDictionary);
                       }
                       else {
                           NSDictionary *userDictionary = @{USER_KEY:@"unknown", STATUS_KEY:STATUS_ERROR};
                           callback(nil, userDictionary);
                       }
                   }];
}

@end
