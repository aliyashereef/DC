//
//  DCLogOutWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/8/15.
//
//

#import "DCLogOutWebService.h"
#import "DCKeyChainManager.h"

@implementation DCLogOutWebService

- (void)logoutUserWithToken:(NSString *)token
                   callback:(void (^)(id response, NSDictionary *error))callback {
    
    //clear cache
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[DCKeyChainManager sharedKeyChainManager] clearKeyStore];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
