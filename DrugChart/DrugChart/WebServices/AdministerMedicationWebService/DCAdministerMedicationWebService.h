//
//  DCAdministerMedicationWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/5/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCAdministerMedicationWebService : DCHTTPRequestOperationManager

- (void)administerMedicationForScheduleId:(NSString *)scheduleId
                             forPatientId:(NSString *)patientId
                         withParameters:(NSDictionary *)administerDictionary
                     withCallbackHandler:(void (^)(id response, NSError *error))callBackHandler;
@end
