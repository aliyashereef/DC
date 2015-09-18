//
//  DCSearchMedication.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/2/15.
//
//

#import <Foundation/Foundation.h>

@interface DCSearchMedication : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *resourceType;
@property (nonatomic, strong) NSString *productText;
@property (nonatomic, strong) NSString *warning; //for temp purpose
@property (nonatomic, strong) NSString *medicationId;
@property (nonatomic, strong) NSString *dosage;
@property BOOL hasWarning;
@property (nonatomic, strong) NSNumber *severeWarningCount;
@property (nonatomic, strong) NSNumber *mildWarningCount;
@property (nonatomic) BOOL addMedicationCompletionStatus;
@property (nonatomic, strong) NSString *medicineCategory;
@property (nonatomic, strong) NSString *prescribedBy;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSDate *medicationStartDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSMutableArray *timeChart;
@property (nonatomic, strong) NSDate *nextMedicationDate;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *instruction;
@property (nonatomic) BOOL medicationStatus;
@property (nonatomic, strong) NSString *onceMedicationDate;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic) BOOL noEndDate;
@property (nonatomic) BOOL overiddenSevereWarning;

- (DCSearchMedication *)initWithDictionary:(NSDictionary *)medicationDictionary;//using live api
- (DCSearchMedication *)initWithMedicationDictionaryFromPlist:(NSDictionary *)medicationDictionary;//temp added for handling plist data, Remove once replaced with live ones

@end
