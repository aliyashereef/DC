//
//  DCMedicationDetails.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import "DCMedicationDetails.h"
#import "DrugChart-Swift.h"


#define PREPARATION_TERM @"preparationTerm"
#define PREPARATION_CODE_ID @"preparationCodeId"
#define DOSAGE_INSTRUCTIONS @"instructions"
#define DRUG_DOSAGE @"dosage"
#define DRUG_CATEGORY @"drugScheduleType"
#define TIMES @"times"
#define ROUTE_CODE_TERM @"routeCodeTerm"

@implementation DCMedicationDetails

- (DCMedicationDetails *)initWithOrderSetMedicationDictionary :(NSDictionary *)medicationDictionary {
    
    if (self == [super init]) {
        self.name = [medicationDictionary valueForKey:PREPARATION_TERM];
        self.medicationId = [medicationDictionary valueForKey:PREPARATION_CODE_ID];
        self.instruction = [medicationDictionary valueForKey:DOSAGE_INSTRUCTIONS];
        self.dosage = [medicationDictionary valueForKey:DRUG_DOSAGE];
        self.medicineCategory = [medicationDictionary valueForKey:DRUG_CATEGORY];
        self.route = [NSString stringWithFormat:@"%@ (PO)",[medicationDictionary valueForKey:ROUTE_CODE_TERM]];
        if ([self.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
            NSDictionary *scheduleDictionary = [[NSDictionary alloc] initWithDictionary:[medicationDictionary valueForKey:@"schedule"]];
            self.scheduleTimesArray = [scheduleDictionary valueForKey:TIMES];
        }
    }
    return self;
}

@end
