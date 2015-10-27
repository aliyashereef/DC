//
//  DCPatientMedicationHomeViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/03/15.
//
//

#import "DCPatientMedicationHomeViewController.h"
#import "DCMedicationViewController.h"
#import "DCCalendarChartViewController.h"
#import "DCPrescriberViewController.h"
#import "DCAddMedicationViewController.h"
#import "DCSettingsViewController.h"
#import "DCAddMedicationInitialViewController.h"

#import "DCSettingsPopOverBackgroundView.h"
#import "DCAlertsAllergyPopOverViewController.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCMedicationTableViewCell.h"

#import "DCMedicationSlot.h"
#import "DCPatientAlert.h"
#import "DCPatientAllergy.h"

#import "DCMedicationListWebService.h"
#import "DCMedicationSchedulesWebService.h"
#import "DCPopOverContentSizeUtility.h"
#import "DCLogOutWebService.h"
#import "DCMedicationScheduleDetails.h"
#import "DCCalendarNavigationTitleView.h"
#import "DCSortTableViewController.h"

#define ALERT_BUTTON_VIEW_WIDTH     107.0f
#define ALLERGIES_BUTTON_VEW_WIDTH  107.0f
#define CELL_PADDING 13

#define ALERTS_ALLERGIES_ICON @"AlertsIcon"



typedef enum : NSInteger {
    kUserTypePrescriber,
    kUserTypeAdminister
} UserType;

@interface DCPatientMedicationHomeViewController () <DCSettingsViewControllerDelegate, DCAddMedicationViewControllerDelegate,UIPopoverControllerDelegate> {
    
    IBOutlet UILabel *dobLabel;
    IBOutlet UILabel *nhsNumberLabel;
    IBOutlet UILabel *consultantLabel;
    IBOutlet UIView *leftContainerView;
    IBOutlet UIView *rightContainerView;
    IBOutlet UIView *administerContainerView;
    IBOutlet UIView *holderView; // holds medication list, calender, medication administer screens
    IBOutlet UIView *prescriberContainerView;
    IBOutlet UIButton *administerViewToggleButton;
    IBOutlet UIButton *prescriberViewToggleButton;
    IBOutlet UIButton *addMedicationButton;
    IBOutlet NSLayoutConstraint *prescriberViewToggleButtonWidth;
    IBOutlet NSLayoutConstraint *administerViewToggleButtonWidth;
    IBOutlet NSLayoutConstraint *toggleButtonToViewBorderConstraint;
    IBOutlet NSLayoutConstraint *leadingAdministerViewConstraint;
    IBOutlet NSLayoutConstraint *topYAdministerViewConstraint;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIView *allergiesButtonContainerView;
    IBOutlet UILabel *allergiesCountLabel;
    IBOutlet NSLayoutConstraint *allergiesButtonContainerWidthConstraint;//set this to zero when no allergies
    IBOutlet UIView *alertsButtonContainerView;
    IBOutlet UILabel *alertsCountLabel;
    IBOutlet NSLayoutConstraint *alertsButtonContainerWidthConstraint;//set this to zero when no alerts
    __weak IBOutlet UIBarButtonItem *sortButton;
    __weak IBOutlet UIToolbar *toolbar;
    UIPopoverController *settingsPopOverController;
    DCMedicationViewController *medicationViewController;
    DCCalendarChartViewController *calendarChartViewController;
    DCPrescriberViewController *prescriberViewController;
    UserType selectedUserType;
    NSMutableArray *alertsArray;
    NSMutableArray *allergiesArray;
    DCMedicationSchedulesWebService *medicationSchedulesWebService;
    
    BOOL isNavigatedFromPrescriberScreen;
    NSString *selectedSortType;
    UIBarButtonItem *addButton;
}
@end

@implementation DCPatientMedicationHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedicationButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    if ([DCAPPDELEGATE isNetworkReachable]) {
        if (!_patient.medicationListArray) {
            [self fetchMedicationListForPatient];
        } else {
            [self configureAlertsAndAllergiesArray];
            [self addSortBarButtonToNavigationBar];
            [prescriberViewController reloadPrescriberViewWithMedicationListWithLoadingCompletion:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNavigationBarItems];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [medicationSchedulesWebService cancelPreviousRequest];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    if ([[SHARED_APPDELEGATE userRole] isEqualToString:ROLE_DOCTOR]) {
        [self displayPrescriberScreen];
        [addMedicationButton setHidden:NO];
    }
    else {
        [self displayMedicationAdministrationScreen];
        [self manageAdministerPrescriberToggleButtonForAdministerView];
        [addMedicationButton setHidden:YES];
    }
    [toolbar setHidden:NO];
    [self populatePatientDetails];
}

- (void)addNavigationBarItems {

    [self addCustomTitleViewToNavigationBar];
}

- (void)populatePatientDetails {
    
    [self populatePatientsDateOfBirthLabel];
    [self populatePatientsNHSLabel];
    [self populatePatientsConsultantLabel];
}

- (void)addCustomTitleViewToNavigationBar {
    
    //customise navigation bar title view
    DCCalendarNavigationTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCCalendarNavigationTitleView class]) owner:self options:nil] objectAtIndex:0];
    [titleView populateViewWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:_patient.dob age:_patient.age
     ];
    self.navigationItem.titleView = titleView;
}

