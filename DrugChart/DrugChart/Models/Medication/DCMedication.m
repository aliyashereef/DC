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
#define VALUE_ROUTE @"valueCodeableConcept"


@implementation DCMedication

- (DCMedication *)initWithMedicationDictionary:(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        
        NSDictionary *resourceDictionary = [medicationDictionary valueForKey:RESOURCE_KEY];
        if (resourceDictionary) {
            self.routeArray = [[NSMutableArray alloc] init];
            self.name = [resourceDictionary valueForKey:RESOURCE_NAME_KEY];
            self.medicationId = [resourceDictionary valueForKey:ID_KEY];
            NSArray *extensionArray = [resourceDictionary valueForKey:EXTENSION_KEY];
            @try {
                for (NSDictionary *valueDictionary in extensionArray) {
                    NSString *valueStrength = [valueDictionary valueForKey:VALUE_STRENGTH_KEY];
                    if (![valueStrength isEqualToString:EMPTY_STRING]) {
                            self.dosage = valueStrength;
                        
                        NSArray *extensionArray = [valueDictionary valueForKey:EXTENSION_KEY];
                        for (NSDictionary *routeValueDictionary in extensionArray) {
                            if ([routeValueDictionary valueForKey:VALUE_ROUTE]) {
                                NSString *valueRoute = [[routeValueDictionary valueForKey:VALUE_ROUTE] valueForKey:@"text"];
                                NSString *routeCodeId = [[[routeValueDictionary valueForKey:VALUE_ROUTE] valueForKey:@"coding"] valueForKey:@"code"];
                                if (![valueRoute isEqualToString:EMPTY_STRING]) {
                                    NSDictionary *route = [[NSDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%@",valueRoute]] forKeys:@[[NSString stringWithFormat:@"%@",routeCodeId]]];
                                    [self.routeArray addObject:route];
                                }
                            }
                        }
                    }
                }
            }
            @catch (NSException *exception) {
                DDLogError(@"exception : %@", exception.description);
            }
        }
    }
    return self;
}

@end
