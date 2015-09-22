//
//  DCConstants.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCAppDelegate.h"

#define SHARED_APPDELEGATE (DCAppDelegate *)[[UIApplication sharedApplication] delegate]

//TODO: added for demo purpose and comment out this, instead of deleting:
//#define kDCBaseUrl @"http://interfacetest.cloudapp.net/api"
#define kDCBaseUrl @"http://openapidemo.cloudapp.net/api" // demo URL

//#define AUTHORIZE_URL           @"https://interfacetest.cloudapp.net/ehc-identity/identity/connect/authorize"
#define AUTHORIZE_URL      @"https://openapidemo.cloudapp.net/ehc-identity/identity/connect/authorize"

#define LOCALHOST_PATH @"http://localhost:8080/api"

// user role
#define ROLE_DOCTOR @"doctor"
#define ROLE_NURSE @"nurse"

#ifndef DrugChart_DCConstants_h
#define DrugChart_DCConstants_h

//string values
#define EMPTY_STRING @""
#define COMMA @","
#define DOT @"."
#define COLON @":"

//web requests

#define GET_HTTP_REQUEST @"GET"

//content offset
#define MEDICINE_NAME_TEXTVIEW_EDGE_INSETS  UIEdgeInsetsMake(10, 10, 10, 30)

//Button Titles
#define OK_BUTTON_TITLE     @"OK"
#define BACK_BUTTON_TITLE   @"Back"
#define CANCEL_BUTTON_TITLE @"Cancel"
#define REMOVE_BUTTON_TITLE @"Remove"
#define ORDER_BUTTON_TITLE  @"Order"
#define ADD_BUTTON_TITLE    @"Add"
#define DONE_BUTTON_TITLE   @"Done"
#define OVERRIDE_BUTTON_TITLE @"Override"
#define DONOTUSE_BUTTON_TITLE @"Do not use"
#define NO_BUTTON_TITLE     @"No"
#define YES_BUTTON_TITLE    @"Yes"

//Button images

#define PLUS_IMAGE @"Plus"
#define ADMINISTRATING_TIME_UNSELECTED @"AdministratingTimeUnselected"
#define ADMINISTRATING_TIME_SELECTED @"AdministratingTimeSelected"

//images

#define SEVERE_WARNING_IMAGE @"SevereWarningSympol"
#define MILD_WARNING_IMAGE @"WarningSympol"
#define TICK_IMAGE @"AddNewTick"

// Storyboard names
#define MAIN_STORYBOARD @"Main"
#define ADMINISTER_STORYBOARD @"Administer"
#define ADD_MEDICATION_STORYBOARD @"AddMedication"
#define AUTHORIZATION_STORYBOARD @"Authorization"
#define PRESCRIBER_DETAILS_STORYBOARD @"PrescriberDetails"
#define ORDERSET_STORYBOARD @"OrderSet"
#define PATIENT_LIST_STORYBOARD @"PatientList"

// Storyboard Ids
#define PATIENT_LIST_VIEW_CONTROLLER @"patientsListViewController"
#define CALENDAR_VIEW_CONTROLLER_STORYBOARD_ID @"CalendarChartViewController"
#define MEDICATION_VIEW_CONTROLLER_STORYBOARD_ID @"MedicationViewController"
#define PRESCRIBER_VIEW_CONTROLLER_STORYBOARD_ID @"PrescriberViewController"
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
#define PATIENT_LIST_COLLECTION_STORYBOARD_ID @"patientListCollectionView"
#define MEDICATION_LIST_STORYBOARD_ID @"MedicationListView"
#define ADD_MEDICATION_DETAIL_STORYBOARD_ID @"AddMedicationDetail"
#define WARNINGS_LIST_STORYBOARD_ID @"WarningsList"
#define CALENDAR_SLOT_DETAIL_STORYBOARD_ID @"CalendarDetail"
#define ADMINISTER_STORYBOARD_ID @"AdministerViewController"

