//
//  PrescriberMedicationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import "PrescriberMedicationViewController.h"
#import "DrugChart-Swift.h"
#import "DCCalendarNavigationTitleView.h"
#import "DCAddMedicationInitialViewController.h"
#import "DCAlertsAllergyPopOverViewController.h"
#import "DCSortTableViewController.h"
#import "DCPatientAlert.h"
#import "DCPatientAllergy.h"

#import "DCMedicationSchedulesWebService.h"
#import "DCMedicationScheduleDetails.h"

#define ALERT_BUTTON_VIEW_WIDTH     107.0f
#define ALLERGIES_BUTTON_VEW_WIDTH  107.0f
#define CELL_PADDING 18

#define ALERTS_ALLERGIES_ICON @"AlertsIcon"
#define SORT_KEY_MEDICINE_NAME @"name"
#define SORT_KEY_MEDICINE_START_DATE @"startDate"

typedef enum : NSUInteger {
    kSortDrugType,
    kSortDrugStartDate,
    kSortDrugName
} SortType;

@interface PrescriberMedicationViewController () <DCAddMedicationViewControllerDelegate,PrescriberListDelegate ,AdministrationDelegate>{
    
    NSMutableArray *currentWeekDatesArray;
    IBOutlet UIView *calendarDaysDisplayView;
    IBOutlet UIView *todayString;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UILabel *noMedicationsAvailableLabel;
    IBOutlet UIView *calendarTopHolderView;
    IBOutlet UIView *medicationListHolderView;
    IBOutlet UILabel *monthYearLabel;

    NSDate *firstDisplayDate;
    UIBarButtonItem *addButton;
    NSMutableArray *alertsArray;
    NSMutableArray *allergiesArray;
    NSString *selectedSortType;
    NSMutableArray *displayMedicationListArray;
    NSMutableArray *rowMedicationSlotsArray;
    CGFloat slotWidth;
    BOOL discontinuedMedicationShown;
    SortType sortType;
    
    DCPrescriberMedicationListViewController *prescriberMedicationListViewController;
    DCCalendarDateDisplayViewController *calendarDateDisplayViewController;
}

@end

@implementation PrescriberMedicationViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    displayMedicationListArray = [[NSMutableArray alloc] init];
    currentWeekDatesArray = [[NSMutableArray alloc] init];
    rowMedicationSlotsArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addCustomTitleViewToNavigationBar];
    [self setCurrentWeekDatesArrayFromToday];
    [self populateMonthYearLabel];
    [self addAddMedicationButtonToNavigationBar];
    [self hideCalendarTopPortion];
    [self fillPrescriberMedicationDetailsInCalendarView];
    [self addTopDatePortionInCalendar];
    [self obtainReferencesToChildViewControllersAddedFromStoryBoard];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prescriberTableViewPannedWithTranslationParameters:(CGFloat )xPoint
                                                 xVelocity:(CGFloat)xVelocity
                                                 panEnded:(BOOL)panEnded {
    
    [calendarDateDisplayViewController translateCalendarContainerViewsForTranslationParameters:xPoint withXVelocity:xVelocity panEndedValue:panEnded];
}

- (void)todayActionForCalendarTop {
    
    [calendarDateDisplayViewController todayActionForCalendarTop];
}

#pragma mark - Sub views addition

//TODO: we need to move this from the administer SB to PrescriberDetails SB.
// And thus load it directly from IB and avoid this method.
- (void)addTopDatePortionInCalendar {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    calendarDateDisplayViewController = [administerStoryboard instantiateViewControllerWithIdentifier:@"CalendarDateDisplayView"];
    calendarDateDisplayViewController.currentWeekDateArray = currentWeekDatesArray;
    [calendarDaysDisplayView addSubview:calendarDateDisplayViewController.view];
}

- (void)addAddMedicationButtonToNavigationBar {
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedicationButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

#pragma mark - Private methods

- (void)setCurrentWeekDatesArrayFromToday {
    
    firstDisplayDate = [DCDateUtility getInitialDateForCalendarDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]
                                                        withAdderValue:-7];
    currentWeekDatesArray = [DCDateUtility getFiveDaysOfWeekFromDate:firstDisplayDate];
}

