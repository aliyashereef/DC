//
//  DCAdministerMedication.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/17/15.
//
//

#import <Foundation/Foundation.h>

@interface DCAdministerMedication : NSObject

@property (nonatomic, strong) NSString *medicineName;
@property (nonatomic, strong) NSDate *medicationTime;
@property (nonatomic, strong) NSDate *scheduledTime;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *instruction;
@property (nonatomic, strong) NSString *medicationCategory;
@property (nonatomic, strong) NSString *medicationStatus;
@property (nonatomic, strong) NSString *dosage;
// administered by timing..
@property (nonatomic, strong) NSString *administeredBy;
@property (nonatomic, strong) NSString *checkedBy;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *batchNumber;
//omitted by
@property (nonatomic, strong) NSString *omittedReason;
@property (nonatomic, strong) NSString *omittedNotes;
//refused by
@property (nonatomic, strong) NSString *refusedNotes;
@property (nonatomic) BOOL isNewRequiredMedication;
@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL earlyAdministration;
@property (nonatomic, strong) NSString *scheduleId;

@end