- (void)addSortBarButtonToNavigationBar {
    
    UIBarButtonItem *alertsAndAllergiesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ALERTS_ALLERGIES_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(allergiesAndAlertsButtonTapped:)];
    if ([allergiesArray count] > 0 || [alertsArray count] > 0) {
        self.navigationItem.rightBarButtonItems = @[addButton, alertsAndAllergiesButton];
    } else {
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)configureAlertsAndAllergiesArray {
    
    alertsArray = self.patient.patientsAlertsArray;
    allergiesArray = self.patient.patientsAlergiesArray;
}

- (void)addPrescriberChildViewController {
    
    if (!prescriberViewController) {
        prescriberViewController = [self.storyboard instantiateViewControllerWithIdentifier:PRESCRIBER_VIEW_CONTROLLER_STORYBOARD_ID];
        [self addChildViewController:prescriberViewController];
        prescriberViewController.view.frame = holderView.bounds;
        [prescriberContainerView addSubview:prescriberViewController.view];
    }
    [prescriberViewController didMoveToParentViewController:self];
}

- (void)addMedicationChildViewControllers {

    //add calendar view in right container
    if (!calendarChartViewController) {
        calendarChartViewController = [self.storyboard instantiateViewControllerWithIdentifier:CALENDAR_VIEW_CONTROLLER_STORYBOARD_ID];
        [self addChildViewController:calendarChartViewController];
        calendarChartViewController.view.frame = rightContainerView.bounds;
        [rightContainerView addSubview:calendarChartViewController.view];
    }
    [calendarChartViewController didMoveToParentViewController:self];
    //add medication view in left container in the storyboard scene
    if (!medicationViewController) {
        medicationViewController = [self.storyboard instantiateViewControllerWithIdentifier:MEDICATION_VIEW_CONTROLLER_STORYBOARD_ID];
        [self addChildViewController:medicationViewController];
        medicationViewController.view.frame = leftContainerView.bounds;
        [leftContainerView addSubview:medicationViewController.view];
    }
    [medicationViewController didMoveToParentViewController:self];
}

- (void)toggleScreenTapDisplayAction:(BOOL)isPrescribersView {
    
    if (isPrescribersView) {
        isNavigatedFromPrescriberScreen = YES;
        [holderView setHidden:YES];
        [prescriberContainerView setHidden:NO];
        [administerViewToggleButton setSelected:NO];
        [prescriberViewToggleButton setSelected:YES];
    }
    else {
        isNavigatedFromPrescriberScreen = NO;
        [holderView setHidden:NO];
        [prescriberContainerView setHidden:YES];
        [administerViewToggleButton setSelected:YES];
        [prescriberViewToggleButton setSelected:NO];
    }
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationsList];
        for (NSDictionary *medicationDetails in medicationArray) {
            DCDebugLog(@"c\n %@",medicationDetails);
            @autoreleasepool {
                DCMedicationScheduleDetails *medicationScheduleDetails = [[DCMedicationScheduleDetails alloc] initWithMedicationScheduleDictionary:medicationDetails];
                if (medicationScheduleDetails) {
                    [medicationListArray addObject:medicationScheduleDetails];
                }
            }
        }
        completionHandler(medicationListArray, nil);
    }];
}

#pragma mark - Public Methods

- (void)setMedicationListForCalendarChart:(DCMedicationScheduleDetails *)medicationList {

    if (leadingAdministerViewConstraint.constant < 0) {
        
        DCDebugLog(@"administer view visible");
        if (!_administerMedicationViewController.hasChanges) {
            [_administerMedicationViewController cancelButtonTapped:nil];
            [calendarChartViewController setDisplayMedicationList:medicationList];
        } else {
            [self displayAdministrationAlertOnNextMedicationSelection:medicationList];
        }
    } else {
        
        [calendarChartViewController setDisplayMedicationList:medicationList];
    }
}

