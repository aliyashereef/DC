//
//  DCConstants.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCAppDelegate.h"

#define SHARED_APPDELEGATE (DCAppDelegate *)[[UIApplication sharedApplication] delegate]

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//TODO: We can change the base url by changing the toggle button in the settings bundle of the app.

#define kDCBaseUrl @"http://interfacetest.cloudapp.net/api"
#define kDCBaseUrl_Demo @"http://openapidemo.cloudapp.net/api" // demo URL


#define kDCBaseVitalSignUrl @"http://emisvitalsigns.cloudapp.net/hub/api"
#define kDCBaseVitalSignUrl_Demo @"http://emisvitalsigns.cloudapp.net/hub/api" // demo URL


#define AUTHORIZE_URL           @"https://interfacetest.cloudapp.net/ehc-identity/identity/connect/authorize"
#define AUTHORIZE_URL_DEMO      @"https://openapidemo.cloudapp.net/ehc-identity/identity/connect/authorize"

#define SETTINGS_TOGGLE_BUTTON_KEY @"enablebaseurl"
#define LOCALHOST_PATH @"http://localhost:8080/api"

// user role
#define ROLE_DOCTOR @"doctor"
#define ROLE_NURSE @"nurse"

#ifndef DrugChart_DCConstants_h
#define DrugChart_DCConstants_h

//string values
#define EMPTY_STRING @""
#define BLANK_TEXT @" - "
#define COMMA @","
#define DOT @"."
#define COLON @":"
#define NONE_TEXT @"None"
#define FIFTEEN_MINUTES 900.0 // In seconds
#define ONE_HOUR 3600.0       // In seconds
#define INTEGER_SET_STRING "0123456789."

//web requests

#define GET_HTTP_REQUEST @"GET"

//content offset
#define MEDICINE_NAME_TEXTVIEW_EDGE_INSETS  UIEdgeInsetsMake(10, 10, 10, 30)

// calendar view width constants

#define CALENDAR_TWO_THIRD_WINDOW_WIDTH 288.0
#define CALENDAR_FULL_WINDOW_WIDTH 580.0
#define TEXT_VIEW_CELL_HEIGHT 90.0
#define ZERO_INT 0
#define NORMAL_CELL_HEIGHT 44.0

//Button Titles
#define OK_BUTTON_TITLE     @"OK"
#define CANCEL_BUTTON_TITLE @"Cancel"
#define REMOVE_BUTTON_TITLE @"Remove"
#define ORDER_BUTTON_TITLE  @"Order"
#define ADD_BUTTON_TITLE    @"Add"
#define DONE_BUTTON_TITLE   @"Done"
#define SAVE_BUTTON_TITLE   @"Save"
#define OVERRIDE_BUTTON_TITLE @"Override"
#define DONOTUSE_BUTTON_TITLE @"Do not use"
#define NO_BUTTON_TITLE     @"No"
#define YES_BUTTON_TITLE    @"Yes"
#define EDIT_BUTTON_TITLE   @"Edit"
#define SELECT_ALL_TITLE    @"Select All"
#define DESELECT_ALL_TITLE  @"Deselect All"
#define REVIEW_TITLE        @"Add Review"
#define MANAGE_SUSPENSION_TITLE @"Manage Suspensions"

//images

#define SEVERE_WARNING_IMAGE @"SevereWarningSympol"
#define MILD_WARNING_IMAGE @"WarningSympol"
#define TICK_IMAGE @"AddNewTick"

// Storyboard names
#define MAIN_STORYBOARD @"Main"
#define ADMINISTER_STORYBOARD @"Administer"
#define PATIENT_MENU_STORYBOARD @"PatientMenu"
#define MEDICATION_HISTORY @"MedicationHistory"
#define ADD_MEDICATION_STORYBOARD @"AddMedication"
#define AUTHORIZATION_STORYBOARD @"Authorization"
#define PRESCRIBER_DETAILS_STORYBOARD @"PrescriberDetails"
#define ONE_THIRD_SCREEN_SB @"OneThirdScreenSizeCalendar"
#define ORDERSET_STORYBOARD @"OrderSet"
#define PATIENT_LIST_STORYBOARD @"PatientList"
#define DOSAGE_STORYBORD @"Dosage"
#define ADMINISTER_GRAPH @"AdministerGraph"
#define SUMMARY_STORYBOARD @"Summary"
#define PHARMACIST_STORYBOARD @"Pharmacist"
#define PHARMACIST_ACTION_STORYBOARD @"PharmacistAction"
#define STOP_MEDICATION @"StopMedication"

