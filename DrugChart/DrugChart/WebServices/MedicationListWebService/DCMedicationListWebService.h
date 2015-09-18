//
//  DCMedicationListWebService.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 06/03/15.
//
//

#import "DCHTTPRequestOperationManager.h"

@interface DCMedicationListWebService : NSObject

- (void)getMedicationListForPatientDemo:(NSString *)patientId
                withCallBackHandler:(void(^)(NSArray *medicationList, NSDictionary *error))callBackHandler;

@end
