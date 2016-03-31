//
//  DCPrescriberMedicationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import "DCPrescriberMedicationViewController.h"
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
#define ALERT_POPOVER_INITIAL_HEIGHT 100.0f

#define ALERTS_ALLERGIES_ICON @"Bell"
#define ALERTS_ALLERGIES_WITHCOUNT_ICON @"BellWithNotificationImage"
#define SORT_KEY_MEDICINE_NAME @"name"
#define SORT_KEY_MEDICINE_START_DATE @"startDate"

typedef enum : NSUInteger {
    kSortDrugStartDate,
    kSortDrugName
} SortType;

@interface DCPrescriberMedicationViewController () <DCAddMedicationViewControllerDelegate,PrescriberListDelegate ,AdministrationDelegate>{
    
    NSMutableArray *currentWeekDatesArray;
    IBOutlet UIView *calendarDaysDisplayView;
    IBOutlet NSLayoutConstraint *calendarDateHolderViewTopSpace;
    IBOutlet NSLayoutConstraint *medicationListHolderVIewTopConstraint;
    IBOutlet UIView *todayString;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UILabel *noMedicationsAvailableLabel;
    IBOutlet UIView *calendarTopHolderView;
    IBOutlet UIView *medicationListHolderView;
    IBOutlet UILabel *monthYearLabel;
    UIView *dateView;
    __weak IBOutlet UIView *MonthYearView;
    __weak IBOutlet NSLayoutConstraint *monthYearViewWidthConstraint;
    NSTimer *refreshTimer;
    NSDate *firstDisplayDate;
    UIBarButtonItem *addButton;
    UIButton *warningsButton;
    UILabel *warningCountLabel;
    NSMutableArray *alertsArray;
    NSMutableArray *allergiesArray;
    NSString *selectedSortType;
    NSMutableArray *displayMedicationListArray;
    NSMutableArray *rowMedicationSlotsArray;
    CGFloat slotWidth;
    BOOL discontinuedMedicationShown;
    BOOL isOneThirdMedicationViewShown;
    BOOL windowSizeChanged;
    BOOL fetchOnLayout;
    BOOL isInBackground;
    SortType sortType;
    NSIndexPath *administrationViewPresentedIndexPath;
    DCPrescriberMedicationListViewController *prescriberMedicationListViewController;
    DCCalendarOneThirdViewController *prescriberMedicationOneThirdSizeViewController;
    DCCalendarDateDisplayViewController *calendarDateDisplayViewController;
    DCAdministrationViewController *detailViewController;
    DCAppDelegate *appDelegate;
    DCScreenOrientation screenOrientation;
}

@end

@implementation DCPrescriberMedicationViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    displayMedicationListArray = [[NSMutableArray alloc] init];
    currentWeekDatesArray = [[NSMutableArray alloc] init];
    rowMedicationSlotsArray = [[NSMutableArray alloc] init];
    _centerDisplayDate = [[NSDate alloc] init];
    appDelegate = [[UIApplication sharedApplication] delegate];
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self currentWeekDatesArrayFromDate:[NSDate date]];
    [self addAddMedicationButtonToNavigationBar];
    [self populateMonthYearLabel];
    [self hideCalendarTopPortion];
    [self fillPrescriberMedicationDetailsInCalendarView];
    [self obtainReferencesToChildViewControllersAddedFromStoryBoard];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self setCurrentScreenOrientation];
    [self configureCurrentWindowCalendarWidth];
    [self prescriberCalendarChildViewControllerBasedOnWindowState];
    [self addCustomTitleViewToNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAvailable:) name:kNetworkAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self cancelPreviousMedicationListFetchRequest];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self configureCurrentWindowCalendarWidth];
    if (windowSizeChanged ) {
        [self prescriberCalendarChildViewControllerBasedOnWindowState];
        [self configureDateArrayForOneThirdCalendarScreen];
        [self setCurrentScreenOrientation];
        [self addCustomTitleViewToNavigationBar];
        windowSizeChanged = NO;
    }
    [self dateViewForOrientationChanges];
   }


- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self dateViewForOrientationChanges];
    windowSizeChanged = YES;
    if (screenOrientation == landscape && appDelegate.screenOrientation == portrait) {
        if (appDelegate.windowState == twoThirdWindow) {
            appDelegate.windowState = halfWindow;
            [self configureCurrentWindowCalendarWidth];
            [self prescriberCalendarChildViewControllerBasedOnWindowState];
            [self configureDateArrayForOneThirdCalendarScreen];
            [self setCurrentScreenOrientation];
            [self addCustomTitleViewToNavigationBar];
            windowSizeChanged = NO;
        }
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prescriberTableViewPannedWithTranslationParameters:(CGFloat )xPoint
                                                 xVelocity:(CGFloat)xVelocity
                                                 panEnded:(BOOL)panEnded {
    
    [calendarDateDisplayViewController translateCalendarContainerViewsForTranslationParameters:xPoint
                                                                                 withXVelocity:xVelocity
                                                                                 panEndedValue:panEnded];
}

- (void) dateViewForOrientationChanges {
    //medication administration slots have to be made constant width , medication details flexible width
    
    monthYearViewWidthConstraint.constant = self.view.frame.size.width - self.calendarViewWidth;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)){
        calendarDateHolderViewTopSpace.constant = 30.0;
        medicationListHolderVIewTopConstraint.constant = 80;
    } else {
        calendarDateHolderViewTopSpace.constant = 64.0;
        medicationListHolderVIewTopConstraint.constant = 115.0;
    }
}

- (void)todayActionForCalendarTop {
    
    [calendarDateDisplayViewController todayActionForCalendarTop];
}

