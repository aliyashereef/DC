//
//  DCHTTPRequestOperationManager.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/04/15.
//
//

#import "DCHTTPRequestOperationManager.h"
#import "DCKeyChainManager.h"

 //old URLS (used till June 26, 2015)
//static NSString *const kDCBedManagementBaseUrl = @"https://interfacetest.cloudapp.net/ehc-api-bedmanagement";
//static NSString *const kDCMedicationBaseUrl = @"https://interfacetest.cloudapp.net/ehc-api-medication";

// Updated URLS (In use from June 26, 2015)
//static NSString *const kDCBedManagementBaseUrl = @"http://interfacetest.cloudapp.net/api";
//static NSString *const kDCMedicationBaseUrl = @"http://interfacetest.cloudapp.net/api";


@implementation DCHTTPRequestOperationManager

+ (DCHTTPRequestOperationManager *)sharedOperationManager {
    static dispatch_once_t onceTokenForBase = 0;
    static dispatch_once_t onceTokenForDemo = 0;
    __strong static id _sharedObject_Base = nil;
    __strong static id _sharedObject_Demo = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_TOGGLE_BUTTON_KEY]) {
        dispatch_once(&onceTokenForBase, ^{
         _sharedObject_Demo = [[DCHTTPRequestOperationManager alloc] initWithDemoURLForBedManagament];
         });
       return _sharedObject_Demo;
        } else {
              dispatch_once(&onceTokenForDemo, ^{
               _sharedObject_Base = [[DCHTTPRequestOperationManager alloc] initWithBaseURLForBedManagament];
            });
           return _sharedObject_Base;
        }
}


+ (DCHTTPRequestOperationManager *)sharedVitalSignManager {
    static dispatch_once_t onceTokenForBase = 0;
    static dispatch_once_t onceTokenForDemo = 0;
    __strong static id _sharedObject_Base = nil;
    __strong static id _sharedObject_Demo = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_TOGGLE_BUTTON_KEY]) {
        dispatch_once(&onceTokenForBase, ^{
            _sharedObject_Demo =[[DCHTTPRequestOperationManager alloc] initWithURLForVitalSign:kDCBaseVitalSignUrl_Demo];
        });
        return _sharedObject_Demo;
    } else {
        dispatch_once(&onceTokenForDemo, ^{
            _sharedObject_Base = [[DCHTTPRequestOperationManager alloc] initWithURLForVitalSign:kDCBaseVitalSignUrl];
        });
        return _sharedObject_Base;
    }
}


+ (DCHTTPRequestOperationManager *)sharedMedicationOperationManager {
    
    static dispatch_once_t onceTokenForBase = 0;
    static dispatch_once_t onceTokenForDemo = 0;
    __strong static id _sharedObject_Base = nil;
    __strong static id _sharedObject_Demo = nil;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_TOGGLE_BUTTON_KEY]) {
        dispatch_once(&onceTokenForBase, ^{
            
            _sharedObject_Demo = [[DCHTTPRequestOperationManager alloc] initWithDemoURLForMedication];
        });
        return _sharedObject_Demo;
    } else {
        dispatch_once(&onceTokenForDemo, ^{
            
            _sharedObject_Base = [[DCHTTPRequestOperationManager alloc] initWithBaseURLForMedication];
        });
        return _sharedObject_Base;
    }
}

+ (DCHTTPRequestOperationManager *)sharedAdministerMedicationManager {
    
    static dispatch_once_t onceTokenForBase = 0;
    static dispatch_once_t onceTokenForDemo = 0;
    __strong static id _sharedObject_Base = nil;
    __strong static id _sharedObject_Demo = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_TOGGLE_BUTTON_KEY]) {
        dispatch_once(&onceTokenForBase, ^{
            
            _sharedObject_Demo = [[DCHTTPRequestOperationManager alloc] initWithDemoURLforAdministerMedication];
        });
        return _sharedObject_Demo;
    } else {
        dispatch_once(&onceTokenForDemo, ^{
            
            _sharedObject_Base = [[DCHTTPRequestOperationManager alloc] initWithBaseURLforAdministerMedication];
        });
        return _sharedObject_Base;
    }
    
}

- (id)initWithBaseURLForBedManagament {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (id)initWithDemoURLForBedManagament {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl_Demo]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (id)initWithURLForVitalSign: (NSString*)url
{
    
    self = [super initWithBaseURL:[NSURL URLWithString:url]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForVitalSignRequest];
        [self.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Content-Type"];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json+fhir"];
    }
    return self;
}


