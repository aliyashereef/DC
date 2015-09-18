//
//  DCAddMedicationOperation.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/7/15.
//
//

#import "DCAddMedicationOperation.h"
#import "DCAddMedicationWebService.h"

@interface DCAddMedicationOperation ()

@property (nonatomic, strong) NSString *medicationType;
@property (nonatomic, strong) NSString *patientId;
@property (nonatomic, strong) NSDictionary *requestDictionary;

@end

@implementation DCAddMedicationOperation


- (void)addMedicationDetailsWithMedicationType:(NSString *)type
                                  forPatientId:(NSString *)patientId
                                withParameters:(NSDictionary *)medicationDictionary {
    
    _medicationType = type;
    _patientId = patientId;
    _requestDictionary = medicationDictionary;
    self.name = [medicationDictionary valueForKey:[medicationDictionary valueForKey:PREPARATION_ID]];
}

- (void)callAddMedicationWebServiceWithCallbackHandler:(void (^) (id response, NSError *error))callbackHandler {
    
    //add addmedication webservice
    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [webService  addMedicationForMedicationType:_medicationType
                                   forPatientId:_patientId
                                 withParameters:_requestDictionary
                            withCallbackHandler:^(id response, NSError *error) {
                                
                                if (!error) {
                                    callbackHandler(response, nil);
                                } else {
                                    callbackHandler(nil, error);
                                }
                            }];
}



@end