- (void)setCurrentScreenOrientation {
    
    screenOrientation = appDelegate.screenOrientation;
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

- (void)modifyTopDatesDisplay {
    
}

- (void)addAddMedicationButtonToNavigationBar {
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                 target:self
                 action:@selector(addMedicationButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

#pragma mark - Private methods

- (void)currentWeekDatesArrayFromDate:(NSDate *)date {
    
    NSInteger adderValue, daysCount;
    adderValue = (appDelegate.windowState == twoThirdWindow) ? -4 : -7;
    daysCount = (appDelegate.windowState == twoThirdWindow) ? 9 : 15;
    firstDisplayDate = [DCDateUtility initialDateForCalendarDisplay:date
                                                     withAdderValue:adderValue];
    currentWeekDatesArray = [DCDateUtility nextAndPreviousDays:daysCount
                                           withReferenceToDate:firstDisplayDate];
    _centerDisplayDate = (appDelegate.windowState == twoThirdWindow) ? [currentWeekDatesArray objectAtIndex:4] :
    [currentWeekDatesArray objectAtIndex:7];
    
}

- (void)populateMonthYearLabel {
    
    //populate month year label
    NSString *mothYearDisplayString = [DCDateUtility monthNameAndYearForWeekDatesArray:currentWeekDatesArray];
    NSAttributedString *monthYearString = [DCUtility monthYearAttributedStringForDisplayString:mothYearDisplayString withInitialMonthLength:0];
    monthYearLabel.attributedText = monthYearString;
}

- (void)calculateCalendarSlotWidth {
    
    //calculate calendar slot width
    //medication administration slots have to be made constant width , medication details flexible width
    slotWidth = (self.calendarViewWidth)/5;
}

- (void)configureCurrentWindowCalendarWidth {

    if (appDelegate.windowState == oneThirdWindow) {
        self.calendarViewWidth = CALENDAR_TWO_THIRD_WINDOW_WIDTH;
    } else {
        if (appDelegate.windowState == halfWindow) {
            self.calendarViewWidth = CALENDAR_TWO_THIRD_WINDOW_WIDTH;
        } else if (appDelegate.windowState == fullWindow) {
            self.calendarViewWidth = CALENDAR_FULL_WINDOW_WIDTH;
        } else {
            self.calendarViewWidth = CALENDAR_TWO_THIRD_WINDOW_WIDTH;
        }
    }
    calendarDateDisplayViewController.calendarViewWidth = self.calendarViewWidth;
}

- (void)prescriberCalendarChildViewControllerBasedOnWindowState {
    
    if ([DCAPPDELEGATE windowState] == halfWindow ||
        [DCAPPDELEGATE windowState] == oneThirdWindow) {
        isOneThirdMedicationViewShown = YES;
        [self hideCalendarTopPortion];
        if (currentWeekDatesArray.count > 0) {
            [self loadCurrentDayDisplayForOneThirdWithDate:_centerDisplayDate];
        }
        [self addPrescriberDrugChartViewForOneThirdWindow];
    }
    else if ([DCAPPDELEGATE windowState] == fullWindow ||
             [DCAPPDELEGATE windowState] == twoThirdWindow) {
        isOneThirdMedicationViewShown = NO;
        [self currentWeekDatesArrayFromDate:_centerDisplayDate];
        [self addPrescriberDrugChartViewForFullAndTwoThirdWindow];
        fetchOnLayout = YES;
        if( !isInBackground ){
            [self showActivityIndicationOnViewRefresh:true];
            [self fetchMedicationListForPatientWithCompletionHandler:^(BOOL success) {
                fetchOnLayout = NO;
            }];
        } else {
            [self cancelPreviousMedicationListFetchRequest];
        }
        
    }
}

// Make the API call to fetch the medicationschedules for a patient.
// this details are then used to create the medication list and the corresponding
// administration data within the calendar.
- (void)fillPrescriberMedicationDetailsInCalendarView {

    [self showActivityIndicationOnViewRefresh:true];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        if (_patient.medicationListArray) {
            _patient.medicationListArray = nil;
        }
        selectedSortType = START_DATE_ORDER;
        [self fetchMedicationListForPatientWithCompletionHandler:^(BOOL success) {
        }];
    } else {
        //hide activity indicator if network is not available
        [self showActivityIndicationOnViewRefresh:false];
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

- (void)setDisplayMedicationListArray {
    
    if (displayMedicationListArray.count > 0) {
        displayMedicationListArray = nil;
    }
    if (discontinuedMedicationShown) {
        displayMedicationListArray = (NSMutableArray *)_patient.medicationListArray;
    }
    else {
        NSString *predicateString = @"isActive == YES";
        NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
        displayMedicationListArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
    }
}

//Celendar top portion is hidden initially, which has to be updated after reload
- (void)hideCalendarTopPortion {
    
    [calendarDaysDisplayView setHidden:YES];
    [calendarTopHolderView setHidden:YES];
}

- (void)showCalendarTopPortion {

    [calendarDaysDisplayView setHidden:NO];
    [calendarTopHolderView setHidden:NO];
}

// fill in values to the allergy and alerts arrays.
- (void)configureAlertsAndAllergiesArrayForDisplay {
    
    alertsArray = self.patient.patientsAlertsArray;
    allergiesArray = self.patient.patientsAlergiesArray;
}

#pragma mark - API fetch methods

- (void)cancelPreviousMedicationListFetchRequest {
    
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    [medicationSchedulesWebService cancelPreviousRequest];
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
        NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
        NSDate *startDate;
        NSDate *endDate;
        if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
            NSDate *date = [DCDateUtility initialDateForCalendarDisplay:_centerDisplayDate withAdderValue:-7];
            NSMutableArray *oneThirdweekDatesArray = [DCDateUtility nextAndPreviousDays:15 withReferenceToDate:date];
            startDate = [oneThirdweekDatesArray objectAtIndex:0];
            endDate = [oneThirdweekDatesArray lastObject];
        } else {
            startDate = [currentWeekDatesArray objectAtIndex:0];
            endDate = [currentWeekDatesArray lastObject];
        }
        NSString *startDateString = [DCDateUtility dateStringFromDate:startDate inFormat:SHORT_DATE_FORMAT];
        DDLogDebug(@"start and end date for API call: %@ %@", startDate, endDate);
        NSString *endDateString = [DCDateUtility dateStringFromDate:endDate inFormat:SHORT_DATE_FORMAT];
        [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId fromStartDate:startDateString toEndDate:endDateString withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
            if (!error) {
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
                completionHandler(medicationListArray, nil);
            } else {
                completionHandler(nil, error);
            }
            // else
            // get the DCMedicationScheduleDetails from the medicationArray,
            // then simply call the update method to update the time chart.
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(medicationListArray, nil);
            });
        }];

        //
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
        });
    });
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

//- (void)fetchMedicationListForPatient {

