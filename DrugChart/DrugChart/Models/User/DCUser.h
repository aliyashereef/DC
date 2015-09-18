//
//  DCUser.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import <Foundation/Foundation.h>

@interface DCUser : NSObject

@property (nonatomic, strong) NSString *userIdentifier;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *foreName;
@property (nonatomic, strong) NSString *surName;

- (DCUser *)initWithUserDetails: (NSDictionary *)userDetailsDictionary;

@end
