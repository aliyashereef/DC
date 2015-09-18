//
//  DCLogOutWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/8/15.
//
//

#import <Foundation/Foundation.h>

@interface DCLogOutWebService : NSObject

- (void)logoutUserWithToken:(NSString *)token
          callback:(void (^)(id response, NSDictionary *error))callback;
@end