- (void)displayAdministerMedicationViewController:(id)medication {
    
    __weak typeof(calendarChartViewController) weakcalendarChartViewController = calendarChartViewController;
    if (_administerMedicationViewController == nil) {
        UIStoryboard *administerSB = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
        _administerMedicationViewController = [administerSB instantiateInitialViewController];
        [self addChildViewController:_administerMedicationViewController];
        _administerMedicationViewController.view.frame = administerContainerView.bounds;
        [administerContainerView addSubview:_administerMedicationViewController.view];
        [_administerMedicationViewController didMoveToParentViewController:self];
    }
    [holderView sendSubviewToBack:rightContainerView];
    [holderView bringSubviewToFront:administerContainerView];
    DCAdministerMedication *administerMedication = (DCAdministerMedication *)medication;
    _administerMedicationViewController.administerMedication = administerMedication;
    _administerMedicationViewController.patientId = _patient.patientId;
    _administerMedicationViewController.scheduleId = administerMedication.scheduleId;//currently hard coded
    [self administerViewDisplayWithAnimation:YES];
    _administerMedicationViewController.administerMedicationHandler = ^ (DCAdministerMedication *updatedMedication) {
        [weakcalendarChartViewController getUpdatedAdministerMedicationObject:updatedMedication];
    };
}

- (void)cancelMedicationAdministration {
    
    [self administerViewDisplayWithAnimation:NO];
}

- (void)doneTappedForMedicationAdministration {
    
    [self administerViewDisplayWithAnimation:NO];
}

- (void)keyBoardActionInAdministerMedicationView:(NSDictionary *)keyBoardDetails {
    
    BOOL keyboardShown = [[keyBoardDetails valueForKey:@"keyBoardShown"] boolValue];
    
    CGSize keyboardSize = [keyBoardDetails[@"keyboardSize"] CGSizeValue];
    
    BOOL isStatusTypeOmitted = [[keyBoardDetails valueForKey:@"isStatusTypeOmitted"] boolValue];
    
    if (keyboardShown) {
        int viewUpdateHeight = 50;
        if (isStatusTypeOmitted) {
            viewUpdateHeight = 280;
        }
        topYAdministerViewConstraint.constant = -(keyboardSize.height - viewUpdateHeight);
    }
    else {
        topYAdministerViewConstraint.constant = ZERO_CONSTRAINT;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (NSMutableArray *)getAllRegularMedicationList:(NSMutableArray *)listArray {
    
    NSString *predicateString = [NSString stringWithFormat:@"medicineCategory contains [cd] '%@'", REGULAR_MEDICATION];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *regularMedicationArray = (NSMutableArray *)[listArray filteredArrayUsingPredicate:predicate];
    return regularMedicationArray;
}

- (NSMutableArray *)getAllOnceMedicationList:(NSMutableArray *)listArray {
    
    NSString *predicateString = [NSString stringWithFormat:@"medicineCategory contains [cd] '%@'", ONCE_MEDICATION];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *onceMedicationArray = (NSMutableArray *)[listArray filteredArrayUsingPredicate:predicate];
    return onceMedicationArray;
}

- (NSMutableArray *)getAllWhenRequiredMedicationList:(NSMutableArray *)listArray {
    
    NSString *predicateString = [NSString stringWithFormat:@"medicineCategory contains [cd] '%@'", WHEN_REQUIRED];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        NSMutableArray *whenrequiredMedicationArray = (NSMutableArray *)[listArray filteredArrayUsingPredicate:predicate];
    return whenrequiredMedicationArray;
}

- (void)editSelectedMedication:(DCMedicationScheduleDetails *)medicationList {
    
    //edit medication triggered, present add medication screen
    [self presentAddMedicationScreenForMedicationList:medicationList];
}

- (void)presentAddMedicationScreenForMedicationList:(DCMedicationScheduleDetails *)medicationList {
    
    //pass medication list for edit
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCAddMedicationViewController *addMedicationViewController = (DCAddMedicationViewController *)[addMedicationStoryboard instantiateInitialViewController];
    addMedicationViewController.patient = _patient;
    if (medicationList) {
        addMedicationViewController.medicationList = medicationList;
    }
    UINavigationController *addMedicationNavController = [[UINavigationController alloc] initWithRootViewController:addMedicationViewController];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:addMedicationNavController animated:YES completion:nil];
    });
}

- (void)calendarSwipeInitiated {
    
   // UIWindow *mainWindow = [UIApplication  sharedApplication].windows[0];
    [self.view bringSubviewToFront:leftContainerView];
    [self.view  bringSubviewToFront:medicationViewController.view];
}