- (void)fetchMedicationListForPatientWithCompletionHandler:(void(^)(BOOL success))completion {
    
    [self showActivityIndicationOnViewRefresh:true];
    [noMedicationsAvailableLabel setHidden:YES];
    [self initialiseTimer];
    [self fetchMedicationListForPatientId:self.patient.patientId
                    withCompletionHandler:^(NSArray *result, NSError *error) {
                        
                        if (!error) {
                            _patient.medicationListArray = result;
                            [self configureAlertsAndAllergiesArrayForDisplay];
                            [self addAlertsAndAllergyBarButtonToNavigationBar];
                            [self setDisplayMedicationListArray];
                            if ([displayMedicationListArray count] > 0) {
                                if (prescriberMedicationListViewController) {
                                    prescriberMedicationListViewController.currentWeekDatesArray = currentWeekDatesArray;
                                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                                    selectedSortType = START_DATE_ORDER;
                                    prescriberMedicationListViewController.patientId = self.patient.patientId;
                                }
                                if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
                                    [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                                  }
                                [medicationListHolderView setHidden:NO];
                                [calendarDaysDisplayView setHidden:NO];
                                [calendarTopHolderView setHidden:NO];
                                [self showActivityIndicationOnViewRefresh:false];
                            }
                            else {
                                DDLogError(@"the error is : %@", error);
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
                            if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
                                [prescriberMedicationOneThirdSizeViewController displayErrorMessageForErrorCode:error.code];
                            } else {
                                if (fetchOnLayout == NO) { // alert should not be shown on call in layout subviews
                                    if (error.code == NETWORK_NOT_REACHABLE || error.code == NOT_CONNECTED_TO_INTERNET) {
                                        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                                            message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
                                    } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                                        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
                                    } else if (error.code != REQUEST_CANCELLED) {
                                        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"MEDICATION_SCHEDULE_ERROR", @"")];
                                    }
                                }
                            }
                         }
                        [self showActivityIndicationOnViewRefresh:false];
                        completion(true);
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
                if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
                    [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

- (void)sortCalendarViewBasedOnCriteria:(NSString *)criteriaString {
    
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
                if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
                    [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

- (void)includeDiscontinuedMedications {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (discontinuedMedicationShown) {
            discontinuedMedicationShown = NO;
            [self setDisplayMedicationListArray];
        } else {
            discontinuedMedicationShown = YES;
            [self setDisplayMedicationListArray];
        }
        [self sortPrescriberMedicationList];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([displayMedicationListArray count] > 0) {
                if (prescriberMedicationListViewController) {
                    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
                if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
                    [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
                }
            }
        });
    });
}

#pragma mark - Navigation title, buttons and actions

// A custom view is loaded as the title for the prescriber screen.
- (void)addCustomTitleViewToNavigationBar {
    
    if ([DCAPPDELEGATE windowState] == halfWindow ||
        [DCAPPDELEGATE windowState] == oneThirdWindow) {
        DCOneThirdCalendarNavigationTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:@"DCOneThirdCalendarNavigationTitleView" owner:self options:nil] objectAtIndex:0];
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationIsLandscape(orientation) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)){
            [titleView populatViewForOneThirdLandscapeWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:self.patient.dob age:self.patient.age];
        } else {
            [titleView populateViewWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:self.patient.dob age:self.patient.age];
        }
        self.navigationItem.titleView = titleView;
    } else  {
        DCCalendarNavigationTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCCalendarNavigationTitleView class]) owner:self options:nil] objectAtIndex:0];
        [titleView populateViewWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:_patient.dob age:_patient.age
         ];
        self.navigationItem.titleView = titleView;
    }
}
//Add medication popover presentedon tapping the + bar button.
- (IBAction)addMedicationButtonPressed:(id)sender {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                                      bundle: nil];
    DCAddMedicationInitialViewController *addMedicationViewController =
    [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_POPOVER_SB_ID];
    addMedicationViewController.patientId = self.patient.patientId;
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
    warningsButton.userInteractionEnabled = NO;
}

// when press the alerts and allergies notification button
// show the popover with segmented control to switch between alerts and allergies.
- (IBAction)allergiesAndAlertsButtonTapped:(id)sender {
    
    warningsButton.selected = YES;
    [warningCountLabel setHidden:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCAlertsAllergyPopOverViewController *patientAlertsAllergyViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:PATIENTS_ALERTS_ALLERGY_VIEW_SB_ID];
    // configuring the alerts and allergies arrays to be shown.
    patientAlertsAllergyViewController.patientsAlertsArray = alertsArray;
    patientAlertsAllergyViewController.patientsAllergyArray = allergiesArray;
    patientAlertsAllergyViewController.viewDismissed = ^ {
        warningsButton.selected = NO;
        [warningCountLabel setHidden:NO];
    };
    NSMutableArray *warningsArray = [NSMutableArray arrayWithArray:alertsArray];
    [warningsArray addObjectsFromArray:allergiesArray];
    // Instatntiating the navigation controller to present the popover with preferred content size of the poppver.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:patientAlertsAllergyViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.preferredContentSize = CGSizeMake([DCUtility popOverPreferredContentSize].width, ALERT_POPOVER_INITIAL_HEIGHT);
    // Presenting the popover presentation controller on the navigation controller.
    UIPopoverPresentationController *alertsPopOverController = [navigationController popoverPresentationController];
    alertsPopOverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    UIBarButtonItem *warningsBarbuttonItem = self.navigationItem.rightBarButtonItems[1];
    [self presentViewController:navigationController animated:YES completion:nil];
    alertsPopOverController.barButtonItem = warningsBarbuttonItem;
}

