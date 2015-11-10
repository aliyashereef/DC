//
//  DCMedicationAdministration.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 15/07/15.
//
//

#import "DCMedicationAdministration.h"

#define SCHEDULED_ADMINISTRATION_TIME_ADM @"scheduledDateTime"
#define ACTUAL_ADMINISTRATION_TIME_ADM @"actualAdministrationDateTime"
#define ADMINISTRATION_STATUS_ADM @"administrationStatus"
#define ADMINISTRATING_USER_ADM @"administratingUser"
#define ADMINISTRATING_DOSAGE_ADM @"amendedDosage"
#define ADMINISTRATING_BATCH_ADM @"batchNumber"
#define ADMINISTRATING_NOTES_ADM @"notes"
#define IS_SELF_ADMINISTERED_ADM @"isSelfAdministered"
#define EXPIRY_DATE_ADM @"expiryDate"
#define NOTES_ADM @"notes"

@implementation DCMedicationAdministration

- (DCMedicationAdministration *)initWithAdministrationDetails:(NSDictionary *)administrationDetails {
    
    self = [[DCMedicationAdministration alloc] init];
    if (self) {

        self.scheduledDateTime = [DCDateUtility administrationDateForString:[administrationDetails objectForKey:SCHEDULED_ADMINISTRATION_TIME_ADM]];
        self.actualAdministrationTime = [DCDateUtility administrationDateForString:[administrationDetails objectForKey:ACTUAL_ADMINISTRATION_TIME_ADM]];
        
        self.status = [administrationDetails objectForKey:ADMINISTRATION_STATUS_ADM];
        
        DCUser *administratingUser = [[DCUser alloc] initWithUserDetails:[administrationDetails objectForKey:ADMINISTRATING_USER_ADM]];
        self.administratingUser = administratingUser;
        //checked by user
        DCUser *checkingUser = [[DCUser alloc] init];
        self.checkingUser = checkingUser;
        self.dosageString = [administrationDetails objectForKey:ADMINISTRATING_DOSAGE_ADM];
        self.batch = [administrationDetails objectForKey:ADMINISTRATING_BATCH_ADM];
        if ([administrationDetails objectForKey:NOTES_ADM]) {
            NSString *notes = [administrationDetails objectForKey:ADMINISTRATING_NOTES_ADM];
            if ([self.status isEqualToString:ADMINISTERED]) {
                self.administeredNotes = notes;
            } else if ([self.status isEqualToString:REFUSED]) {
                self.refusedNotes = notes;
            } else {
                self.omittedNotes = notes;
            }
        }
        self.isSelfAdministered = [[administrationDetails objectForKey:IS_SELF_ADMINISTERED_ADM] boolValue];
    }
    return self;
}

@end
