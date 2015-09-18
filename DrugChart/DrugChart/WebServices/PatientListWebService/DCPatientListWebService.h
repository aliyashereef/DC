//
//  DCPatientListWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "DCHTTPRequestOperationManager.h"

@interface DCPatientListWebService : NSObject

- (void)getPatientListForUser:(NSString *)userName
          withCallBackHandler:(void(^)(NSArray *patientListArray, NSDictionary *error))callBackHandler;

@end