- (void)populateMonthYearLabel {
    
    //populate month year label
    NSString *mothYearDisplayString = [DCDateUtility getMonthNameAndYearForWeekDatesArray:currentWeekDatesArray];
    NSAttributedString *monthYearString = [DCUtility getMonthYearAttributedStringForDisplayString:mothYearDisplayString withInitialMonthLength:0];
    monthYearLabel.attributedText = monthYearString;
}

- (void)calculateCalendarSlotWidth {
    
    //calculate calendar slot width
    slotWidth = ([DCUtility getMainWindowSize].width - 300)/5;
}

// Not needed for now, since the childviewcontroller is added from IB.
- (void)addMedicationListChildViewController {
    
    if (!prescriberMedicationListViewController) {
        UIStoryboard *prescriberStoryBoard = [UIStoryboard storyboardWithName:PRESCRIBER_DETAILS_STORYBOARD bundle:nil];
        prescriberMedicationListViewController = [prescriberStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_LIST_SBID];
        [self addChildViewController:prescriberMedicationListViewController];
        prescriberMedicationListViewController.view.frame = medicationListHolderView.frame;
        prescriberMedicationListViewController.delegate = self;
        [self.view addSubview:prescriberMedicationListViewController.view];
    }
    [prescriberMedicationListViewController didMoveToParentViewController:self];
}

// Make the API call to fetch the medicationschedules for a patient.
// this details are then used to create the medication list and the corresponding
// administration data within the calendar.
- (void)fillPrescriberMedicationDetailsInCalendarView {

    if ([DCAPPDELEGATE isNetworkReachable]) {
        if (_patient.medicationListArray) {
            _patient.medicationListArray = nil;
        }
        [self fetchMedicationListForPatient];
    }
}

// from the child view controllers array we obtain the instance PrescriberMedicationListViewController.
// This instance is needed to use inside the class.
- (void)obtainReferencesToChildViewControllersAddedFromStoryBoard {
    
    if ([self.childViewControllers count] > 0) {
        for (UIViewController *viewController in self.childViewControllers) {
            if ([viewController isKindOfClass:[DCPrescriberMedicationListViewController class]]) {
                prescriberMedicationListViewController = (DCPrescriberMedicationListViewController *)viewController;
                prescriberMedicationListViewController.delegate = self;
            }
        }
    }
}

- (void)getDisplayMedicationListArray {
    if (discontinuedMedicationShown) {
        displayMedicationListArray = (NSMutableArray *)_patient.medicationListArray;
    }
    else {
        NSString *predicateString = @"isActive == YES";
        NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
        displayMedicationListArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
    }
}

// If the alerts or allergy array count is zero, prefill the array with the default
// no alerts/allergies to display statement
- (void) prefillAllergyAndAlertsArrays{
    
    if (alertsArray.count == 0) {
        DCPatientAlert *patientAlert = [[DCPatientAlert alloc] init];
        patientAlert.alertText = NSLocalizedString(@"NO_ALERTS", @"");
        [alertsArray addObject:patientAlert];
    }
    if (allergiesArray.count == 0) {
        DCPatientAllergy *patientAllergy = [[DCPatientAllergy alloc] init];
        patientAllergy.reaction = NSLocalizedString(@"NO_ALLERGIES", @"");
        [allergiesArray addObject:patientAllergy];
    }
}

//Celendar top portion is hidden initially, which has to be updated after reload
- (void)hideCalendarTopPortion {
    
    [calendarDaysDisplayView setHidden:YES];
    [calendarTopHolderView setHidden:YES];
}


// fill in values to the allergy and alerts arrays.
- (void)configureAlertsAndAllergiesArrayForDisplay {
    
    alertsArray = self.patient.patientsAlertsArray;
    allergiesArray = self.patient.patientsAlergiesArray;
}

