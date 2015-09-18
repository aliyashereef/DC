//
//  DCUsersListWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/7/15.
//
//

#import <Foundation/Foundation.h>

@interface DCUsersListWebService : NSObject

- (void)getUsersListWithCallback:(void (^)(NSArray *usersList, NSError *error))callback;
@end
