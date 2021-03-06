//
//  DCPODStatus.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/16.
//
//

#import "DCPODStatus.h"

@implementation DCPODStatus

+ (UIImage *)statusImageForPodStatus:(PODStatusType)podType {
    
    switch (podType) {
        case ePatientOwnDrugs:
            return PATIENT_OWN_DRUG_IPAD_IMAGE;
        case ePatientOwnDrugsHome:
            return PATIENT_OWN_DRUG_HOME_IPAD_IMAGE;
        case ePatientOwnDrugsAndPatientOwnDrugsHome:
            return PATIENT_OWN_BOTH_DRUG_AND_HOME_IPAD_IMAGE;
        default:
            return nil;
    }
}

@end
