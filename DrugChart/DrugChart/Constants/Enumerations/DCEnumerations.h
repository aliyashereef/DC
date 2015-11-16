//
//  DCEnumerations.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/14/15.
//
//

#ifndef DrugChart_DCEnumerations_h
#define DrugChart_DCEnumerations_h

//enums

typedef enum : NSInteger {
    eRoute,
    eMedicationType,
    eMedicationName,
    eDosage
    
} AddMedicationPopOverContentType;

typedef enum : NSInteger {
    
    eAdministerMedication,
    eAddMedication,
    eSecurity,
    ePrescriberDetails,
    eOverride
    
} SelectedPresentationViewType;

typedef enum : NSInteger {
    
    eDeleteMedicationConfirmation,
    eSaveAdministerDetails,
    eErrorDefaultAlertType,
    eOrderSetDeleteConfirmation,
    eOrderSetNameClearConfirmation,
    eNewOrderSetSelection,
    eAddSubstitute
    
} AlertType;

typedef enum : NSInteger {
    
    eTimePicker,
    eDatePicker,
    eStartDatePicker,
    eEndDatePicker
    
} DatePickerType;

typedef enum : NSInteger {
    
    eOrderSet,
    eMedication
    
} AutoSearchType;

typedef enum : NSInteger {
    eSevere,
    eMild
} WarningType;

typedef enum : NSUInteger {
    kMedicationDue,
    kMedicationInHalfHour,
    kMedicationInOneHour,
    kMedicationInOneAndHalfHour,
    kMedicationInTwoHours
} MedicationStatus;

typedef enum : NSUInteger {
    
    ePatientList,
    eCalendarView
} SortView;

typedef enum : NSUInteger {
    
    eDetailWarning,
    eDetailDosage,
    eDetailRoute,
    eDetailType,
    eDetailStartDate,
    eDetailEndDate,
    eDetailAdministrationTime,
    eNewDosage,
    eNewAdministrationTime,
    eOverrideReason,
    eDetailSchedulingType,
    eDetailRepeatType,
    
} AddMedicationDetailType;

typedef enum : NSUInteger {
    eNotes,
    eReason
} NotesType;

typedef enum : NSUInteger {
    
    eSchedulingFrequency,
    eDailyCount
    
} PickerType;

#endif