- (void)medicationListIsEmpty {
    
    //medication list empty
}

- (void)fetchMedicationListForPatient {
    
    [self.activityIndicatorView startAnimating];
    [self fetchMedicationListForPatientId:self.patient.patientId
                    withCompletionHandler:^(NSArray *result, NSError *error) {
                        
                        if (!error) {
                            _patient.medicationListArray = result;
                            [self configureAlertsAndAllergiesArray];
                            [self addSortBarButtonToNavigationBar];
                            NSString *predicateString = @"isActive == YES";
                            NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
                            
                            if (isNavigatedFromPrescriberScreen) {
                                prescriberViewController.medicationListArray = (NSMutableArray *)_patient.medicationListArray ;
                                [prescriberViewController reloadPrescriberViewWithMedicationListWithLoadingCompletion:YES];
                            }
                            else {
                                medicationViewController.medicationListArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];;
                                [medicationViewController reloadMedicationList];
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
                        [self.activityIndicatorView stopAnimating];
                    }];
}

#pragma mark - DCSettingsViewControllerDelegate implementation
- (void)logOutTapped {
    
    DCLogOutWebService *logOutWebService = [[DCLogOutWebService alloc] init];
    [logOutWebService logoutUserWithToken:nil callback:^(id response, NSDictionary *error) {
        
    }];
    [settingsPopOverController dismissPopoverAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - Action methods

- (IBAction)settingsButtonTapped:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCSettingsViewController *settingsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SETTINGS_VIEW_STORYBOARD_ID];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewController.delegate = self;

    settingsPopOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    settingsPopOverController.popoverContentSize = CGSizeMake(170.0, 110.0);
    settingsPopOverController.popoverBackgroundViewClass = [DCSettingsPopOverBackgroundView class];
    CGRect settingsFrame = CGRectMake([sender bounds].origin.x + 3, [sender bounds].origin.y ,[sender bounds].size.height, [sender bounds].size.width);
    [settingsPopOverController presentPopoverFromRect:settingsFrame inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//when press the alerts and allergies notification button to show the popover with segmented control to switch between alerts and allergies.
- (IBAction)allergiesAndAlertsButtonTapped:(id)sender {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCAlertsAllergyPopOverViewController *patientAlertsAllergyViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:PATIENTS_ALERTS_ALLERGY_VIEW_SB_ID];
    // configuring the alerts and allergies arrays to be shown.
    [self prefillContentArrays];
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

//Add medication popover presented.
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
}

// toggle switch action to display prescribers screen to the user.
// action available for prescribers/doctors only
- (IBAction)displayPrescriberViewButtonPressed:(id)sender {
    
    if (_hasAdministerChanges) {
        //currently fixed screen hang issue.. alert has to be displayed on when any unsaved changes
        [self administerViewDisplayWithAnimation:NO];
        _hasAdministerChanges = NO;
    }
   // [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows[0] animated:YES];
    [toolbar setHidden:NO];
    [self displayPrescriberScreen];
}

- (IBAction)displayAdministerViewButtonPressed:(id)sender {

   // [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows[0] animated:YES];
    [toolbar setHidden:YES];
    [self displayMedicationAdministrationScreen];
}

- (IBAction)todayButtonPressed:(id)sender {
    
    [prescriberViewController todayButtonAction];
}

- (IBAction)sortButtonPressed:(id)sender {
    
    //display sort options in a pop over controller,
    //showDiscontinuedMedications denotes if discontinued medications are to be shown
    //
    UIPopoverController *popOverController;
    DCSortTableViewController *sortViewController = [self.storyboard instantiateViewControllerWithIdentifier:SORT_VIEWCONTROLLER_STORYBOARD_ID];
    sortViewController.sortView = eCalendarView;
    sortViewController.showDiscontinuedMedications = prescriberViewController.discontinuedMedicationShown;
    sortViewController.previousSelectedCategory = selectedSortType;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:sortViewController];
    popOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    popOverController.popoverContentSize = CGSizeMake(305, 260);
    [popOverController presentPopoverFromBarButtonItem:sortButton
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    sortViewController.criteria = ^ (NSString * type) {
        if (![type isEqualToString:INCLUDE_DISCONTINUED]) {
            selectedSortType =  type;
        }
        [prescriberViewController sortCalendarViewBasedOnCriteria:type];
        [popOverController dismissPopoverAnimated:YES];
    };
}

#pragma mark - private method implementation

// display patient DOB label with the display.
- (void)populatePatientsDateOfBirthLabel {
    
    // get the DOB string to be displayed.
    dobLabel.text = [NSString stringWithFormat:@"%@ %@",_patient.dob,_patient.age];
}

- (void)populatePatientsNHSLabel {
    
    nhsNumberLabel.text = self.patient.nhs;
}

- (void) populatePatientsConsultantLabel {
    
    consultantLabel.text = self.patient.consultant;
}

// method displays and hide the administer medication view controller.
- (void)administerViewDisplayWithAnimation:(BOOL)shouldShow {
    
    _isAdministerViewPresented = shouldShow;
    [medicationViewController toggleSegmentedControlState:shouldShow];
    CGFloat viewTransitionDistance = 0.0;
    if (shouldShow) {
        DCDebugLog(@"the width of the view is: %f",administerContainerView.fsw);
        viewTransitionDistance = (-1 * administerContainerView.fsw) + 1;
        [holderView sendSubviewToBack:rightContainerView];
        [holderView bringSubviewToFront:administerContainerView];
    }
    [calendarChartViewController updateViewOnAdministerScreenAppear:shouldShow];
    [UIView animateWithDuration:0.3 animations:^{
        calendarChartViewController.calenderHeaderLeadingConstraint.constant = viewTransitionDistance;
        calendarChartViewController.calenderTableViewLeadingConstraint.constant = viewTransitionDistance;
        leadingAdministerViewConstraint.constant = viewTransitionDistance;
        [self.view layoutIfNeeded];
    }];
}

- (void)displayPrescriberScreen {
    
    selectedUserType = kUserTypePrescriber;
    [self toggleScreenTapDisplayAction:YES];
    [self addPrescriberChildViewController];
    prescriberViewController.medicationListArray = (NSMutableArray *)_patient.medicationListArray;
    [prescriberViewController reloadPrescriberViewWithMedicationListWithLoadingCompletion:NO];
}

- (void)displayMedicationAdministrationScreen {
    
    selectedUserType = kUserTypeAdminister;
    [self toggleScreenTapDisplayAction:NO];
    [self addMedicationChildViewControllers];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *predicateString = @"isActive == YES";
        NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
        medicationViewController.medicationListArray =  (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([medicationViewController.medicationListArray count] == 0) {
                [calendarChartViewController configureViewIfmedicationListIsEmpty];
            }
            else {
                [medicationViewController reloadMedicationList];
            }
        });
    });
}

