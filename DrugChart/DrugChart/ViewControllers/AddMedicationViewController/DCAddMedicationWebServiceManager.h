//
//  DCAddMedicationWebServiceManager.h
//  DrugChart
//
//  Created by aliya on 10/09/15.
//
//

#import <Foundation/Foundation.h>
#import "DCAddMedicationWebService.h"
#import "DCMedicationDetails.h"

@interface DCAddMedicationWebServiceManager : NSObject

- (void)addMedicationServiceCallWithParameters:(NSDictionary *)medicationDictionary
                             ForMedicationType:(NSString *)medicationType
                                 WithPatientId:(NSString *)patientId
                           withCallbackHandler:(void (^)( NSError *))callBackHandler ;

- (NSDictionary *)getMedicationDetailsDictionaryForMedicationDetail:(DCMedicationDetails *)medication ;

@end