// Storyboard Ids
#define PATIENT_LIST_VIEW_CONTROLLER @"patientListingViewController"
#define ERROR_CONTENT_VIEW_CONTROLLER_STORYBOARD_ID @"ErrorPopOverController"
#define PRESCRIBER_FILTER_TABLE_VIEW_CONTROLLER @"PrescriberFilterTableViewController"
#define EARLY_ADMINISTERED_VIEW_CONTROLLER @"EarlyAdministeredViewController"
#define MISSED_ADMINISTER_VIEW_CONTROLLER @"MissedAdministerAlertViewController"
#define ADD_MEDICATION_CONTENT_VIEW_CONTROLLER @"AddMedicationPopOverContentViewController"
#define ADD_MEDICATION_SEVERE_WARNINGS_VIEW_CONTROLLER @"AddMedicationSevereWarningsViewController"
#define SETTINGS_VIEW_STORYBOARD_ID @"SettingsViewController"
#define PATIENTS_ALERTS_ALLERGY_VIEW_SB_ID @"PatientAlertsAllergyViewController"
#define ADD_MEDICATION_POPOVER_SB_ID @"AddMedicationPopOverViewController"
#define SECURITY_PIN_VIEW_CONTROLLER @"SecurityPinViewController"
#define NAMES_LIST_VIEW_STORYBOARD_ID @"NamesListViewController"
#define STATUS_LIST_VIEW_SB_ID @"StatusListViewController"
#define PATIENTS_ALLERGY_VIEW_SB_ID @"PatientAllergyNotificationTableViewController"
#define AUTHORIZATION_VIEW_SB_ID @"AuthorizationViewController"
#define PRESCRIBER_DETAILS_SB_ID @"PrescriberDetailsViewController"
#define DATE_PICKER_VIEW_SB_ID @"DatePickerViewController"
#define OVERRIDE_VIEW_SB_ID @"OverrideViewController"
#define PATIENT_LIST_VC_SB_ID @"patientListViewController"
#define WARDS_GRAPHICAL_DISPLAY_VC_SB_ID @"wardsGraphicalDisplayViewController"
#define ADD_MEDICATION_RIGHT_SB_ID @"AddMedicationRightViewController"
#define ADD_MEDICATION_DETAILS_SB_ID @"AddMedicationDetailsViewController"
#define ORDER_SET_SB_ID @"OrderSetViewController"
#define SERVER_CHANGE_VC_ID @"ServerChangeViewController"
#define SORT_VIEWCONTROLLER_STORYBOARD_ID @"SortTableViewController"
#define PATIENT_MEDICATION_HOME_STORYBOARD_ID @"PatientMedicationHome"
#define MEDICATION_LIST_STORYBOARD_ID @"MedicationListView"
#define ADD_MEDICATION_DETAIL_STORYBOARD_ID @"AddMedicationDetail"
#define WARNINGS_LIST_STORYBOARD_ID @"WarningsList"
#define CALENDAR_SLOT_DETAIL_STORYBOARD_ID @"CalendarDetail"
#define ADMINISTER_SUCCESS_VC_STORYBOARD_ID @"AdministerSuccessViewController"
#define ADMINISTER_FAILURE_VC_STORYBOARD_ID @"AdministerFailureViewController"
#define ADMINISTER_IN_PROGRESS_VC_STORYBOARD_ID @"AdministerProgressViewController"
#define MANAGE_SUSPENSION_VC_SB_ID @"manageSuspensionView"
#define MANAGE_SUSPENSION_FROM_VC_SB_ID @"manageSuspensionFromView"
#define MANAGE_SUSPENSION_UNTIL_VC_SB_ID @"manageSuspensionUntilView"
#define INTERVENTION_DETAILS_EXPANSION_SB_ID @"intervensionDetailsExpansionView"

#define ADMINISTRATION_STATUS_CHANGE_VIEW_CONTROLLER @"AdministerStatusChangeViewController"
#define MEDICATION_STORYBOARD_ID @"MedicationHistory"
#define BNF_STORYBOARD_ID @"BNFViewController"
#define PRESCRIBER_LIST_SBID @"PrescriberMedicationList"
#define PRESCRIBER_LIST_ONE_THIRD_SBID @"PrescriberOneThirdMedicationList"
#define PATIENT_MENU_VIEW_CONTROLLER_SB_ID @"PatientMenuViewController"
#define VITAL_SIGNS_VIEW_CONTROLLER_VIEW_CONTROLLER_SB_ID @"VitalSignViewController"
#define SCHEDULING_DETAIL_STORYBOARD_ID @"SchedulingDetailView"
#define SCHEDULING_INITIAL_STORYBOARD_ID @"SchedulingInitialView"
#define INFUSIONS_STORYBOARD_ID @"InfusionViewController"
#define ADMINISTER_GRAPH_STORYBOARD_ID @"administerGraph"

