//
//  DCSearchMedication.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/2/15.
//
//

#import "DCSearchMedication.h"

#define RESOURCE_KEY @"resource"
#define RESOURCE_TYPE_KEY @"resourceType"
#define RESOURCE_NAME_KEY @"name"
#define PRODUCT_KEY @"product"
#define FORM_KEY @"form"
#define TEXT_KEY @"text"
#define ID_KEY @"id"
#define EXTENSION_KEY @"extension"
#define VALUE_STRENGTH_KEY @"valueStrength"
#define DOSAGE_KEY @"dosage"
#define HAS_WARNING_KEY @"warning"
#define SEVERE_COUNT_KEY @"severeWarning"
#define MILD_COUNT_KEY @"mildWarning"
#define MEDICINE_NAME @"medicineName"
#define MEDICINE_CATEGORY @"medicineCategory"
#define DOSAGE @"dosage"
#define PRESCRIBED_BY @"prescribedBy"
#define TIME_CHART @"timeChart"
#define START_DATE @"startDate"
#define END_DATE @"endDate"
#define ROUTE @"route"
#define INSTRUCTION @"instruction"
#define NO_DATE @"noDate"
#define TIME_ARRAY @"timeArray"

#define MEDICATION_TIME @"time"
#define MEDICATION_STATUS @"status"
#define HAS_WARNING_KEY @"warning"
#define SEVERE_COUNT_KEY @"severeWarning"
#define MILD_COUNT_KEY @"mildWarning"
#define ONCE_DATE_KEY @"OnceDate"
#define ONCE_TIME_KEY @"OnceTime"

@implementation DCSearchMedication

- (DCSearchMedication *)initWithDictionary:(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        
        NSDictionary *resourceDictionary = [medicationDictionary valueForKey:RESOURCE_KEY];
        if (resourceDictionary) {
            
            self.resourceType = [resourceDictionary valueForKey:RESOURCE_TYPE_KEY];
            self.name = [resourceDictionary valueForKey:RESOURCE_NAME_KEY];
            self.medicationId = [resourceDictionary valueForKey:ID_KEY];
            NSArray *extensionArray = [resourceDictionary valueForKey:EXTENSION_KEY];
            @try {
                for (NSDictionary *dict in extensionArray) {
                    NSString *valueStrength = [dict valueForKey:VALUE_STRENGTH_KEY];
                    if (![valueStrength isEqualToString:EMPTY_STRING]) {
                        self.dosage = valueStrength;
                        break;
                    }
                }
            }
            @catch (NSException *exception) {
                DDLogError(@"exception : %@", exception.description);
            }
        }
        NSDictionary *productDictionary = [resourceDictionary valueForKey:PRODUCT_KEY];
        if (productDictionary) {
            
            NSDictionary *formDictionary = [productDictionary valueForKey:FORM_KEY];
            if (formDictionary) {
                
                self.productText = [formDictionary valueForKey:TEXT_KEY];
            }
        }
    }
    return self;
}

- (DCSearchMedication *)initWithMedicationDictionaryFromPlist:(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        
        self.name = [medicationDictionary valueForKey:MEDICINE_NAME];
        self.dosage = [medicationDictionary valueForKey:DOSAGE_KEY];
        self.hasWarning = [[medicationDictionary valueForKey:HAS_WARNING_KEY] boolValue];
        if (self.hasWarning) {
            self.severeWarningCount = @([medicationDictionary[SEVERE_COUNT_KEY] intValue]);
            self.mildWarningCount = @([medicationDictionary[MILD_COUNT_KEY] intValue]);
            self.warning = (self.severeWarningCount > 0) ? SEVERE_WARNING : MILD_WARNING;
        }
        self.name = [medicationDictionary valueForKey:MEDICINE_NAME];
        self.medicineCategory = [medicationDictionary valueForKey:MEDICINE_CATEGORY];
        self.prescribedBy = [medicationDictionary valueForKey:PRESCRIBED_BY];
        self.startDate = [medicationDictionary valueForKey:START_DATE];
        self.endDate = [medicationDictionary valueForKey:END_DATE];
        self.dosage = [medicationDictionary valueForKey:DOSAGE];
        self.route = [medicationDictionary valueForKey:ROUTE];
        self.instruction = [medicationDictionary valueForKey:INSTRUCTION];
        self.noEndDate = [[medicationDictionary valueForKey:NO_DATE] boolValue];
        self.timeArray = [medicationDictionary valueForKey:TIME_ARRAY];
    }
    return self;
}


@end
