//
//  DCSecurityPinWebService.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/5/15.
//
//

#import <Foundation/Foundation.h>

@interface DCSecurityPinWebService : NSObject

- (void)checkSecurityPin:(NSString *)pin
        withCallbackHandler:(void (^)(id response, NSError *error))callbackHandler;
@end