#define PRESCRIBER_MEDICATION_SBID @"PrescriberMedicationViewControllerSBID"
#define DOSAGE_SELECTION_SBID @"DosageSelection"
#define DOSAGE_DETAIL_SBID @"DosageDetail"
#define DOSAGE_CONDITIONS_SBID @"DosageConditions"
#define ADD_CONDITION_SBID @"AddConditions"
#define ADD_CONDITION_DETAIL_SBID @"AddConditionDetail"
#define ADD_NEW_DOSE_TIME_SBID @"AddNewViewController"
#define DOSAGE_UNIT_SELECTION_SBID @"DosageUnitSelection"
#define WARDS_INFORMATION_SBID @"wardsInformationViewController"
#define ROUTE_STORYBOARD_ID @"RouteViewController"
#define INJECTION_REGION_SB_ID @"InjectionRegionView"
#define ADMINISTRATION_TIMES_SB_ID "AdministrationTimesView"
#define ADD_NEW_VALUE_SBID @"AddNewValueViewController"
#define SINGLE_DOSE_VIEW_STORYBOARD_ID @"SingleDoseViewController"
#define MEDICATION_TYPE_STORYBOARD_ID @"MedicationTypeStoryboardId"
#define MEDICATION_SUMMARY_ADMINISTRATION_HISTORY_SBID @"summaryAdministrationHistoryDisplay"
#define MEDICATION_SUMMARY_REVIEW_HISTORY_SBID @"summaryReviewHistoryDisplay"
#define REVIEW_VIEW_CONTROLLER_SB_ID @"ReviewViewController"
#define PHARMACIST_VIEW_CONTROLLER_SB_ID @"pharmacistViewController"
#define INTERVENTION_ADD_RESOLVE_SB_ID @"addOrResolveInterventionViewController"
#define UPDATE_POD_STATUS_SB_ID @"podStatusViewController"
#define ADMINISTRATING_DOSE_SB_ID @"AdministratingDoseViewController"
#define ACTION_POPOVER_SB_ID @"ActionPopOverView"
#define ONT_THIRD_ACTION_SB_ID @"oneThirdActionView"
#define INTERVENTION_DETAILS_SB_ID @"InterventionDetailsViewController"
#define MORE_BUTTON_ACTION_DISPLAY_SB_ID @"moreButtonActionDisplayView"
#define MANAGE_SUSPENSION_REASON_SB_ID @"manageSuspensionReasonView"

//Nib files
#define WARNINGS_HEADER_VIEW_NIB @"DCWarningsHeaderView"
#define ADMINISTER_HEADER_VIEW_NIB @"DCAdministerTableHeaderView"
#define SCHEDULING_HEADER_VIEW_NIB @"DCSchedulingHeaderView"
#define PROGRESSTIMEVIEW_NIB @"DCProgressTimeView"
// Segue Ids
#define SHOW_PATIENT_LIST @"showPatientList"
#define SHOW_PATIENT_LIST_FROM_INITIAL_VIEW @"PatientListFromInitialView" 
#define SHOW_PATIENT_MEDICATION_HOME @"showPatientMedicationHomeView"
#define ADMINISTERED_BY_POPOVER @"administerPopOver"
#define CHECKED_BY_POPOVER @"checkedByPopOver"
#define SHOW_WARDS_LIST @"showWardsList"
#define WARDS_SEGUE_ID @"WardsSegue"
#define GOTO_PATIENT_LIST @"goToSelectedPatientList"
#define SHOW_PRESCRIBER_MEDICATION @"showPrescriberMedicationView"

// color values
#define NAVIGATION_BAR_COLOR [UIColor colorWithRed:13.0/255.0 green:119.0/255.0  blue:200.0/255.0  alpha:1.0]
#define BORDER_COLOR [UIColor colorForHexString:@"#c4d3d5"]
#define LIGHT_GRAY_BORDER_COLOR  [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor
#define ADMINISTRATING_VIEW_COLOR UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)

