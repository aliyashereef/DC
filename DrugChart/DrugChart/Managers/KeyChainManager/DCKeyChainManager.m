//
//  DCKeyChainManager.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/17/15.
//
//

#import "DCKeyChainManager.h"

@implementation DCKeyChainManager

+ (DCKeyChainManager *)sharedKeyChainManager {
    
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[DCKeyChainManager alloc] init];
        
    });
    return _sharedObject;
}

- (UICKeyChainStore *)getKeyChainStoreService {
    
    //get key chain service
    if (!_keychain) {
        
        _keychain = [UICKeyChainStore keyChainStoreWithServer:[NSURL URLWithString:[[NSBundle mainBundle] bundleIdentifier]]
                                                 protocolType:UICKeyChainStoreProtocolTypeHTTPS];;
    }
    return _keychain;
}

- (void)saveToken:(NSString *)token forKey:(NSString *)key {
    
    NSError *error;
    UICKeyChainStore *keychain = [self getKeyChainStoreService];
    [keychain setString:token forKey:key error:&error];
    if (error) {
        DDLogError(@"Error on saving token : %@", error.localizedDescription);
    }
}

- (NSString *)getTokenForKey:(NSString *)key {
    
    NSError *error;
    NSString *token = [[self getKeyChainStoreService] stringForKey:key error:&error];
    if (error) {
        DDLogError(@"Error on retrieving token : %@", error.localizedDescription);
    }
    return token;
}

- (void)clearKeyStore {
    
    //reset key store contents to nil
    UICKeyChainStore *keychain = [self getKeyChainStoreService];
    NSError *error;
    [keychain removeAllItemsWithError:&error];
    if (error) {
        DDLogError(@"error is %@", error.localizedDescription);
    }
}

@end
