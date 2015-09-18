//
//  DCAuthorizationManager.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import "DCAuthorizationManager.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "DCKeyChainManager.h"

#define INPUT_KEY @"input"
#define NAME_KEY @"name"
#define ACCESS_TOKEN @"access_token"
#define ID_TOKEN @"id_token"
#define VALUE_KEY @"value"

#define ROLE_PROFILE_KEY        @"roleprofiles"
#define ROLE_PROFILE_NAME_KEY   @"RoleProfileName"


@implementation DCAuthorizationManager

+ (DCAuthorizationManager *)sharedAuthorizationManager {
    
    static dispatch_once_t p = 0;
    __strong static id _sharedManager = nil;
    dispatch_once(&p, ^{
        _sharedManager = [[DCAuthorizationManager alloc] init];
        
    });
    return _sharedManager;
}

- (void)extractAndSaveUserTokensFromResponseHtml:(NSString *)htmlString {
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
    if (error) {
        DCDebugLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:INPUT_KEY];
    for (HTMLNode *inputNode in inputNodes) {
        NSString *inputNodeName = [inputNode getAttributeNamed:NAME_KEY];
        if ([inputNodeName isEqualToString:ACCESS_TOKEN]) {
            NSString *accessToken = [inputNode getAttributeNamed:VALUE_KEY];
            NSLog(@"ACCESS TOKEN %@",accessToken);
            [[DCKeyChainManager sharedKeyChainManager] saveToken:accessToken forKey:kUserAccessToken];
        }
        if ([inputNodeName isEqualToString:ID_TOKEN]) {
            NSString *idToken = [inputNode getAttributeNamed:VALUE_KEY];
            NSLog(@"COOKIE %@",idToken);
            [[DCKeyChainManager sharedKeyChainManager] saveToken:idToken forKey:kUserIdToken];
            [self saveRoleProfileFromIdentityToken];
        }
    }
}

- (void)saveRoleProfileFromIdentityToken {
    
    //get role profile from identity token
    NSString *idToken = [[DCKeyChainManager sharedKeyChainManager] getTokenForKey:kUserIdToken];
    NSArray *subComponents = [idToken componentsSeparatedByString:DOT];
    NSString *roleProfileEncodedString = [subComponents objectAtIndex:1];
    NSString *roleProfileDecodedString = [DCUtility decodeBase64EncodedString:roleProfileEncodedString];
    NSDictionary *roleProfileDictionary = [DCUtility convertjsonStringToDictionary:roleProfileDecodedString];
    NSArray *rolesArray = [DCUtility convertJSONStringToArray:[roleProfileDictionary objectForKey:ROLE_PROFILE_KEY]];
    //TODO: - currently role checked commented, complete this after clarification
    //[self setUserRoleFromRolesArray:rolesArray];
    [DCAPPDELEGATE setUserRole:ROLE_DOCTOR];
    NSDictionary *rolesConversion = (NSDictionary *)[rolesArray objectAtIndex:0]; //currently taking value at initial index
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rolesConversion options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    [[DCKeyChainManager sharedKeyChainManager] saveToken:jsonString forKey:kRolesProfile];
}

- (void)setUserRoleFromRolesArray:(NSArray *)rolesArray {
    
    //set user roles
    NSString *roleProfileName = EMPTY_STRING;
    for (id content in rolesArray) {
        //check for roles in array
        NSDictionary *roleDictionary = [DCUtility convertjsonStringToDictionary:content];
        roleProfileName = [roleDictionary valueForKey:ROLE_PROFILE_NAME_KEY];
        if ([roleProfileName isEqualToString:CLINICAL_PRACTITIONER_ROLE] || [roleProfileName isEqualToString:PRACTICE_MANAGER_ROLE]) {
            //nurse role
            [DCAPPDELEGATE setUserRole:ROLE_DOCTOR];
            break;
        } else {
            if ([roleProfileName isEqualToString:NURSE_ACCESS_ROLE] || [roleProfileName isEqualToString:NURSE_MANAGER_ROLE]) {
                //doctor role
                [DCAPPDELEGATE setUserRole:ROLE_NURSE];
                break;
            }
        }
    }
    if ([roleProfileName isEqualToString:EMPTY_STRING]) {
        //for temp purpose , currently setting role to doctor when returned value is not present in check list
        [DCAPPDELEGATE setUserRole:ROLE_DOCTOR];
    }
}

@end