// table cell reuse identifier
#define PATIENT_CELL_IDENTIFIER @"patientCell"
#define MEDICATION_CELL_IDENTIFIER @"medicationCell"
#define CALENDAR_CELL_IDENTIFIER @"calendarCell"
#define ALLERGY_CELL_IDENTIFIER @"AllergyCell"
#define ALLERGY_NOTIFICATION_CELL_IDENTIFIER @"AllergyCellID"
#define ADD_MEDICATION_CELL_IDENTIFIER @"AddMedicationCell"
#define ADD_NEW_DOSAGE_CELL_IDENTIFIER @"AddNewDosageCell"
#define PATIENT_ALERTS_ALLERGY_CELL_IDENTIFIER @"PatientAlertsAllergyCell"
#define MEDICINE_NAME_CELL_IDENTIFIER @"MedicineNameCell"
#define ORDER_CELL_IDENTIFIER @"OrderSetCell"
#define AUTO_SEARCH_CELL_IDENTIFIER @"AutoSearchCell"
#define SORT_CELL_IDENTIFIER @"SortTableCell"
#define ADD_MEDICATION_CELL_IDENTIFIER @"AddMedicationCell"
#define MEDICATION_LIST_CELL_IDENTIFIER @"MedicationListCell"
#define ADD_MEDICATION_CONTENT_CELL @"AddMedicationContentCell"
#define INSTRUCTIONS_CELL_IDENTIFIER @"InstructionsCell"
#define ADD_MEDICATION_DETAIL_CELL_IDENTIFIER @"DetailCell"
#define DATE_PICKER_CELL_IDENTIFIER @"pickercell"
#define DATE_STATUS_PICKER_CELL_IDENTIFIER @"datepickercell"
#define ADD_DOSAGE_CELL_IDENTIFIER @"AddDosageCell"
#define WARNINGS_CELL_ID @"WarningsCell"
#define OVERRIDE_REASON_CELL_ID @"OverrideReasonCell"
#define ADMINISTER_CELL_ID @"AdministerCell"
#define ADMINISTER_MEDICATION_DETAILS_CELL_ID @"AdministerMedicationDetailsCell"
#define MEDICATION_CELL_ID @"MedicationDetailsCell"
#define ADMINSTER_MEDICATION_HISTORY_CELL @"AdministerCell"
#define NOTES_AND_REASON_CELL @"NoteAndReasonCell"
#define BATCH_NUMBER_CELL_ID @"BatchNumberCell"
#define NOTES_CELL_ID @"NotesCell"
#define MEDICATION_HISTORY_HEADER_VIEW @"DCMedicationHistoryHeaderView"
#define ADMINISTER_PICKER_CELL_ID @"AdministerPickerCellId"
#define SCHEDULING_CELL_ID @"SchedulingCellId"
#define SCHEDULING_PICKER_CELL_ID @"SchedulingPickerCellId"
#define SCHEDULING_INITIAL_CELL_ID @"SchedulingInitialCellId"
#define SCHEDULING_DESCRIPTION_CELL_ID @"SchedulingDescriptionCell"
#define DOSE_MENU_CELL_ID @"dosagetypecell"
#define DOSE_DROP_DOWN_CELL_ID @"dosageDetailCell"
#define DOSE_DETAIL_CELL_ID @"dosageDetailCell"
#define DOSE_DETAIL_DISPLAY_CELL_ID @"dosageDetailDisplay"
#define ADD_NEW_VALUE_CELL_ID @"newDosageCell"
#define SCHEDULING_TIME_CELL_ID @"SchedulingTimeCell"
#define SCHEDULING_DATE_PICKER_CELL_ID @"SchedulingDatePickerCellId"
#define DOSE_PICKER_DISPLAY_CELL_ID @"pickerViewCell"
#define REQUIRED_DAILY_DOSE_CELL_ID @"requiredDailyDoseCell"
#define ADD_NEW_TIME_CELL_ID @"timePickerViewCell"
#define DOSE_CONDITION_CELL_ID @"conditionMenuCell"
#define DOSE_VALUE_CELL_ID @"doseValueCell"
#define ADD_NEW_DOSE_CELL_ID @"addNewDoseCell"
#define ADD_CONDITION_MENU_CELL_ID @"addConditionMenuCell"
#define ROUTE_CELL_ID @"RouteCell"
#define INFUSIONS_ADMINISTER_AS_CELL_ID @"InfusionsAdministerAsCell"
#define INFUSIONS_CELL_ID @"InfusionCell"
#define SLOW_BOLUS_CELL_ID @"SlowBolusCell"
#define INJECTION_CELL_ID @"InjectionCellId"
#define INFUSION_PICKER_CELL_ID @"InfusionPickerCellId"
#define ADMINISTRATION_TIMES_CELLID @"AdministrationTimesCellId"
#define VALUE_TEXTFIELD_CELL @"newValueTextfieldCell"
#define PICKER_DROP_DOWN_CELL @"pickerDropDownCell"
#define PICKER_CELL @"pickerCell"
#define SINGLE_DOSE_CELL_ID  @"SingleDoseCellId"
#define SINGLE_DOSE_PICKER_CELL_ID @"SingleDosePickerCellId"
#define SINGLE_DOSE_ENTRY_CELL_ID @"SingleDoseEntryCellId"
#define TYPE_CELL_ID @"TypeCellId"
#define REVIEW_SELECTION_CELL_ID @"ReviewSelectionCellId"
#define NEW_REVIEW_CELL_ID @"newReviewCellId"
#define PHARMACIST_CELL_ID @"pharmacistCellId"
#define POD_STATUS_CELL @"podStatusCell"
#define POD_NOTES_CELL_ID @"notesCell"
#define DOSE_DISPLAY_TEXTFIELD @"doseDisplayCell"
#define REASON_TEXT_VIEW @"reasonTextViewCell"
#define ACTION_DISPLAY_CELL @"actionDisplayCell"
#define HISTORY_OPTION_DISPLAY_CELL @"historyCell"
#define MANAGE_SUSPENSION_CELL @"titleCell"
#define REASON_CELL_ID @"reasonCell"

