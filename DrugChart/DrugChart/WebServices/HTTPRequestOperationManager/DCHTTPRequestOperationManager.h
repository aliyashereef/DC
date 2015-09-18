//
//  DCHTTPRequestOperationManager.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 08/04/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface DCHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (DCHTTPRequestOperationManager *)sharedOperationManager;

+ (DCHTTPRequestOperationManager *)sharedMedicationOperationManager;

+ (DCHTTPRequestOperationManager *)sharedAdministerMedicationManager;

- (void)setHeaderFieldsForRequest;

- (void)cancelAllWebRequests;

- (void)cancelWebRequestWithPath:(NSString *)path;

@end
