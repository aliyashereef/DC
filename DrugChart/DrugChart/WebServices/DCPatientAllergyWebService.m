//
//  DCPatientAlergyWebService.m
//  DrugChart
//
//  Created by aliya on 08/07/15.
//
//

#import "DCPatientAllergyWebService.h"

#define ENTRY @"entry"
#define RESOURCE @"resource"
#define SUBSTANCE @"substance"
#define TEXT @"text"
#define WARNING_TYPE @"warningType"
#define EXTENSION @"extension"
#define NAME @"name"
#define VALUE_STRING @"valueString"
#define REACTION @"reaction"
#define URL @"url"

@implementation DCPatientAllergyWebService

static NSString *const kAllergiesUrl = @"patients/%@/allergies";
static NSString *const kAllergyAPIUrl = @"http://openapi.e-mis.com/fhir/extensions/original-term";

- (void)getPatientAllergiesForId:(NSString *)patientId
            withCallBackHandler:(void (^)(NSArray *allergiesArray, NSError *error))callBackHandler {
    NSString *allergiesUrl = [NSString stringWithFormat:kAllergiesUrl, patientId];
    [[self getHTTPRequestManager] GET:allergiesUrl
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSMutableArray *allergiesArray = [[NSMutableArray alloc] init];
                                  @try {
                                      NSMutableDictionary *responseDictionary = (NSMutableDictionary *)responseObject;
                                      NSMutableArray *allergyArray = [responseDictionary valueForKey:ENTRY];
                                      for (NSMutableDictionary *allergiesDictionary in allergyArray) {
                                          NSMutableDictionary *allergyDictionary = [[NSMutableDictionary alloc] init];
                                          NSDictionary *resourceDictionary = [[allergiesDictionary valueForKey:RESOURCE] valueForKey:SUBSTANCE];
                                          [allergyDictionary setValue:[resourceDictionary valueForKey:TEXT] forKey:NAME];
                                          [allergyDictionary setValue:@"" forKey:WARNING_TYPE];
                                          
                                          NSArray *urlArray = [resourceDictionary valueForKey:EXTENSION];
                                          for(NSDictionary *urlDictionary in urlArray) {
                                              if([[urlDictionary valueForKey:URL] isEqualToString: kAllergyAPIUrl]) {
                                                  [allergyDictionary setValue:[urlDictionary valueForKey:VALUE_STRING] forKey:REACTION];
                                              }
                                          }
                                          [allergiesArray addObject:allergyDictionary];
                                      }
                                  }
                                  @catch (NSException *exception) {
                                  }
                                  callBackHandler (allergiesArray, nil);
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  callBackHandler (nil, error);
                              }
     ];
    
}

- (DCHTTPRequestOperationManager *)getHTTPRequestManager {
    
    DCAppDelegate *appDelegate = DCAPPDELEGATE;
    DCHTTPRequestOperationManager *manager = [[DCHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:appDelegate.baseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager setHeaderFieldsForRequest];
    [manager.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json+fhir"];
    return manager;
}

@end
