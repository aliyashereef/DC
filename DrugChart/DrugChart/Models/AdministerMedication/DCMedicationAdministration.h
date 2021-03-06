//
//  DCMedicationAdministration.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 15/07/15.
//
//
#import <Foundation/Foundation.h>
#import "DCUser.h"

@interface DCMedicationAdministration : NSObject

@property (nonatomic, strong) NSDate *scheduledDateTime;
@property (nonatomic, strong) NSDate *actualAdministrationTime;
@property (nonatomic, strong) NSDate *restartedDate;
@property (nonatomic, strong) NSDate *expiryDateTime;
@property (nonatomic, strong) DCUser *administratingUser;
@property (nonatomic, strong) DCUser *checkingUser;
@property (nonatomic, strong) NSString *dosageString;
@property (nonatomic, strong) NSString *doseEditReason;
@property (nonatomic, strong) NSString *batch;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *statusReason;
@property (nonatomic, strong) NSString *secondaryReason;
@property (nonatomic, strong) NSString *administeredNotes;
@property (nonatomic, strong) NSString *omittedNotes;
@property (nonatomic, strong) NSString *refusedNotes;
@property (nonatomic, strong) NSString *infusionStatusChangeReason;
@property (nonatomic) BOOL isSelfAdministered;
@property (nonatomic) BOOL isEarlyAdministration;
@property (nonatomic) BOOL isLateAdministration;
@property (nonatomic) BOOL isWhenRequiredEarlyAdministration;
@property (nonatomic) BOOL isDoseUpdated;
- (DCMedicationAdministration *)initWithAdministrationDetails:(NSDictionary *)administrationDetails;

@end
