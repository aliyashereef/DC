//
//  DCHTTPRequestOperationManager.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/04/15.
//
//

#import "DCHTTPRequestOperationManager.h"
#import "DCKeyChainManager.h"

//static NSString *const kDCBaseUrl = @"http://interfacetest.cloudapp.net/ehc-tapi"; //temporary url

 //old URLS (used till June 26, 2015)
//static NSString *const kDCBedManagementBaseUrl = @"https://interfacetest.cloudapp.net/ehc-api-bedmanagement";
//static NSString *const kDCMedicationBaseUrl = @"https://interfacetest.cloudapp.net/ehc-api-medication";

// Updated URLS (In use from June 26, 2015)
//static NSString *const kDCBedManagementBaseUrl = @"http://interfacetest.cloudapp.net/api";
//static NSString *const kDCMedicationBaseUrl = @"http://interfacetest.cloudapp.net/api";


@implementation DCHTTPRequestOperationManager

+ (DCHTTPRequestOperationManager *)sharedOperationManager {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[DCHTTPRequestOperationManager alloc] initWithBaseURLForBedManagament];
    });
    return _sharedObject;
}

+ (DCHTTPRequestOperationManager *)sharedMedicationOperationManager {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[DCHTTPRequestOperationManager alloc] initWithBaseURLForMedication];
    });
    return _sharedObject;
}

+ (DCHTTPRequestOperationManager *)sharedAdministerMedicationManager {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[DCHTTPRequestOperationManager alloc] initWithBaseURLforAdministerMedication];
    });
    return _sharedObject;
    
}

- (id)initWithBaseURLForBedManagament {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self setHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (id)initWithBaseURLForMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self setHeaderFieldsForRequest];
        [self setAdditionalHeadersForMedication];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json+fhir"];
    }
    return self;
}

- (id)initWithBaseURLforAdministerMedication {
    
    self = [super initWithBaseURL:[NSURL URLWithString:kDCBaseUrl]];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30.0f;
        [self setHeaderFieldsForRequest];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    return self;
}

- (void)setHeaderFieldsForRequest {
    
    NSString *accessToken = [[DCKeyChainManager sharedKeyChainManager] getTokenForKey:kUserAccessToken];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    id rolesProfile = [[DCKeyChainManager sharedKeyChainManager] getTokenForKey:kRolesProfile];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"RoleContext %@", [DCUtility encodeStringToBase64Format:rolesProfile]] forHTTPHeaderField:@"Cookie"];
}


- (void)setAdditionalHeadersForMedication {
    
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
