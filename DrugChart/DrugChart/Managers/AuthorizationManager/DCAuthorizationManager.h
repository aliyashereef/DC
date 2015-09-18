//
//  DCAuthorizationManager.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import <Foundation/Foundation.h>

@interface DCAuthorizationManager : NSObject

+ (DCAuthorizationManager *)sharedAuthorizationManager;

- (void)extractAndSaveUserTokensFromResponseHtml:(NSString *)htmlString;

@end
