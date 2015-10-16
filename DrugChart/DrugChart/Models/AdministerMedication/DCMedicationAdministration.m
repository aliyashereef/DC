//
//  DCMedicationAdministration.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 15/07/15.
//
//

#define SCHEDULED_ADMINISTRATION_TIME @"scheduledDateTime"
#define ACTUAL_ADMINISTRATION_TIME @"actualAdministrationDateTime"
#define ADMINISTRATION_STATUS @"administrationStatus"
#define ADMINISTRATING_USER @"administratingUser"
#define ADMINISTRATING_DOSAGE @"amendedDosage"
#define ADMINISTRATING_BATCH @"batchNumber"
#define ADMINISTRATING_NOTES @"notes"
#define IS_SELF_ADMINISTERED @"IsSelfAdministered"


#import "DCMedicationAdministration.h"

@implementation DCMedicationAdministration

- (DCMedicationAdministration *)initWithAdministrationDetails:(NSDictionary *)administrationDetails {
    
    self = [[DCMedicationAdministration alloc] init];
    if (self) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:GMT]];
        NSDate *scheduledDate = [dateFormatter dateFromString:[administrationDetails objectForKey:SCHEDULED_ADMINISTRATION_TIME]];
        NSDate *actualDate = [dateFormatter dateFromString:[administrationDetails objectForKey:ACTUAL_ADMINISTRATION_TIME]];
        self.scheduledDateTime = scheduledDate;
        self.actualAdministrationTime = actualDate;
        self.status = [administrationDetails objectForKey:ADMINISTRATION_STATUS];
        
        DCUser *administratingUser = [[DCUser alloc] initWithUserDetails:[administrationDetails objectForKey:ADMINISTRATING_USER]];
        self.administratingUser = administratingUser;
        //checked by user
        DCUser *checkingUser = [[DCUser alloc] init];
        self.checkingUser = checkingUser;
        self.dosageString = [administrationDetails objectForKey:SCHEDULED_ADMINISTRATION_TIME];
        self.batch = [administrationDetails objectForKey:ADMINISTRATING_BATCH];
        if ([administrationDetails objectForKey:NOTES]) {
            NSString *notes = [administrationDetails objectForKey:ADMINISTRATING_NOTES];
            if ([self.status isEqualToString:ADMINISTERED]) {
                self.administeredNotes = notes;
            } else if ([self.status isEqualToString:REFUSED]) {
                self.refusedNotes = notes;
            } else {
                self.omittedNotes = notes;
            }
        }
        self.isSelfAdministered = [[administrationDetails objectForKey:IS_SELF_ADMINISTERED] boolValue];
        if (self.isSelfAdministered) {
            self.status = SELF_ADMINISTERED;
        }
    }
    return self;
}

@end
