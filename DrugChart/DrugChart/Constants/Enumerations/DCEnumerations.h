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
    eDetailAdministrationTime,
    //eNewDosage,
    eNewAdministrationTime,
    eOverrideReason,
    
} AddMedicationDetailType;

typedef enum : NSUInteger {
    
    eDetailSchedulingType,
    eDetailSpecificTimesRepeatType,
    eDetailIntervalRepeatFrequency
    
} SchedulingDetailType;

typedef enum : NSUInteger {
    eNotes,
    eReason
} NotesType;

typedef enum : NSInteger {
    
    eDosageMenu,
    eFixedDosage,
    eVariableDosage,
    eReducingIncreasing,
    eSplitDaily
}DosageSelectionType;

typedef enum : NSUInteger {
    
    eDoseUnit,
    eDoseValue,
    eDoseFrom,
    eDoseTo,
    eStartingDose,
    eChangeOver,
    eAddNewDosage,
    eAddDoseForTime,
    eAddNewTime,
}DosageDetailType;

typedef enum : NSUInteger {
    
    eAddNewDose,
    eAddNewTimes
}AddNewType;


typedef enum : NSUInteger {
    
    eDoseChange,
    eUntilDose
}AddConditionDetailType;


typedef enum : NSUInteger {
    
    eSchedulingFrequency,
    eDailyCount,
    eWeeklyCount,
    eWeekDays,
    eMonthlyCount,
    eYearlyCount,
    eMonthEachCount,
    eMonthOnTheCount,
    eYearEachCount,
    eYearOnTheCount,
    eDayCount,
    eHoursCount,
    eMinutesCount,
    eReducingIncreasingType
}PickerType;



//typedef enum : NSUInteger {
//
//    oneThirdWindow,
//    halfWindow,
//    twoThirdWindow,
//    fullWindow
//} CurrentWindowState;

#endif
