//
//  DCMedicationSearchWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/2/15.
//
//

#import "DCMedicationSearchWebService.h"
#import "DCHTTPRequestOperationManager.h"
#import "DCMedication.h"

static NSString *const kEntryKey = @"entry";
static NSString *const kDCMedicationBaseUrl = @"/medication?name";

@implementation DCMedicationSearchWebService

- (void)getCompleteMedicationListWithCallBackHandler:(void (^) (id response, id error))callBackHandler {
    
    DCAppDelegate *appDelegate = DCAPPDELEGATE;
    NSString *request = [NSString stringWithFormat:@"%@%@",appDelegate.baseURL,kDCMedicationBaseUrl];
    [[DCHTTPRequestOperationManager sharedMedicationOperationManager] cancelWebRequestWithPath:request];
    NSString *urlString = [NSString stringWithFormat:@"medication?name=%@",_searchString] ;
    NSString *requestUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[DCHTTPRequestOperationManager sharedMedicationOperationManager] GET:requestUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSArray *medicationArray = [responseDict valueForKey:kEntryKey];
            NSMutableArray *searchListArray = [[NSMutableArray alloc] init];
            for (NSDictionary *medicationDictionary in medicationArray) {
                DCMedication *medication = [[DCMedication alloc] initWithMedicationDictionary:medicationDictionary];
                [searchListArray addObject:medication];
                
            }
            callBackHandler (searchListArray, nil);
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in parsing medication search list: %@", exception);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *errorMessage = (operation.responseString == nil) ? NSLocalizedString(@"WEBSERVICE_FAILED", @"") : operation.responseString;
        
        NSDictionary *errorDict = @{@"code" : [NSNumber numberWithInteger:error.code],
                                    @"message" : errorMessage};
        callBackHandler(nil, errorDict);
    }];
}

- (void)cancelPreviousRequest {
    
    //cancel web request
    DCAppDelegate *appDelegate = DCAPPDELEGATE;
    NSString *request = [NSString stringWithFormat:@"%@%@",appDelegate.baseURL,kDCMedicationBaseUrl];
    [[DCHTTPRequestOperationManager sharedMedicationOperationManager] cancelWebRequestWithPath:request];
}

@end
