//
//  DCMedicationDetails.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/11/15.
//
//

#import <Foundation/Foundation.h>
#import "DCMedication.h"

@interface DCMedicationDetails : DCMedication

@property (nonatomic, strong) NSString *instruction;
@property (nonatomic, strong) NSString *medicineCategory;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSMutableArray *scheduleTimesArray;
@property BOOL hasWarning;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
//@property (nonatomic, strong) NSNumber *severeWarningCount;
//@property (nonatomic, strong) NSNumber *mildWarningCount;
@property (nonatomic, strong) NSString *warning;
@property (nonatomic, strong) NSString *onceMedicationDate;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic) BOOL noEndDate;
@property (nonatomic) BOOL overiddenSevereWarning;


- (DCMedicationDetails *)initWithOrderSetMedicationDictionary :(NSDictionary *)medicationDictionary;

@end