//Nib files
#define WARNINGS_HEADER_VIEW_NIB @"DCWarningsHeaderView"

// Segue Ids
#define SHOW_PATIENT_LIST @"showPatientList"
#define SHOW_PATIENT_LIST_FROM_INITIAL_VIEW @"PatientListFromInitialView" 
#define SHOW_PATIENT_MEDICATION_HOME @"showPatientMedicationHomeView"
#define ADMINISTERED_BY_POPOVER @"administerPopOver"
#define CHECKED_BY_POPOVER @"checkedByPopOver"
#define SHOW_WARDS_LIST @"showWardsList"
#define WARDS_SEGUE_ID @"WardsSegue"
#define GOTO_PATIENT_LIST @"goToSelectedPatientList"

// color values
#define NAVIGATION_BAR_COLOR [UIColor colorWithRed:13.0/255.0 green:119.0/255.0  blue:200.0/255.0  alpha:1.0]
#define BORDER_COLOR [UIColor getColorForHexString:@"#c4d3d5"]
#define LIGHT_GRAY_BORDER_COLOR  [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor

// table cell reuse identifier
#define PATIENT_CELL_IDENTIFIER @"patientCell"
#define MEDICATION_CELL_IDENTIFIER @"medicationCell"
#define CALENDAR_CELL_IDENTIFIER @"calendarCell"
#define FILTER_CELL_IDENTIFIER   @"FilterCell"
#define MEDICINE_FILTER_CELL_IDENTIFIER @"MedicineFilterCell"
#define ALLERGY_CELL_IDENTIFIER @"AllergyCell"
#define ALLERGY_NOTIFICATION_CELL_IDENTIFIER @"AllergyCellID"
#define ADD_MEDICATION_CELL_IDENTIFIER @"AddMedicationCell"
#define ADD_NEW_DOSAGE_CELL_IDENTIFIER @"AddNewDosageCell"
#define PATIENT_ALERTS_ALLERGY_CELL_IDENTIFIER @"PatientAlertsAllergyCell"
#define MEDICINE_NAME_CELL_IDENTIFIER @"MedicineNameCell"
#define ORDER_CELL_IDENTIFIER @"OrderSetCell"
#define AUTO_SEARCH_CELL_IDENTIFIER @"AutoSearchCell"
#define WARNINGS_CELL_IDENTIFIER @"WarningsCellIdentifier"
#define WARNINGS_POPOVER_CELL_IDENTIFIER @"WarningsPopoverCell"
#define SORT_CELL_IDENTIFIER @"SortTableCell"
#define PATIENT_COLLECTION_IDENTIFIER @"PatientCollectionViewCell"
#define PATIENT_LIST_HEADER_IDENTIFIER @"PatientListHeaderView"
#define ADD_MEDICATION_CELL_IDENTIFIER @"AddMedicationCell"
#define MEDICATION_LIST_CELL_IDENTIFIER @"MedicationListCell"
#define ADD_MEDICATION_CONTENT_CELL @"AddMedicationContentCell"
#define INSTRUCTIONS_CELL_IDENTIFIER @"InstructionsCell"
#define ADD_MEDICATION_DETAIL_CELL_IDENTIFIER @"DetailCell"
#define DATE_PICKER_CELL_IDENTIFIER @"pickercell"
#define ADD_DOSAGE_CELL_IDENTIFIER @"AddDosageCell"
#define NO_DATE_CELL_IDENTIFIER @"NoEndDateCell"
#define WARNINGS_CELL_ID @"WarningsCell"
#define OVERRIDE_REASON_CELL_ID @"OverrideReasonCell"

// title for views
#define INPATIENT_TITLE @"In Patients"
#define ADD_MEDICATION @"Add Medication"
#define EDIT_MEDICATION @"Edit Medication"
#define ORDER_SET @"Order Set"

//temp cookie value

