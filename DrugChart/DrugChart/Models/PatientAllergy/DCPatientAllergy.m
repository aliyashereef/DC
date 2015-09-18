//
//  DCPatientAllergy.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/5/15.
//
//

#import "DCPatientAllergy.h"

#define ALLERGIES_NAME_KEY @"name"
#define WARNING_TYPE_KEY @"warningType"
#define REASON_KEY @"reaction"

@implementation DCPatientAllergy

- (DCPatientAllergy *)initWithAllergyDictionary:(NSDictionary *)allergyDictionary {
    
    if (self = [super init]) {
        
        self.allergyName = [allergyDictionary objectForKey:ALLERGIES_NAME_KEY];
        self.warningType = [allergyDictionary objectForKey:WARNING_TYPE_KEY];
        self.reaction = [allergyDictionary objectForKey:REASON_KEY];
    }
    return self;
}

@end
