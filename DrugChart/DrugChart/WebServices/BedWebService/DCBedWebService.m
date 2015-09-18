//
//  DCBedWebService.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 24/04/15.
//
//

#import "DCBedWebService.h"

@implementation DCBedWebService

static NSString *const kWardURL = @"bedmanagement/wards/%@/beds";

- (void)getBedDetailsInWard:(NSString *)wardId
        withCallBackHandler:(void (^)(NSArray *bedArray, NSError *error))callBackHandler {
    
    NSString *bedsUrl = [NSString stringWithFormat:kWardURL, wardId];
    DCDebugLog(@"The bed url is: %@", bedsUrl);
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:bedsUrl
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            callBackHandler (responseObject, nil);
                                                            
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            callBackHandler (nil, error);
                                                        }];
}

@end