#define USER_ROLE_COOKIE @"eyJVc2VySW5Sb2xlSWQiOjI0ODgsIlVzZXJJblJvbGVSb2xlUHJvZmlsZUlkIjoxNjg2LCJSb2xlUHJvZmlsZU5hbWUiOiJDbGluaWNhbCBQcmFjdGl0aW9uZXIgQWNjZXNzIFJvbGUiLCJEZXNjcmlwdGlvbiI6IkEgZ2VuZXJpYyBjbGluaWNhbCByb2xlIHRvIGNvdmVyIGFsbCBkb2N0b3JzIGFuZCBzdGFmZiB1bmRlcnRha2luZyBzaW1pbGFyIGFjdGl2aXRpZXMgd2l0aCBoZWFsdGggcmVjb3JkcyAoc3VjaCBhcyBOdXJzZSBQcmFjdGlvbmVycykgd29ya2luZyBpbiBwcmltYXJ5LCBzZWNvbmRhcnkgYW5kIGNvbW11bml0eSBjYXJlLiBUaGUgam9iIHJvbGUgYmFzZWxpbmUgYWN0aXZpdGllcyBjYW4gYmUgZXh0ZW5kZWQgYnkgYWRkaXRpb25hbCBBcmVhIG9mIFdvcmsgYmFzZWxpbmUgYWN0aXZpdGllcy4ifQ=="


//hexcodes

#define PLACEHOLDER_COLOR_HEX @"#797979"

// time zone
#define GMT @"GMT"

//file types
#define PLIST @"plist"

//saved pin

#define SAVED_PIN @"1234"

//notification keys

#define kEarlyAdministrationNotification        @"EarlyAdministration"
#define kNetworkAvailable                       @"NetworkAvailable"

//date

#define DEFAULT_DATE_FORMAT     @"yyyy-MM-dd hh:mm:ss z"
#define SHORT_DATE_FORMAT       @"yyyy-MM-dd"
#define DATE_FORMAT_RANGE       @"yyyy-MM-dd HH:mm"
#define DATE_FORMAT_WITH_DAY    @"EE, LLLL d, HH:mm"
#define DATE_FORMAT_START_DATE  @"dd-MMM-yyyy HH:mm"
#define DOB_DATE_FORMAT         @"YYYY-mm-dd"
#define BIRTH_DATE_FORMAT       @"dd MMM yyyy"
#define LONG_DATE_FORMAT        @"yyyy-MM-dd HH:mm:ss"

#define SERVER_DATE_FORMAT       @"yyyy-MM-dd'T'hh:mm:ss"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)

// medication category
#define REGULAR_MEDICATION @"Regular"
#define ONCE_MEDICATION @"Once"
#define WHEN_REQUIRED_VALUE @"When Required"
#define WHEN_REQUIRED @"WhenRequired"

#define MEDICATION_IN_SIX_HOURS 21600
#define ADMINISTER_IN_ONE_HOUR 60*60

//medication status
#define OMITTED @"Omitted"
#define REFUSED @"Refused"
#define IS_GIVEN @"Administered"
#define YET_TO_GIVE @"notGiven"
#define TO_GIVE @"toGive"
#define SELF_ADMINISTERED @"selfAdministered"

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

//Prescriber filter criterias

#define DRUG_TYPE           @"Drug Type"
#define START_DATE_ORDER    @"Start Date"
#define ALPHABETICAL_ORDER  @"Alphabetical Order"

//image nameds
#define LOGOUT_IMAGE @"Logout"
#define NOTIFICATION_IMAGE @"Notification"
#define SETTINGS_IMAGE @"Settings"
#define ALLERGY_IMAGE @"Allergy"
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


//webservice error codes

#define WEBSERVICE_UNAVAILABLE 101
#define NETWORK_NOT_REACHABLE -1001

//Warnings

#define CONTRAINDICATION @"Contraindication"
#define MILD_KEY @"M"
#define SEVERE_KEY @"H"
#define ALLERGY_INTOLERANCE @"AllergyIntolerance"
#define ENTRY_KEY @"entry"
#define RESOURCE_KEY @"resource"


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

#endif