- (void)addAlertsAndAllergyBarButtonToNavigationBar {
    
    warningsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    warningsButton.selected = NO;
    [warningsButton setImage:[UIImage imageNamed:ALERTS_ALLERGIES_WITHCOUNT_ICON] forState:UIControlStateNormal];
    [warningsButton setImage:[UIImage imageNamed:ALERTS_ALLERGIES_ICON] forState:UIControlStateSelected];
    [warningsButton addTarget:self action:@selector(allergiesAndAlertsButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
    [warningsButton sizeToFit];
    warningCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(warningsButton.frame.origin.x + warningsButton.frame.size.width - 22 , 2, 20, 22)];
    [warningCountLabel setFont:[UIFont systemFontOfSize:13.0]];
    [warningCountLabel setHidden:NO];
    NSInteger warningsCount = alertsArray.count + allergiesArray.count;
    [warningCountLabel setText:[NSString stringWithFormat:@"%li", (long)warningsCount]];
    warningCountLabel.textAlignment = NSTextAlignmentCenter;
    [warningCountLabel setTextColor:[UIColor whiteColor]];
    [warningCountLabel setBackgroundColor:[UIColor clearColor]];
    [warningsButton addSubview:warningCountLabel];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:warningsButton];
    if ([allergiesArray count] > 0 || [alertsArray count] > 0) {
        self.navigationItem.rightBarButtonItems = @[addButton, barButtonItem];
    } else {
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)currentWeeksDateArrayFromCenterDate: (NSDate *)centerDate {
    NSInteger adderValue, daysCount;
    adderValue = (appDelegate.windowState == twoThirdWindow) ? -4 : -7;
    daysCount = (appDelegate.windowState == twoThirdWindow) ? 9 : 15;
    firstDisplayDate = [DCDateUtility initialDateForCalendarDisplay:centerDate
                                                     withAdderValue:adderValue];
    currentWeekDatesArray = [DCDateUtility nextAndPreviousDays:daysCount
                                           withReferenceToDate:firstDisplayDate];
    _centerDisplayDate = (appDelegate.windowState == twoThirdWindow) ? [currentWeekDatesArray objectAtIndex:4]:[currentWeekDatesArray objectAtIndex:7];
    [self modifyWeekDatesInCalendarTopPortion];
    [self reloadCalendarTopPortion];
}

- (IBAction)sortButtonPressed:(id)sender {

    //display sort options in a pop over controller,
    //showDiscontinuedMedications denotes if discontinued medications are to be shown
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle: nil];
    DCSortTableViewController *sortViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SORT_VIEWCONTROLLER_STORYBOARD_ID];
    sortViewController.sortView = eCalendarView;
    sortViewController.previousSelectedCategory = selectedSortType;
    if (discontinuedMedicationShown) {
        sortViewController.showDiscontinuedMedications = YES;
    }
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:sortViewController];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    UIPopoverPresentationController *presentationController =
    [navigationController popoverPresentationController];
    presentationController.permittedArrowDirections =
    UIPopoverArrowDirectionAny;
    sortViewController.preferredContentSize = CGSizeMake(305, 200);
    presentationController.sourceView = self.view;
    presentationController.barButtonItem = (UIBarButtonItem *)sender;
    
    sortViewController.criteria = ^ (NSString * type) {
        if (![type isEqualToString:INCLUDE_DISCONTINUED]) {
            selectedSortType =  type;
        }
        [self sortCalendarViewBasedOnCriteria:type];
    };
}

- (IBAction)todayButtonPressed:(id)sender {
    
    if (prescriberMedicationListViewController && !isOneThirdMedicationViewShown) {
        [prescriberMedicationListViewController todayButtonClicked];
    } else {
        [prescriberMedicationOneThirdSizeViewController todayButtonClicked];
    }
}

#pragma mark - Public methods implementation.

