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
