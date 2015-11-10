//
//  DCMedication.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import "DCMedication.h"

#define RESOURCE_NAME_KEY @"name"
#define ID_KEY @"id"
#define EXTENSION_KEY @"extension"
#define VALUE_STRENGTH_KEY @"valueString"


@implementation DCMedication

- (DCMedication *)initWithMedicationDictionary:(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        
        NSDictionary *resourceDictionary = [medicationDictionary valueForKey:RESOURCE_KEY];
        if (resourceDictionary) {
            
            self.name = [resourceDictionary valueForKey:RESOURCE_NAME_KEY];
            self.medicationId = [resourceDictionary valueForKey:ID_KEY];
            NSArray *extensionArray = [resourceDictionary valueForKey:EXTENSION_KEY];
            @try {
                for (NSDictionary *valueDictionary in extensionArray) {
                    NSString *valueStrength = [valueDictionary valueForKey:VALUE_STRENGTH_KEY];
                    if (![valueStrength isEqualToString:EMPTY_STRING]) {
                        self.dosage = valueStrength;
                        break;
                    }
                }
            }
            @catch (NSException *exception) {
                DCDebugLog(@"exception : %@", exception.description);
            }
        }
    }
    return self;
}

@end