- (void)reloadAdministrationScreenWithMedicationDetails {
    
    if (displayMedicationListArray.count > 0) {
        DCMedicationScheduleDetails *medicationList = [displayMedicationListArray objectAtIndex:administrationViewPresentedIndexPath.item];
        detailViewController.medicationDetails = medicationList;
        if ([medicationList.medicineCategory  isEqual: WHEN_REQUIRED]) {
            detailViewController.medicationSlotsArray = _medicationSlotArray;
            [detailViewController initialiseMedicationSlotToAdministerObject];
        } else {
            [detailViewController initialiseMedicationSlotToAdministerObject];
        }
        [detailViewController.administerTableView reloadData];
    }
}

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath
                                      withWeekDate:(NSDate *)date {
    _medicationSlotArray = [[NSArray alloc] init];
    administrationViewPresentedIndexPath = indexPath;
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    detailViewController = [administerStoryboard instantiateViewControllerWithIdentifier:@"AdministrationViewControllerSBID"];
    if ([displayMedicationListArray count] > 0) {
        DCMedicationScheduleDetails *medicationList =  [displayMedicationListArray objectAtIndex:indexPath.item];
        if (medicationList.isActive) {
            detailViewController.scheduleId = medicationList.scheduleId;
            detailViewController.medicationDetails = medicationList;
            DCSwiftObjCNavigationHelper *helper = [[DCSwiftObjCNavigationHelper alloc] init];
            helper.delegate = self;
            detailViewController.helper = helper;
            detailViewController.medicationSlotsArray = [self medicationSlotsArrayFromSlotsDictionary:medicationSLotsDictionary];
            detailViewController.weekDate = date;
            detailViewController.patientId = self.patient.patientId;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *startDate = [self dateWithRemovingTimeComponentsForDate:[DCDateUtility dateFromSourceString:medicationList.startDate] inCalendar:calendar];
            NSDate *endDate = [self dateWithRemovingTimeComponentsForDate:[DCDateUtility dateFromSourceString:medicationList.endDate] inCalendar:calendar];
            NSComparisonResult startDateOrder = [calendar compareDate:startDate toDate:date toUnitGranularity:NSCalendarUnitDay];
            NSComparisonResult endDateOrder = [calendar compareDate:endDate toDate:date toUnitGranularity:NSCalendarUnitDay];
            if (medicationList.endDate != nil) {
                if ((startDateOrder == NSOrderedAscending || startDateOrder == NSOrderedSame) &&  (endDateOrder == NSOrderedDescending || endDateOrder == NSOrderedSame)) {
                    [self presentAdministrationwithMedicationList:medicationList andDate:date];
                }
            } else {
                if (startDateOrder == NSOrderedAscending || startDateOrder == NSOrderedSame) {
                    [self presentAdministrationwithMedicationList:medicationList andDate:date];
                }
            }
        }
    }
}

