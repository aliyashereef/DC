//
//  DCKeyChainManager.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/17/15.
//
//

#import <Foundation/Foundation.h>
#import "UICKeyChainStore.h"

@interface DCKeyChainManager : NSObject

@property (nonatomic, strong)  UICKeyChainStore *keychain;

+ (DCKeyChainManager *)sharedKeyChainManager;

- (void)saveToken:(NSString *)token forKey:(NSString *)key;

- (NSString *)getTokenForKey:(NSString *)key;

- (void)clearKeyStore;

@end
