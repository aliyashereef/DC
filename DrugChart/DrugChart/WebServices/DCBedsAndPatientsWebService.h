//
//  DCBedsAndPatientsWebService.h
//  DrugChart
//
//  Created by aliya on 11/09/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCBedsAndPatientsWebService : NSObject

- (void)getBedsPatientsDetailsFromUrl:(NSString *)requestUrl
                 withCallBackHandler:(void (^)(NSArray *responseObject, NSError *error))callBackHandler;


@end
