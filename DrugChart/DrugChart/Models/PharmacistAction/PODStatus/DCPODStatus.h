//
//  DCPODStatus.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import <Foundation/Foundation.h>

#define PATIENT_OWN_DRUG_IMAGE [UIImage imageNamed:@"OwnDrugIcon"]
#define PATIENT_OWN_DRUG_HOME_IMAGE [UIImage imageNamed:@"OwnDrugHomeImage"]
#define PATIENT_OWN_BOTH_DRUG_AND_HOME_IMAGE [UIImage imageNamed:@"OwnDrugAndHomeIcon"]

typedef enum : NSUInteger {
    ePatientOwnDrugs,
    ePatientOwnDrugsHome,
    ePatientOwnDrugsAndPatientOwnDrugsHome
} PODStatusType;


@interface DCPODStatus : NSObject

@property (nonatomic) PODStatusType podStatusType;

+ (UIImage *)statusImageForPodStatus:(PODStatusType)podType;

@end
