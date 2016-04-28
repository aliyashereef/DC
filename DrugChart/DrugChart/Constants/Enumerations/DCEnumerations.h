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
    
    eDetailSchedulingType,
    eDetailSpecificTimesRepeatType,
    eDetailIntervalRepeatFrequency
    
} SchedulingDetailType;

typedef enum :NSUInteger {
    eNotes,
    eReason
}NotesType;

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
    eAddNewTimes,
}AddNewType;

typedef enum : NSUInteger {
    
    eAddIntegerValue,
    eAddValueWithUnit,
}ValueType;

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
    eReducingIncreasingType,
}PickerType;

typedef enum : NSUInteger {
    
    eUnit,
    eFlowDuration,
    eRateStarting,
    eRateNormal
}InfusionPickerType;

typedef enum : NSUInteger {
    eAddIntervention,
    eResolveIntervention
}InterventionType;

typedef enum : NSUInteger {
    eClinicalCheck,
    eIntervention,
    eUpdatePodStatus,
    eSupplyRequest
}PharmacistBarButtonActionType;

typedef enum : NSUInteger {
    eDrugChart,
    ePharmacist
}SummaryType;

#endif
