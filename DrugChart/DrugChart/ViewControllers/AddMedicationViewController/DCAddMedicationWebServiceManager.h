//
//  DCAddMedicationWebServiceManager.h
//  DrugChart
//
//  Created by aliya on 10/09/15.
//
//

#import <Foundation/Foundation.h>
#import "DCAddMedicationWebService.h"
#import "DCMedicationScheduleDetails.h"

@interface DCAddMedicationWebServiceManager : NSObject

- (void)addMedicationServiceCallWithParameters:(NSDictionary *)medicationDictionary
                             ForMedicationType:(NSString *)medicationType
                                 WithPatientId:(NSString *)patientId
                           withCallbackHandler:(void (^)( NSError *))callBackHandler ;

- (NSDictionary *)medicationDetailsDictionaryForMedicationDetail:(DCMedicationScheduleDetails *)medication ;

@end