// Week days

#define SUNDAY @"Sunday"
#define MONDAY @"Monday"
#define TUESDAY @"Tuesday"
#define WEDNESDAY @"Wednesday"
#define THURSDAY @"Thursday"
#define FRIDAY @"Friday"
#define SATURDAY @"Saturday"

#define SELECTED_TIME_DISPLAY_CELL_ID @"selectedTimeCell"

// title for views
#define INPATIENT_TITLE @"In Patients"
#define ADD_MEDICATION @"Add Medication"
#define VITAL_SIGNS @"Vital Signs"
#define EDIT_MEDICATION @"Edit Medication"
#define ORDER_SET @"Order Set"

//temp cookie value

#define USER_ROLE_COOKIE @"eyJVc2VySW5Sb2xlSWQiOjI0ODgsIlVzZXJJblJvbGVSb2xlUHJvZmlsZUlkIjoxNjg2LCJSb2xlUHJvZmlsZU5hbWUiOiJDbGluaWNhbCBQcmFjdGl0aW9uZXIgQWNjZXNzIFJvbGUiLCJEZXNjcmlwdGlvbiI6IkEgZ2VuZXJpYyBjbGluaWNhbCByb2xlIHRvIGNvdmVyIGFsbCBkb2N0b3JzIGFuZCBzdGFmZiB1bmRlcnRha2luZyBzaW1pbGFyIGFjdGl2aXRpZXMgd2l0aCBoZWFsdGggcmVjb3JkcyAoc3VjaCBhcyBOdXJzZSBQcmFjdGlvbmVycykgd29ya2luZyBpbiBwcmltYXJ5LCBzZWNvbmRhcnkgYW5kIGNvbW11bml0eSBjYXJlLiBUaGUgam9iIHJvbGUgYmFzZWxpbmUgYWN0aXZpdGllcyBjYW4gYmUgZXh0ZW5kZWQgYnkgYWRkaXRpb25hbCBBcmVhIG9mIFdvcmsgYmFzZWxpbmUgYWN0aXZpdGllcy4ifQ=="


//hexcodes

#define PLACEHOLDER_COLOR_HEX @"#797979"

#define NAVIGATION_BAR_HEIGHT_WITH_STATUS_BAR 64.0f
#define NAVIGATION_BAR_HEIGHT_NO_STATUS_BAR 44.0f


// time zone
#define GMT @"GMT"
#define UTC @"UTC"

//file types
#define PLIST @"plist"

//saved pin

#define SAVED_PIN @"1234"

//notification keys

#define kEarlyAdministrationNotification        @"EarlyAdministration"
#define kNetworkAvailable                       @"NetworkAvailable"
#define kPharmacistTableViewScrollNotification  @"PharmacistTableViewScrollNotification"
#define kDrugChartScrollNotification            @"DrugChartScrollNotification"

//date

#define WEEK_DAY_FORMAT                 @"EEE"
#define DAY_DATE_FORMAT                 @"d"
#define DEFAULT_DATE_FORMAT             @"yyyy-MM-d hh:mm:ss z"
#define SHORT_DATE_FORMAT               @"yyyy-MM-d"
#define DATE_FORMAT_RANGE               @"yyyy-MM-d HH:mm"
#define DATE_FORMAT_WITH_DAY            @"EE, LLLL d, HH:mm"
#define DATE_FORMAT_START_DATE          @"dd-MMM-yyyy HH:mm"
#define DOB_DATE_FORMAT                 @"YYYY-mm-dd"
#define BIRTH_DATE_FORMAT               @"dd MMM yyyy"
#define EXPIRY_DATE_FORMAT               @"d-MMM-yyyy"
#define LONG_DATE_FORMAT                @"yyyy-MM-dd HH:mm:ss"
#define DATE_MONTHNAME_YEAR_FORMAT      @"d LLLL yyyy"
#define ADMINISTER_DATE_TIME_FORMAT     @"d-MMM-yyyy hh:mm a"
#define SERVER_DATE_FORMAT              @"yyyy-MM-dd'T'hh:mm:ss"

