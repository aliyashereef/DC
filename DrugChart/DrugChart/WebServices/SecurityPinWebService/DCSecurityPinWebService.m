//
//  DCSecurityPinWebService.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/5/15.
//
//

#import "DCSecurityPinWebService.h"

@implementation DCSecurityPinWebService

- (void)checkSecurityPin:(NSString *)pin
     withCallbackHandler:(void (^)(id response, NSError *error))callbackHandler {
    
    //currently checking this against saved pin
    if ([pin isEqualToString:SAVED_PIN]) {
        callbackHandler(SUCCESS, nil);
    } else {
        NSError *error;
        callbackHandler(nil, error);
    }
}

@end
