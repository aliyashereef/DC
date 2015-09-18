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
@property (nonatomic, strong) DCUser *administratingUser;
@property (nonatomic, strong) NSString *dosageString;
@property (nonatomic, strong) NSString *batch;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic) BOOL isSelfAdministered;

- (DCMedicationAdministration *)initWithAdministrationDetails:(NSDictionary *)administrationDetails;

@end
