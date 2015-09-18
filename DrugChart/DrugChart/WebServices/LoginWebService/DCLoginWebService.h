//
//  DCLoginWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import <Foundation/Foundation.h>
#import "DCHTTPRequestOperationManager.h"

#define STATUS_KEY @"status"
#define USER_KEY @"user"
#define STATUS_OK @"OK"
#define STATUS_ERROR @"ERROR"

@interface DCLoginWebService : NSObject

@property (nonatomic, strong) NSString *urlString;

- (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                  callback:(void (^)(id response, NSDictionary *error))callback;
@end