- (id)initWithDemoURLForMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl_Demo]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        [self configureAdditionalHeadersForMedication];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json+fhir"];
    }
    return self;
}

- (id)initWithBaseURLForMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        [self configureAdditionalHeadersForMedication];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json+fhir"];
    }
    return self;
}

- (id)initWithDemoURLforAdministerMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl_Demo]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    return self;
}

- (id)initWithBaseURLforAdministerMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self configureHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    return self;
}

- (void)configureHeaderFieldsForRequest {
    
    NSString *accessToken = [[DCKeyChainManager sharedKeyChainManager] getTokenForKey:kUserAccessToken];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    id rolesProfile = [[DCKeyChainManager sharedKeyChainManager] getTokenForKey:kRolesProfile];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"RoleContext %@", [DCUtility encodeStringToBase64Format:rolesProfile]] forHTTPHeaderField:@"Cookie"];
}



- (void)configureHeaderFieldsForVitalSignRequest {
    NSString *token = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSIsImtpZCI6ImEzck1VZ01Gdjl0UGNsTGE2eUYzekFrZnF1RSJ9.eyJpc3MiOiJodHRwOi8vZW1pc3ZpdGFsc2lnbnMuY2xvdWRhcHAubmV0L2lkZW50aXR5c2VydmVyL2NvcmUiLCJhdWQiOiJodHRwOi8vZW1pc3ZpdGFsc2lnbnMuY2xvdWRhcHAubmV0L2lkZW50aXR5c2VydmVyL2NvcmUvcmVzb3VyY2VzIiwiZXhwIjoxNDU5MDkxNTAxLCJuYmYiOjE0NTY0OTk1MDEsImNsaWVudF9pZCI6ImVtaXNfbW9iaWxlIiwic2NvcGUiOlsib3BlbmlkIiwib3BlbmFwaSIsIm9mZmxpbmVfYWNjZXNzIl0sInN1YiI6ImVtaXN0cmFpbmVyIiwiYXV0aF90aW1lIjoxNDU2NDk5NTAwLCJpZHAiOiJFbWlzSGVhbHRoIiwic2Vzc2lvbklkIjoiYjNmZDMxNzktM2IwYy00M2U1LTlhYWItZWI2ZDFiNWNmNDQ0IiwibmFtZSI6ImVtaXN0cmFpbmVyIiwicm9sZSI6ImV5SlBjbWRoYm1sellYUnBiMjVIZFdsa0lqb2lZV0ZrWW1RMU1qZ3RNRGcyWXkwME0yRTVMV0poWlRNdFpHRmlNekl3TkRrd05tVXpJaXdpVlhObGNrbHVVbTlzWlVsa0lqb3hOREF4TENKVmMyVnlTVzVTYjJ4bFVtOXNaVkJ5YjJacGJHVkpaQ0k2TVRRd01uMD0iLCJhbXIiOlsiZXh0ZXJuYWwiXX0.BT9YiiXcMSlOU4Q6L4rlfncLScRAy5AAsyEf_bGC4kq773tf4mZ61JbMqwFKoCK41IGHuvwLwtyWB0hldoJMmiPlHxGbK6n3z-IN-kFGCkhEVoUMqZBCGkX6kIxzmmmEs-rQMkZlBtL88PSkkoE4szaq4N8RTcM9ndGJxx6NAGxioSBvju9B9JHfPbX4P7GAvpS_6IHoEFG4K4Q_i8h1chNYBZ0FwWGjnLazwkfcTHmmiv_5kSUZRZkj1GItnS8nKHGei1ZLiL_BAoYxyS04cQviZ9-XQniq_rDQjN0Sdsvq2Evahh_fBIpbeu4Nn61-lKzBcjo03gidIlmR4mWJrQ";
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}


- (void)configureAdditionalHeadersForMedication {
    
    [self.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json+fhir" forHTTPHeaderField:@"Accept"];
}

- (void)cancelAllWebRequests {
    
    [self.operationQueue cancelAllOperations];
}

// method checks for the URL and cancels the url request.
- (void)cancelWebRequestWithPath:(NSString *)path {
    
    NSArray *operations = self.operationQueue.operations;
    for (AFHTTPRequestOperation *operation in operations) {
        NSString *urlString = [operation.request.URL absoluteString];
        if ([urlString containsString:path]) {
            [operation cancel];
        }
    }
}

@end