- (NSDate *)dateWithRemovingTimeComponentsForDate:(NSDate*)date inCalendar:(NSCalendar *)calendar {
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

- (void)presentAdministrationwithMedicationList:(DCMedicationScheduleDetails *)medicationList andDate:(NSDate *)date {
    
    if ([medicationList.medicineCategory isEqualToString:WHEN_REQUIRED] || [medicationList.medicineCategory isEqualToString:WHEN_REQUIRED_VALUE]) {
        NSDate *today = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSComparisonResult order = [calendar compareDate:today toDate:date toUnitGranularity:NSCalendarUnitDay];
        if (order == NSOrderedSame || _medicationSlotArray.count > 0) {
            [self presentAdministrationViewController];
        }
    } else {
        [self presentAdministrationViewController];
    }
}

- (NSArray *)medicationSlotsArrayFromSlotsDictionary:(NSDictionary *)medicationSlotsDictionary {
    
    if ([[medicationSlotsDictionary allKeys] containsObject:@"timeSlots"]) {
        NSMutableArray *slotsArray = [[NSMutableArray alloc] initWithArray:[medicationSlotsDictionary valueForKey:@"timeSlots"]];
        if ([slotsArray count] > 0) {
            _medicationSlotArray = slotsArray;
            return slotsArray;
        }
    }
    return nil;
}

- (void)presentAdministrationViewController {
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSString *)startDateStringFromDateString:(NSString *)date {
    
    NSRange range = [date rangeOfString:@" "];
    NSString *startDate = [date substringToIndex:range.location];
    return startDate;
}

- (void)modifyStartDayAndWeekDates:(BOOL)isNextWeek {
    
    NSInteger adderValue, daysCount;
    BOOL isTwoThirdWindow = ([DCAPPDELEGATE windowState] == twoThirdWindow);
    if (isNextWeek) {
        adderValue = isTwoThirdWindow? 3 : 5;
    }
    else {
        adderValue = isTwoThirdWindow? -3 : -5;
    }
    daysCount = [DCAPPDELEGATE windowState] == twoThirdWindow? 9 : 15;
    firstDisplayDate = [DCDateUtility initialDateForCalendarDisplay:firstDisplayDate withAdderValue:adderValue];
    currentWeekDatesArray = [DCDateUtility nextAndPreviousDays:daysCount
                                           withReferenceToDate:firstDisplayDate];
    _centerDisplayDate = isTwoThirdWindow ? [currentWeekDatesArray objectAtIndex:4]:
                                           [currentWeekDatesArray objectAtIndex:7];
}

- (void)loadCurrentWeekDate {
    
    [self currentWeekDatesArrayFromDate:[NSDate date]];
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

- (void)loadCurrentDayDisplayForOneThirdWithDate : (NSDate *)date {
    
    CGFloat windowWidth= [DCUtility mainWindowSize].width;
    if (!dateView) {
        dateView = [[UIView alloc] init];
    }
    dateView.frame = CGRectMake(0, 0, windowWidth, 50);
    [dateView setBackgroundColor:[UIColor whiteColor]];
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, windowWidth, 50)];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"LLLL yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    dateLabel.text = dateString;
    dateLabel.backgroundColor = [UIColor whiteColor];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:20];
    dateLabel.numberOfLines = 1;
    if(isOneThirdMedicationViewShown) {
        [dateView addSubview:dateLabel];
        [calendarTopHolderView addSubview:dateView];
        [calendarTopHolderView setHidden:NO];
    } else {
        [dateView removeFromSuperview];
    }
}

- (void)updatePrescriberMedicationListDetails {
    
    if (prescriberMedicationListViewController) {
        prescriberMedicationListViewController.currentWeekDatesArray = currentWeekDatesArray;
        [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
    }
    if (prescriberMedicationOneThirdSizeViewController && isOneThirdMedicationViewShown) {
        NSDate *date = [DCDateUtility initialDateForCalendarDisplay:_centerDisplayDate withAdderValue:-7];
        NSMutableArray *oneThirdweekDatesArray = [DCDateUtility nextAndPreviousDays:15 withReferenceToDate:date];
        prescriberMedicationOneThirdSizeViewController.currentWeekDatesArray = oneThirdweekDatesArray;
        prescriberMedicationOneThirdSizeViewController.centerDate = _centerDisplayDate;
        [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
    }
}

- (void)modifyWeekDatesViewConstraint:(CGFloat)leadingConstraint {
    
    if (calendarDateDisplayViewController) {
        calendarDateDisplayViewController.calendarViewLeadingConstraint.constant = leadingConstraint;
        [calendarDateDisplayViewController.view layoutIfNeeded];
    }
}

- (void)showActivityIndicationOnViewRefresh:(BOOL)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (show) {
            _isLoading = YES;
            [activityIndicatorView startAnimating];
            [self.view bringSubviewToFront:activityIndicatorView];
        } else {
            _isLoading = NO;
            [activityIndicatorView stopAnimating];
            [self.view sendSubviewToBack:activityIndicatorView];
        }
    });
}

- (void)resetMedicationListCellsToOriginalPosition {
    
    [prescriberMedicationListViewController resetMedicationListCellsToOriginalPositionAfterCalendarSwipe];
}

- (void)addPrescriberDrugChartViewForOneThirdWindow {
    
    [prescriberMedicationListViewController.view removeFromSuperview];
    if (!prescriberMedicationOneThirdSizeViewController) {
        UIStoryboard *prescriberOneThirdStoryBoard = [UIStoryboard storyboardWithName:ONE_THIRD_SCREEN_SB bundle:nil];
        prescriberMedicationOneThirdSizeViewController = [prescriberOneThirdStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_LIST_ONE_THIRD_SBID];
        [self addChildViewController:prescriberMedicationOneThirdSizeViewController];
    }
    prescriberMedicationOneThirdSizeViewController.view.frame = medicationListHolderView.frame;
    [self.view addSubview:prescriberMedicationOneThirdSizeViewController.view];
    [prescriberMedicationOneThirdSizeViewController didMoveToParentViewController:self];
    if (currentWeekDatesArray.count == 0) {
        [self currentWeekDatesArrayFromDate:[NSDate date]];
    }
    [self.view bringSubviewToFront:activityIndicatorView];
}