// medication category
#define REGULAR_MEDICATION @"Regular"
#define ONCE_MEDICATION @"Once"
#define WHEN_REQUIRED_VALUE @"When Required"
#define WHEN_REQUIRED @"WhenRequired"

// Administration status
#define PENDING @"Pending"
#define ADMINISTER_MEDICATION @"Administer Medication"
#define IN_PROGRESS @"In progress"
#define ENDED @"Ended"
#define STOPED_DUE_TO_PROBLEM @"Stoped due to problem"
#define CONTINUED_AFTER_PROBLEM @"Continued after problem"
#define FLUID_CHANGED @"Fluid changed"
#define PAUSED @"Paused"
#define NOT_ADMINISTRATED_OTHERS @"Not Administered other"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)

#define MEDICATION_IN_SIX_HOURS 21600
#define ADMINISTER_IN_ONE_HOUR 60*60

//medication status
#define OMITTED @"Omitted"
#define REFUSED @"Refused"
#define NOT_ADMINISTRATED @"Not Administered"
#define IS_GIVEN @"Administered"
#define YET_TO_GIVE @"notGiven"
#define TO_GIVE @"toGive"
#define SELF_ADMINISTERED @"selfAdministered"
#define ADMINISTERED @"Administered"
#define STARTED @"Started"

//cell heights
#define CALENDAR_TABLE_CELL_HEIGHT 70.0f
#define ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT 3

#define SEARCH_ENTRY_MIN_LENGTH   3

#define HALF_WIDTH_LIMIT 500.0f

// cell widths

#define ALERT_ALLERGY_CELL_WIDTH 305
//navigation bar height

#define NAVIGATION_BAR_HEIGHT     64.0f

//textview content insets
#define TEXTVIEW_EDGE_INSETS  UIEdgeInsetsMake(10, 10, 10, 10)

//font sizes
#define SYSTEM_FONT_SIZE_FIFTEEN [UIFont systemFontOfSize:15.0f]

// Table section header titles
#define SECTION_HEADER_WHEN_REQUIRED @"When Required"
#define SECTION_HEADER_REGULAR @"Regular"
#define SECTION_HEADER_ONCE @"Once"

// display string
#define WHEN_REQ_DISPLAY_STRING @"When Required"

//others
#define SUCCESS    @"Success"
#define SELF_ADMINISTERED_TITLE @"Self Administered"

//Administer
#define DISPLAY_NAME_KEY @"displayName"
#define IDENTIFIER_KEY @"identifier"

#define MED_DATE @"medDate"
#define MED_DETAILS @"medDetails"

//Prescriber medication view dictionary keys
#define PRESCRIBER_SLOT_VIEW_TAG @"viewTag"
#define PRESCRIBER_TIME_SLOTS @"timeSlots"

#define WELCOME_NURSE @"Hi Julia" //currently hard coded user name
#define WELCOME_DOCTOR @"Hi Shaun"
#define DEFAULT_NURSE_NAME @"Julia Antony"
#define DEFAULT_DOCTOR_NAME @"Shaun O'Hanlon"

#define INACTIVE @"Inactive"
#define CURRENTLY_ACTIVE @"Currently Active"
#define INCLUDE_DISCONTINUED @"Include Discontinued"
#define DISCONTINUED_STRING @"Discontinued"
#define SORT_ACTIVE_FIRST @"Active on Top"

//Prescriber filter criterias

#define DRUG_TYPE           @"Drug Type"
#define START_DATE_ORDER    @"Start Date"
#define ALPHABETICAL_ORDER  @"Alphabetical Order"

//image nameds
#define LOGOUT_IMAGE @"Logout"
#define SETTINGS_IMAGE @"Settings"
#define TOP_LOGO @"EmisTopLogo"

//warning types
#define SEVERE_WARNING @"Severe"
#define MILD_WARNING @"Mild"

//Bed Types

#define BED @"Bed"
#define CHAIR @"Chair"
#define TROLLEY @"Trolley"
#define CUBICLE @"Cubicle"

#define ZERO_CONSTRAINT             0.0f
#define ALPHA_FULL                  1.0
#define ALPHA_PARTIAL               0.6
#define KEYBOARD_ANIMATION_DURATION 0.1

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

//Netherland locale

#define NETHERLANDS_LOCALE       @"NL"


//webservice error codes

#define WEBSERVICE_UNAVAILABLE 101
#define NETWORK_NOT_REACHABLE -1001
#define NOT_CONNECTED_TO_INTERNET -1009
#define REQUEST_CANCELLED -999

//Warnings

