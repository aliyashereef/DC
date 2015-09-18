//
//  DCContraIndicationWebService.h
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCContraIndicationWebService : NSObject

- (void)getContraIndicationsForPatientWithId:(NSString *)patientId
                        forDrugPreparationId:(NSString *)preparationId
                         withCallBackHandler:(void (^)(NSArray *alergiesArray, NSError *error))callBackHandler;

@end
