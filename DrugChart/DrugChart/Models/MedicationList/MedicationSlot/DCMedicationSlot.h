//
//  DCMedicationStatus.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/13/15.
//
//

#import <Foundation/Foundation.h>
#import "DCAdministerMedication.h"
#import "DCMedicationAdministration.h"

@interface DCMedicationSlot : NSObject

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) DCMedicationAdministration *medicationAdministration;
@property (nonatomic) BOOL isOverridenAdministration;

@end