#define CONTRAINDICATION @"Contraindication"
#define MILD_KEY @"M"
#define SEVERE_KEY @"H"
#define ALLERGY_INTOLERANCE @"AllergyIntolerance"
#define ENTRY_KEY @"entry"
#define RESOURCE_KEY @"resource"

//Appdelegate

#define HAS_LAUNCHED_ONCE @"HasLaunchedOnce"

//Scheduling

#define SPECIFIC_TIMES @"Specific Times"
#define INTERVAL @"Interval"
#define DAILY @"Daily"
#define WEEKLY @"Weekly"
#define MONTHLY @"Monthly"
#define YEARLY @"Yearly"
#define FREQUENCY @"Frequency"
#define EVERY @"Every"
#define EACH @"Each"
#define ON_THE @"On the..."
#define FIRST @"First"
#define SECOND @"Second"
#define THIRD @"Third"
#define FOURTH @"Fourth"
#define FIFTH @"Fifth"
#define LAST @"Last"
#define DAY @"day"
#define DAYS @"days"
#define WEEK @"week"
#define WEEKS @"weeks"
#define MONTH @"month"
#define MONTHS @"months"
#define YEAR @"year"
#define YEARS @"years"
#define HOUR @"hour"
#define HOURS @"hours"
#define MINUTE @"minute"
#define MINUTES @"minutes"
#define DAYS_TITLE @"Days"
#define HOURS_TITLE @"Hours"
#define MINUTES_TITLE @"Minutes"
#define SINGLE_DAY @"1 day"
#define SINGLE_WEEK @"1 week"
#define SINGLE_MONTH @"1 month"
#define SINGLE_YEAR @"1 year"
#define PREVIEW @"PREVIEW"
#define ONE @"1"
#define ONCE @"once"
#define TWICE @"twice"
#define THRICE @"thrice"

//Roles

#define CLINICAL_PRACTITIONER_ROLE @"Clinical Practitioner Access Role"
#define PRACTICE_MANAGER_ROLE @"Practice Manager Role"
#define NURSE_ACCESS_ROLE @"Nurse Access Role"
#define NURSE_MANAGER_ROLE @"Nurse Manager Access Role"

//userdefault keys
#define kSortType @"SortType"
#define kUserAccessToken @"UserAccessToken"
#define kUserIdToken @"UserIdToken"
#define kRolesProfile @"RolesProfile"

#define PREPARATION_ID @"PreparationId"
#define INSTRUCTIONS @"Instructions"
#define DOSAGE_VALUE @"Dosage"
#define ROUTE_CODE_ID @"RouteCodeId"
#define START_DATE_TIME @"StartDateTime"
#define END_DATE_TIME @"EndDateTime"
#define SCHEDULED_DATE_TIME @"scheduleDateTime"
#define SCHEDULE_TIMES @"ScheduleTimes"

// Routes and route code Ids

#define ORAL @"Oral (PO)"
#define ORAL_ID @"26643006"
#define RECTAL @"Rectal (PR)"
#define RECTAL_ID @"37161004"
#define INTRAVENOUS @"Intravenous (IV)"
#define INTRAVENOUS_ID @"47625008"
#define INTRAMASCULAR @"Intramuscular (IM)"
#define INTRAMASCULAR_ID @"78421000"
#define INTRATHECAL @"Intrathecal (IT)"
#define INTRATHECAL_ID @"72607000"
#define SUBCUTANEOUS @"Subcutaneous"
#define SUBCUTANEOUS_ID @"34206005"

// Images
#define ADMINISTRATION_HISTORY_TICK_IMAGE @"historyTick"

// Administration History Label texts
#define STATUS @"Status"
#define OUTCOME @"Outcome"
#define DOSE @"Dose"
#define STATUS_CHANGE @"Status Change"
#define ADMINISTRATED_BY @"Administered By"
#define DATE_TIME @"Date & Time"
#define CHECKED_BY @"Checked By"
#define BATCHNO_EXPIRY @"Batch No/Expiry Date"
#define NOTES @"Notes"
#define OVERRIDE_ADMINISTRATION @"Override Administration"
#define PREVIOUS_HISTORY @"Previous History"
#define MORE_BUTTON_PRESSED @"moreButtonPressed:"
#define DUMMY_TEXT "Lorem Ipsum is simply dummy text of the printing and types etting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s"
#define DATE @"Date"
#define REASON @"Reason"
#define NEXT_MEDICATION_DATE_KEY @"nextMedicationDate"
#define OVERDUE_KEY @"Overdue"
#define IMMEDIATE_KEY @"Immediate"
#define NOT_IMMEDIATE_KEY @"Not Immediate"
#define BATCH_NUMBER @"Batch Number"
#define EXPIRY_DATE_STRING @"Expiry Date"
#define NA_TEXT @"N/A"
#define DUMMY_DOCTOR @"KENNEDY, Frederick (Dr)"
#define BED_NUMBER @"0"

