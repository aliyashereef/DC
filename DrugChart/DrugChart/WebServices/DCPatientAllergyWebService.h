//
//  DCPatientAlergyWebService.h
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

@interface DCPatientAllergyWebService : NSObject

- (void)getPatientAllergiesForId:(NSString *)patientId
          withCallBackHandler:(void (^)(NSArray *alergiesArray, NSError *error))callBackHandler;
@end
