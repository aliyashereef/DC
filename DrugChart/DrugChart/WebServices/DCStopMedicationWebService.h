//
//  DCStopMedicationWebService.h
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCStopMedicationWebService : NSObject

- (void)stopMedicationForPatientWithId:(NSString *)patientId
                    drugWithScheduleId:(NSString *)scheduleId
                   withCallBackHandler:(void (^)(id response, NSError *error))callBackHandler;

@end
