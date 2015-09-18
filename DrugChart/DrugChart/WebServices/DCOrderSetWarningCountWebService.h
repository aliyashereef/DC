//
//  DCOrderSetWarningCountWebService.h
//  DrugChart
//
//  Created by aliya on 11/08/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCOrderSetWarningCountWebService : NSObject

- (void)getOrderSetWarningCountForPatientWithId:(NSString *)patientId
                        forOrderSetWithId:(NSString *)orderSetId
                         withCallBackHandler:(void (^)(NSArray *warningsArray, NSError *error))callBackHandler;

@end
