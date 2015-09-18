//
//  DCOrderSet.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/1/15.
//
//

#import "DCOrderSet.h"
#import "DCMedicationDetails.h"

#define NAME_KEY @"name"
#define DESCRIPTION_KEY @"description"
#define MEDICATIONS_KEY @"medications"

@implementation DCOrderSet

- (DCOrderSet *)initWithOrderSetDictionary:(NSDictionary *)orderSetDictionary {
    
    DCOrderSet *orderSet = [[DCOrderSet alloc] init];
    orderSet.name = [orderSetDictionary valueForKey:NAME];
    orderSet.identifier = [orderSetDictionary valueForKey:IDENTIFIER];
    NSNumber *favouriteValue = [NSNumber numberWithInt:[[orderSetDictionary valueForKey:IS_USER_FAVOURITE] intValue]];
    orderSet.isUserFavourite = [favouriteValue boolValue];
    NSArray *medicationArray = [orderSetDictionary valueForKey:MEDICATIONS];
    orderSet.medicationList = [[NSMutableArray alloc] init];
    for (NSDictionary *medicationDict in medicationArray) {
        DCMedicationDetails *medicationDetails = [[DCMedicationDetails alloc] initWithOrderSetMedicationDictionary:medicationDict];
        [orderSet.medicationList addObject:medicationDetails];
    }
    return orderSet;
}

@end