- (void)manageAdministerPrescriberToggleButtonForAdministerView {
    
    [administerViewToggleButton setHidden:YES];
    [prescriberViewToggleButton setHidden:YES];
    administerViewToggleButtonWidth.constant = ZERO_CONSTRAINT;
    prescriberViewToggleButtonWidth.constant = ZERO_CONSTRAINT;
    toggleButtonToViewBorderConstraint.constant = ZERO_CONSTRAINT;
}

//If the alerts or allergy array count is zero, prefill the array with the default no alerts/allergies to display statement
- (void) prefillContentArrays{
    
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


- (void)displayAdministrationAlertOnNextMedicationSelection:(DCMedicationScheduleDetails *)medicationList {
    //display missed administartion pop up
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *missedMedicationAlertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];

    missedMedicationAlertViewController.alertType = eSaveAdministerDetails;
    missedMedicationAlertViewController.dismissView = ^{
        
        // Selecting the now selected cell
        DCMedicationTableViewCell *selectedMedicationTableViewCell = (DCMedicationTableViewCell *)[medicationViewController.medicationTableView cellForRowAtIndexPath:medicationViewController.selectedIndexPath];
        [selectedMedicationTableViewCell configureSelectedStateForSelection:YES];
        [medicationViewController.medicationTableView selectRowAtIndexPath:medicationViewController.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

        DCMedicationScheduleDetails *selectedMedicationList = selectedMedicationTableViewCell.medicationList;
        [_administerMedicationViewController cancelButtonTapped:nil];
        
        // Sending the selected medication list
        [calendarChartViewController setDisplayMedicationList:selectedMedicationList];
    };
    missedMedicationAlertViewController.dismissViewWithoutSaving = ^{
        // Selecting the previous selected cell
        medicationViewController.selectedIndexPath = medicationViewController.previousSelectedIndexPath;
        //
        DCMedicationTableViewCell *previousSelectedMedicationTableViewCell = (DCMedicationTableViewCell *)[medicationViewController.medicationTableView cellForRowAtIndexPath:medicationViewController.previousSelectedIndexPath];
        [previousSelectedMedicationTableViewCell configureSelectedStateForSelection:YES];
    };
   
    [missedMedicationAlertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:missedMedicationAlertViewController animated:YES completion:nil];
}

@end