#pragma mark - API fetch methods

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    NSDate *startDate = [currentWeekDatesArray objectAtIndex:0];
    NSString *startDateString = [DCDateUtility convertDate:startDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    NSDate *endDate = [currentWeekDatesArray lastObject];
    NSString *endDateString = [DCDateUtility convertDate:endDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId fromStartDate:startDateString toEndDate:endDateString withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationsList];
        // if FetchTypeInitial
        for (NSDictionary *medicationDetails in medicationArray) {
            @autoreleasepool {
                DCMedicationScheduleDetails *medicationScheduleDetails = [[DCMedicationScheduleDetails alloc] initWithMedicationScheduleDictionary:medicationDetails forWeekStartDate:startDate weekEndDate:endDate];
                if (medicationScheduleDetails) {
                    [medicationListArray addObject:medicationScheduleDetails];
                }
            }
        }
        // else
        // get the DCMedicationScheduleDetails from the medicationArray,
        // then simply call the update method to update the time chart.
        completionHandler(medicationListArray, nil);
    }];
}

- (void)fetchMedicationListForPatientWithFetchType {
    
    typedef enum : NSUInteger {
        FetchTypeInitial,
        FetchTypePrevious,
        FetchTypeNext,
    } DCFetchType;
    
    // Initial, the same method.
    //
}

- (void)fetchMedicationListForPatient {
    
    [activityIndicatorView startAnimating];
    [self.view bringSubviewToFront:activityIndicatorView];
    [noMedicationsAvailableLabel setHidden:YES];
    [self fetchMedicationListForPatientId:self.patient.patientId
                    withCompletionHandler:^(NSArray *result, NSError *error) {
                        if (!error) {
                            _patient.medicationListArray = result;
                            [self configureAlertsAndAllergiesArrayForDisplay];
                            [self addAlertsAndAllergyBarButtonToNavigationBar];
                            [self getDisplayMedicationListArray];
                            if ([displayMedicationListArray count] > 0) {
                                if (prescriberMedicationListViewController) {
                                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                                    prescriberMedicationListViewController.patientId = self.patient.patientId;
                                    prescriberMedicationListViewController.currentWeekDatesArray = currentWeekDatesArray;
                                }
                                [medicationListHolderView setHidden:NO];
                                [calendarDaysDisplayView setHidden:NO];
                                [calendarTopHolderView setHidden:NO];
                            }
                            else {
                                if ([_patient.medicationListArray count] == 0) {
                                    noMedicationsAvailableLabel.text = @"No medications available";
                                }
                                else {
                                    if ([displayMedicationListArray count] == 0) {
                                        noMedicationsAvailableLabel.text = @"No active medications available";
                                    }
                                }
                                [noMedicationsAvailableLabel setHidden:NO];
                            }
                        }
                        else {
                            if (error.code == NETWORK_NOT_REACHABLE) {
                                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                                    message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
                            } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
                            }
                            else {
                                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"MEDICATION_SCHEDULE_ERROR", @"")];
                            }
                        }
                        [activityIndicatorView stopAnimating];
                    }];
}

#pragma mark - Display sort methods

