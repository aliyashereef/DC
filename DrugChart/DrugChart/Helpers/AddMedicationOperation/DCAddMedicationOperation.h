//
//  DCAddMedicationOperation.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/7/15.
//
//

#import <Foundation/Foundation.h>


@interface DCAddMedicationOperation : NSOperation

@property (nonatomic, strong) NSString *operationId;

- (void)addMedicationDetailsWithMedicationType:(NSString *)type
                           forPatientId:(NSString *)patientId
                                       withParameters:(NSDictionary *)medicationDictionary;

- (void)callAddMedicationWebServiceWithCallbackHandler:(void (^) (id response, NSError *error))callbackHandler;

@end
