//
//  DCMedication.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import <Foundation/Foundation.h>

#define NEXT_MEDICATION_DATE_KEY @"nextMedicationDate"

@interface DCMedication : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *medicationId;
@property (nonatomic, strong) NSString *dosage;
@property BOOL addMedicationCompletionStatus;
@property (nonatomic) NSInteger severeWarningCount;
@property (nonatomic) NSInteger mildWarningCount;
@property (nonatomic, strong) NSString *overriddenReason;


- (DCMedication *)initWithMedicationDictionary:(NSDictionary *)medicationDictionary;

@end
