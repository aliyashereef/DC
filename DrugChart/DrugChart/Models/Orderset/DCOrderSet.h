//
//  DCOrderSet.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/1/15.
//
//

#import <Foundation/Foundation.h>

#define IDENTIFIER                    @"identifier"
#define NAME                          @"name"
#define IS_USER_FAVOURITE             @"isUserFavourite"
#define MEDICATIONS                   @"requests"

@interface DCOrderSet : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) BOOL isUserFavourite;
@property (nonatomic, strong) NSString *ordersetDescription;
@property (nonatomic, strong) NSMutableArray *medicationList;

- (DCOrderSet *)initWithOrderSetDictionary:(NSDictionary *)orderSetDictionary;

@end

