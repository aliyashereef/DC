//
//  DCAddMedicationWebService.m
//  DrugChart
//
//  Created by aliya on 06/07/15.
//
//

#import "DCAddMedicationWebService.h"
#import "DCMedicationDetails.h"


static NSString *const kOnceMedicationRequestUrl = @"patients/%@/drugschedules/oneoffrequest";
static NSString *const kRegularMedicationRequestUrl = @"patients/%@/drugschedules/regularrequest";
static NSString *const kWhenRequiredMedicationRequestUrl = @"patients/%@/drugschedules/whenrequiredrequest";

@implementation DCAddMedicationWebService

- (void)addMedicationForMedicationType :(NSString *)type
                           forPatientId:(NSString *)patientId
                         withParameters:(NSDictionary *)medicationDictionary
                    withCallbackHandler:(void (^)(id, NSError *))callBackHandler {
    
    NSString *requestURL;
    if ([type isEqualToString: REGULAR_MEDICATION]) {
        requestURL = [NSString stringWithFormat:kRegularMedicationRequestUrl,patientId];
    } else if ([type isEqualToString: ONCE_MEDICATION]) {
        requestURL = [NSString stringWithFormat:kOnceMedicationRequestUrl,patientId];
    } else {
        requestURL = [NSString stringWithFormat:kWhenRequiredMedicationRequestUrl,patientId];
    }
    [[DCHTTPRequestOperationManager sharedOperationManager] POST:requestURL
                                                      parameters:medicationDictionary
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             
                                                             callBackHandler(responseObject,nil);
                                                             
                                                         }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             callBackHandler(nil, error);
                                                         }
     ];
}


@end
