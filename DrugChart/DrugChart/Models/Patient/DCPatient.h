//
//  DCPatient.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 02/03/15.
//
//

#import <Foundation/Foundation.h>
#import "DCBedGraphics.h"

#define PATIENT_ID @"identifier"
#define PATIENT_NAME @"patientName"
#define BED_ID @"bedId"
#define MEDICATION_LIST @"medicationList"
#define MEDICATION_DATE @"nextMedication"
#define ADD_DELAY @"add"
#define NHS_ID @"nhs"
#define CONSULTANT @"consultant"
#define DOB_DATE @"dob"
#define PATIENT_NUMBER @"patientNumber"
#define PATIENT_SEX_KEY            @"patientSex"
#define CONSULTANT_KEY             @"consultantDisplayName"
#define PATIENT_NAME_KEY           @"patientDisplayName"
#define NEXT_MEDICATION_KEY        @"nextDrugDateTime"

#define PATIENT_ALERTS_PLIST       @"PatientAlerts"
#define PATIENT_ALLERGIES_PLIST    @"PatientAllergies"

#define ADMISSION_DATE @"admissionDate"
#define EXPECTED_DISCHARGE_DATE @"expectedDischargeDate"
#define NEXT_DUE_MEDICATION @"nextDueMedication"
#define NEXT_DUE_ADMINISTRATION_DATE_TIME @"nextDueAdministrationDateTime"
#define PATIENT @"patient"
#define DISPLAY_NAME @"displayText"
#define PATIENT_URL @"href"

@interface DCPatient : NSObject

@property (nonatomic, strong) NSString *patientName;
@property (nonatomic, strong) NSString *patientId;
@property (nonatomic, strong) NSString *patientNumber;
@property (nonatomic, strong) NSString *bedId;
@property (nonatomic, strong) NSDictionary *medicationList;
@property (nonatomic, strong) NSDate *nextMedicationDate;
@property (nonatomic, strong) NSString *consultant;

@property (nonatomic, strong) NSDate *dob;
@property (nonatomic, strong) NSString *nhs;
@property (nonatomic, strong) NSString *age;

@property (nonatomic, strong) NSArray *medicationListArray;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *bedType;
@property (nonatomic, strong) DCBedGraphics *bedGraphics;
@property (nonatomic, strong) NSString *bedNumber;
@property (nonatomic) MedicationStatus emergencyStatus;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSMutableArray *patientsAlertsArray;
@property (nonatomic, strong) NSMutableArray *patientsAlergiesArray;

- (MedicationStatus)medicationStatus;
- (UIColor *)displayColorForMedicationStatus;
- (NSMutableAttributedString *)formattedDisplayMedicationDateForPatient;

- (DCPatient *)initWithPatientDictionary:(NSDictionary *)patientDictionary;
- (void)setPatientBedIdFromBedNumber:(NSNumber *)bedNumber;
- (void)setPatientBedType:(NSString *)bedType;
- (void)getAdditionalInformationAboutPatientFromUrlwithCallBackHandler:(void (^)(NSError *error))callBackHandler;
- (void)setPatientsAlerts;
- (void)setPatientsAllergies;

@end