- (void)sortPrescriberMedicationList {
    
    NSString *sortKey;
    if (sortType == kSortDrugName) {
        sortKey = SORT_KEY_MEDICINE_NAME;
    }
    else if (sortType == kSortDrugStartDate) {
        sortKey = SORT_KEY_MEDICINE_START_DATE;
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    NSArray *descriptorArray = @[sortDescriptor];
    NSMutableArray *sortedMedicationArray = [[NSMutableArray alloc] initWithArray:[displayMedicationListArray sortedArrayUsingDescriptors:descriptorArray]];
    displayMedicationListArray = sortedMedicationArray;
}

- (void)sortMedicationListSelectionChanged:(NSInteger)currentSelection {
    
    sortType = kSortDrugType;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (currentSelection == 1) {
            sortType = kSortDrugStartDate;
            [self sortPrescriberMedicationList];
        }
        else if (currentSelection == 2) {
            sortType = kSortDrugName;
            [self sortPrescriberMedicationList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([displayMedicationListArray count] > 0) {
                if (prescriberMedicationListViewController) {
                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

- (void)sortCalendarViewBasedOnCriteria:(NSString *)criteriaString {
    
    sortType = kSortDrugType;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([criteriaString isEqualToString:INCLUDE_DISCONTINUED]) {
            [self includeDiscontinuedMedications];
            
        }
        if ([criteriaString isEqualToString:START_DATE_ORDER]) {
            sortType = kSortDrugStartDate;
            [self sortPrescriberMedicationList];
        }
        else if ([criteriaString isEqualToString:ALPHABETICAL_ORDER]) {
            sortType = kSortDrugName;
            [self sortPrescriberMedicationList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([displayMedicationListArray count] > 0) {
                if (prescriberMedicationListViewController) {
                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

- (void)includeDiscontinuedMedications {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (discontinuedMedicationShown) {
            discontinuedMedicationShown = NO;
            [self getDisplayMedicationListArray];
        } else {
            discontinuedMedicationShown = YES;
            [self getDisplayMedicationListArray];
            if (sortType != kSortDrugType) {
                [self sortPrescriberMedicationList];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([displayMedicationListArray count] > 0) {
                if (prescriberMedicationListViewController) {
                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

#pragma mark - Navigation title, buttons and actions

// A custom view is loaded as the title for the prescriber screen.
- (void)addCustomTitleViewToNavigationBar {
    
    DCCalendarNavigationTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCCalendarNavigationTitleView class]) owner:self options:nil] objectAtIndex:0];
    [titleView populateViewWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:_patient.dob age:_patient.age
     ];
    self.navigationItem.titleView = titleView;
}

//Add medication popover presentedon tapping the + bar button.
- (IBAction)addMedicationButtonPressed:(id)sender {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                                      bundle: nil];
    DCAddMedicationInitialViewController *addMedicationViewController =
    [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_POPOVER_SB_ID];
    addMedicationViewController.patient = self.patient;
    addMedicationViewController.delegate = self;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:addMedicationViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:navigationController animated:YES completion:nil];
    UIPopoverPresentationController *presentationController =
    [navigationController popoverPresentationController];
    presentationController.delegate = addMedicationViewController;
    presentationController.permittedArrowDirections =
    UIPopoverArrowDirectionAny;
    presentationController.sourceView = self.view;
    presentationController.barButtonItem = (UIBarButtonItem *)sender;
}

// when press the alerts and allergies notification button
// show the popover with segmented control to switch between alerts and allergies.
- (IBAction)allergiesAndAlertsButtonTapped:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCAlertsAllergyPopOverViewController *patientAlertsAllergyViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:PATIENTS_ALERTS_ALLERGY_VIEW_SB_ID];
    // configuring the alerts and allergies arrays to be shown.
    [self prefillAllergyAndAlertsArrays];
    patientAlertsAllergyViewController.patientsAlertsArray = alertsArray;
    patientAlertsAllergyViewController.patientsAllergyArray = allergiesArray;
    // Instatntiating the navigation controller to present the popover with preferred content size of the poppver.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:patientAlertsAllergyViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    // Calculating the height for popover.
    CGFloat popOverHeight = [patientAlertsAllergyViewController getAllergyAndAlertDisplayTableViewHeightForContent:alertsArray];
    navigationController.preferredContentSize = CGSizeMake(ALERT_ALLERGY_CELL_WIDTH, popOverHeight+ CELL_PADDING );
    [self presentViewController:navigationController animated:YES completion:nil];
    // Presenting the popover presentation controller on the navigation controller.
    UIPopoverPresentationController *alertsPopOverController = [navigationController popoverPresentationController];
    alertsPopOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    alertsPopOverController.sourceView = self.view;
    alertsPopOverController.barButtonItem = (UIBarButtonItem *)sender;
}

- (void)addAlertsAndAllergyBarButtonToNavigationBar {
    
    UIBarButtonItem *alertsAndAllergiesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ALERTS_ALLERGIES_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(allergiesAndAlertsButtonTapped:)];
    if ([allergiesArray count] > 0 || [alertsArray count] > 0) {
        self.navigationItem.rightBarButtonItems = @[addButton, alertsAndAllergiesButton];
    } else {
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (IBAction)sortButtonPressed:(id)sender {
    
    //display sort options in a pop over controller,
    //showDiscontinuedMedications denotes if discontinued medications are to be shown
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle: nil];
    UIPopoverController *popOverController;
    DCSortTableViewController *sortViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SORT_VIEWCONTROLLER_STORYBOARD_ID];
    sortViewController.sortView = eCalendarView;
    sortViewController.previousSelectedCategory = selectedSortType;
    if (discontinuedMedicationShown) {
        sortViewController.showDiscontinuedMedications = YES;
    }
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:sortViewController];
    popOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    popOverController.popoverContentSize = CGSizeMake(305, 200);
    [popOverController presentPopoverFromBarButtonItem:sender
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    sortViewController.criteria = ^ (NSString * type) {
        if (![type isEqualToString:INCLUDE_DISCONTINUED]) {
            selectedSortType =  type;
        }
        [self sortCalendarViewBasedOnCriteria:type];
        [popOverController dismissPopoverAnimated:YES];
    };
}

- (IBAction)todayButtonPressed:(id)sender {
    
    if (prescriberMedicationListViewController) {
        [prescriberMedicationListViewController todayButtonClicked];
    }
}

#pragma mark - Public methods implementation.

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    DCCalendarSlotDetailViewController *detailViewController = [administerStoryboard instantiateViewControllerWithIdentifier:CALENDAR_SLOT_DETAIL_STORYBOARD_ID];
    if ([displayMedicationListArray count] > 0) {
        DCMedicationScheduleDetails *medicationList =  [displayMedicationListArray objectAtIndex:indexPath.item];
        detailViewController.scheduleId = medicationList.scheduleId;
        detailViewController.medicationDetails = medicationList;
    }
    DCSwiftObjCNavigationHelper *helper = [[DCSwiftObjCNavigationHelper alloc] init];
    helper.delegate = self;
    detailViewController.helper = helper;
    if ([[medicationSLotsDictionary allKeys] containsObject:@"timeSlots"]) {
        NSMutableArray *slotsArray = [[NSMutableArray alloc] initWithArray:[medicationSLotsDictionary valueForKey:@"timeSlots"]];
        if ([slotsArray count] > 0) {
            detailViewController.medicationSlotsArray = slotsArray;
        }
    }
    detailViewController.weekDate = date;
    detailViewController.patientId = self.patient.patientId;
    detailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:detailViewController animated:YES completion:nil];
}

- (void)modifyStartDayAndWeekDates:(BOOL)isNextWeek {
    
    if (isNextWeek) {
        firstDisplayDate = [DCDateUtility getInitialDateForCalendarDisplay:firstDisplayDate withAdderValue:5];
        currentWeekDatesArray = [DCDateUtility getFiveDaysOfWeekFromDate:firstDisplayDate];
    }
    else {
        firstDisplayDate = [DCDateUtility getInitialDateForCalendarDisplay:firstDisplayDate withAdderValue:-5];
        currentWeekDatesArray = [DCDateUtility getFiveDaysOfWeekFromDate:firstDisplayDate];
    }
}

- (void)modifyWeekDatesInCalendarTopPortion {
    
    if (calendarDateDisplayViewController) {
        calendarDateDisplayViewController.currentWeekDateArray = currentWeekDatesArray;
    }
}

- (void)reloadCalendarTopPortion {
    if (calendarDateDisplayViewController) {
        [calendarDateDisplayViewController displayDatesInView];
    }
    [self populateMonthYearLabel];
}

- (void)reloadAndUpdatePrescriberMedicationDetails {
    if (prescriberMedicationListViewController) {
        prescriberMedicationListViewController.currentWeekDatesArray = currentWeekDatesArray;
        [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
    }
}

#pragma mark - DCAddMedicationViewControllerDelegate implementation

// after adding a medication the latest drug schedules are fetched and displayed to the user.
- (void)addedNewMedicationForPatient {
    [self fetchMedicationListForPatient];
}

// This method refresh the medication list when an mediation gets deleted.
- (void) refreshMedicationList {
    [self fetchMedicationListForPatient];
}

- (void)reloadPrescriberMedicationList {
    [self fetchMedicationListForPatient];
}

#pragma mark - Methods needed.

- (void)populateMedicationWeekDaysForDisplayInCalendar {
    
    // here we need to add the methods to populate the values
    
}

@end
