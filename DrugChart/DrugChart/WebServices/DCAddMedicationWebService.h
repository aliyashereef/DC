//
//  DCAddMedicationWebService.h
//  DrugChart
//
//  Created by aliya on 06/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCAddMedicationWebService : NSObject

- (void)addMedicationForMedicationType :(NSString *)type
                           forPatientId:(NSString *)patientId
             withParameters:(NSDictionary *)medicationDictionary
                  withCallbackHandler:(void (^)(id response, NSError *error))callBackHandler;

@end
