//
//  DCWardWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/04/15.
//
//

#import "DCHTTPRequestOperationManager.h"

@interface DCWardWebService : NSObject

- (void)getAllWardsForUser:(NSString *)user
       withCallBackHandler:(void (^)(id response, NSError *error))callBackHandler;

@end