- (void)configureDateArrayForOneThirdCalendarScreen {
    if ([DCAPPDELEGATE windowState] == halfWindow ||
        [DCAPPDELEGATE windowState] == oneThirdWindow) {
        prescriberMedicationOneThirdSizeViewController.centerDate = _centerDisplayDate;
        NSDate *date = [DCDateUtility initialDateForCalendarDisplay:_centerDisplayDate withAdderValue:-7];
        NSMutableArray *oneThirdweekDatesArray = [DCDateUtility nextAndPreviousDays:15 withReferenceToDate:date];
        prescriberMedicationOneThirdSizeViewController.currentWeekDatesArray = oneThirdweekDatesArray;
        [prescriberMedicationOneThirdSizeViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
    }
}

- (void)addPrescriberDrugChartViewForFullAndTwoThirdWindow {
    
    if (!calendarDateDisplayViewController) {
        [self addTopDatePortionInCalendar];
    }
    [dateView removeFromSuperview];
    [self currentWeekDatesArrayFromDate:_centerDisplayDate];
    [self modifyWeekDatesInCalendarTopPortion];
    if (calendarDateDisplayViewController) {
        [calendarDateDisplayViewController adjustHolderFrameAndDisplayDates];
    }
    [self reloadCalendarTopPortion];
    [self showCalendarTopPortion];
    [prescriberMedicationOneThirdSizeViewController.view removeFromSuperview];
    if (!prescriberMedicationListViewController) {
        UIStoryboard *prescriberStoryBoard = [UIStoryboard storyboardWithName:PRESCRIBER_DETAILS_STORYBOARD bundle:nil];
        prescriberMedicationListViewController = [prescriberStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_LIST_SBID];
        [self addChildViewController:prescriberMedicationListViewController];
    }
    prescriberMedicationListViewController.currentWeekDatesArray = currentWeekDatesArray;
    prescriberMedicationListViewController.view.frame = medicationListHolderView.frame;
    prescriberMedicationListViewController.delegate = self;
    [self.view addSubview:prescriberMedicationListViewController.view];
    [prescriberMedicationListViewController didMoveToParentViewController:self];
    [prescriberMedicationListViewController reloadMedicationListWithDisplayArray:displayMedicationListArray];
    [self.view bringSubviewToFront:activityIndicatorView];
}

#pragma mark - DCAddMedicationViewControllerDelegate implementation

// after adding a medication the latest drug schedules are fetched and displayed to the user.
- (void)addedNewMedicationForPatient {
   // [self fetchMedicationListForPatient];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self fetchMedicationListForPatientWithCompletionHandler:^(BOOL success) {
        }];
    }
}

// This method refresh the medication list when an mediation gets deleted.
- (void) refreshMedicationList {
   // [self fetchMedicationListForPatient];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self fetchMedicationListForPatientWithCompletionHandler:^(BOOL success) {
        }];
    }
}

- (void)reloadPrescriberMedicationListWithCompletionHandler:(void (^)(BOOL))completion{
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self fetchMedicationListForPatientWithCompletionHandler:^(BOOL success) {
            completion(success);
        }];
    }
}

- (void)addMedicationViewDismissed {
    
    //add medication view dismissed
    warningsButton.userInteractionEnabled = YES;
}

#pragma mark - Notification Methods

- (void)networkAvailable:(NSNotification *)notification {
    
    [self refreshMedicationList];
}

- (void)applicationEnteredBackground:(NSNotification *)notification {
    
    NSLog(@"******* Entered background *****");
    [self cancelPreviousMedicationListFetchRequest];
    isInBackground = YES;
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    
    NSLog(@"****** ENtered foreground");
    [self refreshMedicationList];
    isInBackground = NO;
}

#pragma mark - Refresh Timer methods

- (void)initialiseTimer {
    
    [self invalidateTimer];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:FIFTEEN_MINUTES target:self selector:@selector(handleRefreshTimerAction) userInfo:nil repeats:NO];
}

- (void)invalidateTimer {
    
    if (refreshTimer) {
        
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}

- (void)handleRefreshTimerAction {
    
    [self refreshMedicationList];
}

@end
