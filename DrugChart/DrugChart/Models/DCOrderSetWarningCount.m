//
//  DCOrderSetWarningCount.m
//  DrugChart
//
//  Created by aliya on 11/08/15.
//
//

#import "DCOrderSetWarningCount.h"

static NSString *const KMedicationID           =       @"targetPreparationCodeId";
static NSString *const kSevereCount            =       @"totalHighSeverity";
static NSString *const kMildCount              =       @"totalMediumSeverity";

@implementation DCOrderSetWarningCount

- (DCOrderSetWarningCount *)initWithDictionary:(NSDictionary*)warningDictionary {
    
    if (self == [super init]) {
        
        if ([warningDictionary valueForKey:KMedicationID]) {
            self.medicationId = [warningDictionary valueForKey:KMedicationID];
        }
        if ([warningDictionary valueForKey:kSevereCount]) {
            self.severeWarningCount = [warningDictionary valueForKey:kSevereCount];
        }
        if ([warningDictionary valueForKey:KMedicationID]) {
            self.mildWarningCount = [warningDictionary valueForKey:kMildCount];
        }
    }
    return self;
}

@end