// Administaration API Labels
#define SCHEDULED_ADMINISTRATION_TIME @"ScheduledDateTime"
#define ACTUAL_ADMINISTRATION_TIME @"ActualAdministrationDateTime"
#define ADMINISTRATION_STATUS @"AdministrationStatus"
#define ADMINISTRATING_USER @"AdministratingUser"
#define ADMINISTRATING_DOSAGE @"AmendedDosage"
#define ADMINISTRATING_BATCH @"batchNumber"
#define ADMINISTRATING_NOTES @"Notes"
#define IS_SELF_ADMINISTERED @"IsSelfAdministered"
#define EXPIRY_DATE @"ExpiryDate"

//Dosage
#define DOSE_FIXED @"Fixed"
#define DOSE_VARIABLE @"Variable"
#define DOSE_REDUCING_INCREASING @"Reducing / Increasing"
#define DOSE_SPLIT_DAILY @"Split daily"
#define DOSE_UNIT_LABEL_TEXT @"Dose Unit"
#define DOSE_UNIT_TITLE @"Unit"
#define DOSE_VALUE_TITLE @"Dose"
#define DOSE_FROM_TITLE @"From"
#define DOSE_TO_TITLE @"To"
#define STARTING_DOSE_TITLE @"Starting Dose"
#define CHANGE_OVER_TITLE @"Change Over"
#define CONDITIONS_TITLE @"Conditions"
#define ADD_NEW_TITLE @"Add New"
#define ADD_CONDITION_TITLE @"Add Condition"
#define EDIT_CONDITION_TITLE @"Edit Condition"
#define REDUCING @"Reducing"
#define INCREASING @"Increasing"
#define ADD_ADMINISTRATION_TIME @"Add Administration Time"
#define ADD_NEW_TIME @"Add New Time"
#define TIME_KEY @"time"
#define UNTIL_TITLE @"Until"
#define SINGLE_DOSE @"Single dose"
#define DOSE_DATE_AND_TIME @"Dose date"

//Administration times
 #define SELECTED_KEY @"selected"

//Infusions
#define BOLUS_INJECTION @"Bolus injection"
#define DURATION_BASED_INFUSION @"Duration based infusion"
#define RATE_BASED_INFUSION @"Rate based infusion"
#define CENTRAL_LINE @"Central line"
#define PERIPHERAL_LINE_ONE @"Peripheral line 1"
#define PERIPHERAL_LINE_TWO @"Peripheral line 2"
#define MG_PER_HOUR @"mg/Hour"
#define MG_PER_MINUTE @"mg/Minute"

#define REVIEW_DUE_IN @"Review Due In"
#define REVIEW_DUE_AT @"Review Due At"

//Pharmacist
#define RESOLVE_INTERVENTION_CELL @"resolutionMainCell"
#define REASON_RESOLVE_TEXTVIEW_CELL @"reasonOrResolutionCell"
#define REASON_TEXT @"Reason"
#define RESOLUTION_TEXT @"Resolution"
#define UPDATE_POD_STATUS @"Update POD Status"
#define ADD_REVIEW "Add Review"
#define SUPPLY_REQUEST @"Supply Request"
#define RESOLVE_INTERVENTION @"Resolve Intervention"
#define CLINICAL_CHECK @"Clinical Check"
#define CLINICAL_REMOVE @"Remove Clinical Check"
#define INTERVENTION_TEXT @"Intervention"
#define ADD_INTERVENTION @"Add Intervention"
#define EDIT_INTERVENTION @"Edit Intervention"
#define PATIENT_OWN_DRUG @"Patient Own Drugs"
#define PATIENT_OWN_DRUG_HOME @"Patient Own Drugs(Home)"
#define PATIENT_OWN_AND_HOME @"Patient Own Drugs & Patient Own Drugs(Home)"
#define ADD_SUPPLY_REQUEST @"Add Supply Request"
#define CANCEL_SUPPLY_REQUEST @"Cancel Supply Request"
#define RESOLVE_INTERVENTION_DETAILS_SINGLE_CELL_ID @"interventionDetailsSingleCell"

#define IS_SCROLLING @"isScrolling"

//Manage Suspension
#define SUSPEND_IMMEDIATELY @"Suspend Immediately"
#define SUSPEND_FROM @"Suspend From"
#define MANUALLY_UNSUSPENDED @"Manually Unsuspended"
#define SPECIFIED_DATE @"Specified Date"
#define SPECIFIED_DOSE @"Specified Doses"
#define OTHER_TEXT @"Other"
#define DETAILS_TEXT @"Details"

#endif
