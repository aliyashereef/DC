//
//  DCOrderSetWebService.m
//  DrugChart
//
//  Created by aliya on 28/07/15.
//
//

#import "DCOrderSetWebService.h"
#import "DCOrderSet.h"

#define kOrderSetURL @"drugscheduling/ordersets"

@implementation DCOrderSetWebService


- (void)getAllOrderSetsWithCallBackHandler:(void (^)(NSArray *orderSetsArray, NSError *error))callBackHandler {
    NSString *urlString = [NSString stringWithFormat:kOrderSetURL];
    [[DCHTTPRequestOperationManager sharedOperationManager] GET:urlString
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            @try {
                                                    
                                                                NSMutableArray *searchListArray = [[NSMutableArray alloc] init];
                                                                NSArray *orderSetsArray = [[NSArray alloc] initWithArray:responseObject];
                                                                for (NSDictionary *dict in orderSetsArray) {
                                                                    
                                                                    DCOrderSet *orderSet = [[DCOrderSet alloc] initWithOrderSetDictionary:dict];
                                                                    [searchListArray addObject:orderSet];
                                                                }
                                                                callBackHandler (searchListArray, nil);
                                                            }
                                                            @catch (NSException *exception) {
                                                                
                                                                DDLogError(@"exception raised is %@", exception.description);
                                                            }
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            callBackHandler (nil, error);
                                                        }];

    
}
@end
