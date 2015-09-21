//
//  DCContraIndicationWebService.m
//  DrugChart
//
//  Created by aliya on 21/07/15.
//
//

#import "DCContraIndicationWebService.h"
#import "DCWarning.h"

@implementation DCContraIndicationWebService

// To Do : Have to modify the URL according to specific preparation and patient ids
static NSString *const kDCContraIndicationUrl = @"patients/%@/interactions/%@";

- (void)getContraIndicationsForPatientWithId:(NSString *)patientId forDrugPreparationId:(NSString *)preparationId withCallBackHandler:(void (^)(NSArray *, NSError *))callBackHandler {
    
    NSString *requestUrl = [NSString stringWithFormat:kDCContraIndicationUrl, patientId, preparationId];
    [[DCHTTPRequestOperationManager sharedMedicationOperationManager] GET:requestUrl
                                                     parameters:nil
                                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                            
                                                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                                            NSMutableArray *warningsArray = [[NSMutableArray alloc] init];
                                                            NSArray *resultArray = [responseDict valueForKey:ENTRY_KEY];
                                                            NSLog(@"*** warningsArray is %@", resultArray);
                                                            for (NSDictionary *warningDict in resultArray) {
                                                                DCWarning *warning = [[DCWarning alloc] initWithDictionary:[warningDict valueForKey:RESOURCE_KEY]];
                                                                [warningsArray addObject:warning];
                                                            }
                                                            callBackHandler (warningsArray, nil);
                                                            
                                                        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            
                                                            callBackHandler (nil, error);
                                                        }
     ];
}

@end
