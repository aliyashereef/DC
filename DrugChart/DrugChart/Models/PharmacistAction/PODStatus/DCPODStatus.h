//
//  DCPODStatus.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import <Foundation/Foundation.h>

#define PATIENT_OWN_DRUG_IPAD_IMAGE [UIImage imageNamed:@"OwnDrugIcon"]
#define PATIENT_OWN_DRUG_HOME_IPAD_IMAGE [UIImage imageNamed:@"OwnDrugHomeImage"]
#define PATIENT_OWN_BOTH_DRUG_AND_HOME_IPAD_IMAGE [UIImage imageNamed:@"OwnDrugAndHomeIcon"]

typedef enum : NSUInteger {
    ePatientOwnDrugs,
    ePatientOwnDrugsHome,
    ePatientOwnDrugsAndPatientOwnDrugsHome,
    eNoStatus
} PODStatusType;


@interface DCPODStatus : NSObject

@property (nonatomic) PODStatusType podStatusType;
//@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *notes;

+ (UIImage *)statusImageForPodStatus:(PODStatusType)podType;

@end
