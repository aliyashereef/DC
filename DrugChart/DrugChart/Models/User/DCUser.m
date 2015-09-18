//
//  DCUser.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCUser.h"

#define USER_ID_KEY @"identifier"
#define USER_NAME_KEY @"displayText"
#define USER_TITLE @"title"
#define USER_FORENAME @"forenames"
#define USER_SURNAME @"surname"


@implementation DCUser

- (DCUser *)initWithUserDetails: (NSDictionary *)userDetailsDictionary {
    
    self = [super init];
    if (self) {
        self.userIdentifier = [userDetailsDictionary objectForKey:USER_ID_KEY];
        self.displayName = [userDetailsDictionary objectForKey:USER_NAME_KEY];
        self.title = [userDetailsDictionary objectForKey:USER_TITLE];
        self.foreName = [userDetailsDictionary objectForKey:USER_FORENAME];
        self.surName = [userDetailsDictionary objectForKey:USER_SURNAME];
    }
    return self;
}

@end
