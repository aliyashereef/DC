//
//  PrescriberMedicationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import "PrescriberMedicationViewController.h"
#import "DrugChart-Swift.h"
//#import "PrescriberMedicationCellTableViewCell.h"
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
#define CELL_PADDING 13

#define ALERTS_ALLERGIES_ICON @"AlertsIcon"


@interface PrescriberMedicationViewController () {
    
    NSMutableArray *currentWeekDatesArray;
    IBOutlet UIView *calendarDaysDisplayView;
    IBOutlet UIView *todayString;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UILabel *noMedicationsAvailableLabel;
    IBOutlet UIView *todayBackGroundView;
    IBOutlet UIView *calendarTopHolderView;
    // just for intermin release. to be moved to another view controller
    IBOutlet UILabel *firstDayLabel;
    IBOutlet UILabel *secondDayLabel;
    IBOutlet UILabel *thirdDayLabel;
    IBOutlet UILabel *fourthDayLabel;
    IBOutlet UILabel *fifthDayLabel;
    
    IBOutlet UITableView *medicationsTableView;
    
    UIBarButtonItem *addButton;
    NSMutableArray *alertsArray;
    NSMutableArray *allergiesArray;
    NSString *selectedSortType;
    NSMutableArray *displayMedicationListArray;
    NSMutableArray *rowMedicationSlotsArray;
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
    [self setCurrentWeekDatesArrayFromToday];
    [self configurePrescriberMedicationView];
    // Commented out for this release.
    //[self addCalendarDateView];
    [self displayDatesInCalendarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addCustomTitleViewToNavigationBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentWeekDatesArrayFromToday {
    
    NSDate *firstDay = [DCDateUtility getInitialDateForFiveDayDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    currentWeekDatesArray = [DCDateUtility getFiveDaysOfWeekFromDate:firstDay];
    NSLog(@"the week days array: %@", currentWeekDatesArray);
}

- (void)addCalendarDateView {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCCalendarDateDisplayViewController *viewController = [administerStoryboard instantiateViewControllerWithIdentifier:@"CalendarDateDisplayView"];
    
    [calendarDaysDisplayView addSubview:viewController.view];
}

+ (NSMutableArray *)getDateDisplayStringForDateArray:(NSArray *)dateArray {
    
    //get date display string in calendar view in eg format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSArray *weekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
    NSMutableArray *weekDays = [[NSMutableArray alloc] init];
    for (NSDate *date in dateArray) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
        NSInteger day = [comps weekday];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:DATE_COMPONENTS fromDate:date];
        NSString *displayText = [NSString stringWithFormat:@"%@ %li", [weekdaySymbols objectAtIndex:day-1], (long)[components day]];
        [weekDays addObject:displayText];
    }
    return weekDays;
}

//TODO: just for the display for interim  release.
// Method will be replaced with the original method for display.
- (void)displayDatesInCalendarView {
    
    NSMutableArray *weekDisplayArray = [[NSMutableArray alloc] init];
    weekDisplayArray = [PrescriberMedicationViewController getDateDisplayStringForDateArray:currentWeekDatesArray];
    if ([weekDisplayArray count] == 5) {
        firstDayLabel.text = (NSString *)[weekDisplayArray objectAtIndex:0];
        secondDayLabel.text = (NSString *)[weekDisplayArray objectAtIndex:1];
        
        NSString *todaysString = (NSString *)[weekDisplayArray objectAtIndex:2];
        NSString *dayString, *dayNameString;
        NSArray *components = [todaysString componentsSeparatedByString:@" "];
        if ([components count] == 2) {
            dayString = (NSString *)[components objectAtIndex:1];
            if ([dayString length] == 2) {
                dayNameString = [NSString stringWithFormat:@"%@ ",(NSString *)[components objectAtIndex:0]];
            }
            else {
                dayNameString = [NSString stringWithFormat:@"%@  ",(NSString *)[components objectAtIndex:0]];
            }
        }
        
        NSAttributedString * dateString = [[NSMutableAttributedString alloc] initWithString:dayString attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        NSMutableAttributedString *dayDisplayString = [[NSMutableAttributedString alloc] initWithString:dayNameString];
        [dayDisplayString appendAttributedString:dateString];
        thirdDayLabel.attributedText = dayDisplayString;
        fourthDayLabel.text = (NSString *)[weekDisplayArray objectAtIndex:3];
        fifthDayLabel.text = (NSString *)[weekDisplayArray objectAtIndex:4];
    }
}

- (void)configurePrescriberMedicationView {
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedicationButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    medicationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [todayBackGroundView.layer setCornerRadius:12.5];

    if ([DCAPPDELEGATE isNetworkReachable]) {
        if (!_patient.medicationListArray) {
            [self fetchMedicationListForPatient];
        } else {
            [self getDisplayMedicationListArray];
            if ([displayMedicationListArray count] == 0) {
                noMedicationsAvailableLabel.text = @"No active medications available";
                [noMedicationsAvailableLabel setHidden:NO];
            }
            else {
                noMedicationsAvailableLabel.text = @"No medications available";
                [noMedicationsAvailableLabel setHidden:YES];
            }
            [self configureAlertsAndAllergiesArray];
            [self addSortBarButtonToNavigationBar];
            [medicationsTableView reloadData];
        }
    }
}

#pragma mark - table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [displayMedicationListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PrescriberMedicationTableViewCell *medicationCell = (PrescriberMedicationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"prescriberIdentifier"];
    if (medicationCell == nil) {
        medicationCell = [[PrescriberMedicationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"prescriberIdentifier"];
    }
    medicationCell.selectionStyle = UITableViewCellSelectionStyleNone;
    DCMedicationScheduleDetails *medicationList = [displayMedicationListArray objectAtIndex:indexPath.item];
    if (medicationList) {
        medicationCell.medicineName.text = medicationList.name;
        medicationCell.route.text = medicationList.route;
        if (medicationList.instruction != nil) {
            medicationCell.instructions.text = [NSString stringWithFormat:@" (%@)", medicationList.instruction];
        }
    }
    rowMedicationSlotsArray = [self setMedicationSlotsForDisplay:medicationList];
    if ([rowMedicationSlotsArray count] > 0) {
        [self addMedicationSlotsFromSlotArray:rowMedicationSlotsArray
                              inTableViewCell:medicationCell
                                  atIndexPath:indexPath];
    }
    return medicationCell;
}

- (NSMutableArray *)setMedicationSlotsForDisplay:(DCMedicationScheduleDetails *)medicationList {
    
    NSMutableArray *displayMedicationSlotsArray = [[NSMutableArray alloc] init];
    NSInteger count = 0, weekDays = 5;
    while (count < weekDays) {
        
        NSMutableDictionary *slotsDictionary = [[NSMutableDictionary alloc] init];
        if (count <[currentWeekDatesArray count] ) {
            NSString *formattedDateString = [DCDateUtility convertDate:[currentWeekDatesArray objectAtIndex:count] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
            NSString *predicateString = [NSString stringWithFormat:@"medDate contains[cd] '%@'",formattedDateString];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            NSArray *slotsDetailsArray = [medicationList.timeChart filteredArrayUsingPredicate:predicate];
            if ([slotsDetailsArray count] > 0) {
                NSMutableArray *medicationSlotArray = [[slotsDetailsArray objectAtIndex:0] valueForKey:MED_DETAILS];
                [slotsDictionary setObject:medicationSlotArray forKey:PRESCRIBER_TIME_SLOTS];
            }
        }
        [slotsDictionary setObject:[NSNumber numberWithInteger:count+1] forKey:PRESCRIBER_SLOT_VIEW_TAG];
        [displayMedicationSlotsArray addObject:slotsDictionary];
        count++;
    }
    return displayMedicationSlotsArray;
}

- (void)addMedicationSlotsFromSlotArray:(NSMutableArray *)displaySlotsArray
                        inTableViewCell:(PrescriberMedicationTableViewCell *)prescriberCell
                            atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = 1;
    while (index <= [displaySlotsArray count]) {
        // things are coming correctly here. just ensure that the correct slots go for the correct view.
        
        
        DCMedicationAdministrationStatusView *statusView = (DCMedicationAdministrationStatusView *)[prescriberCell viewWithTag:index];
        statusView.delegate = self;
        statusView.medicationSLotDictionary = [displaySlotsArray objectAtIndex:index - 1];
//        statusView.medicationSlot = [displayMedicationListArray objectAtIndex:indexPath.item];
        statusView.currentIndexPath = indexPath;
        index++;
    }
}


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
                for (NSDictionary *medicationDetails in medicationArray) {
                    DCDebugLog(@"the medication details dictionary:\n %@", medicationDetails);
                   // NSLog(@"the medication details dictionary:\n %@", medicationDetails);
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

- (void)getDisplayMedicationListArray {
    
    NSString *predicateString = @"isActive == YES";
    NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    displayMedicationListArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
}

- (void)fetchMedicationListForPatient {
    
    [activityIndicatorView startAnimating];
    [calendarDaysDisplayView setHidden:YES];
    [calendarTopHolderView setHidden:YES];
    [noMedicationsAvailableLabel setHidden:YES];
    [self fetchMedicationListForPatientId:self.patient.patientId
                    withCompletionHandler:^(NSArray *result, NSError *error) {
                        
                        if (!error) {
                            _patient.medicationListArray = result;
                            [self configureAlertsAndAllergiesArray];
                            [self addSortBarButtonToNavigationBar];
                            [self getDisplayMedicationListArray];
                            if ([displayMedicationListArray count] > 0) {
                                [medicationsTableView reloadData];
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


- (void)addCustomTitleViewToNavigationBar {
    
    //customise navigation bar title view
    DCCalendarNavigationTitleView *titleView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCCalendarNavigationTitleView class]) owner:self options:nil] objectAtIndex:0];
    [titleView populateViewWithPatientName:self.patient.patientName nhsNumber:self.patient.nhs dateOfBirth:_patient.dob age:_patient.age
     ];
    self.navigationItem.titleView = titleView;
}


//Add medication popover presented.
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


- (void)configureAlertsAndAllergiesArray {
    
    alertsArray = self.patient.patientsAlertsArray;
    allergiesArray = self.patient.patientsAlergiesArray;
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

- (void)addSortBarButtonToNavigationBar {
    
    UIBarButtonItem *alertsAndAllergiesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ALERTS_ALLERGIES_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(allergiesAndAlertsButtonTapped:)];
    if ([allergiesArray count] > 0 || [alertsArray count] > 0) {
        self.navigationItem.rightBarButtonItems = @[addButton, alertsAndAllergiesButton];
    } else {
        self.navigationItem.rightBarButtonItem = addButton;
    }
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
- (IBAction)sortButtonPressed:(id)sender {
    
    //display sort options in a pop over controller,
    //showDiscontinuedMedications denotes if discontinued medications are to be shown
    //
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle: nil];
    UIPopoverController *popOverController;
    DCSortTableViewController *sortViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SORT_VIEWCONTROLLER_STORYBOARD_ID];
    sortViewController.sortView = eCalendarView;
    sortViewController.previousSelectedCategory = selectedSortType;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:sortViewController];
    popOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    popOverController.popoverContentSize = CGSizeMake(305, 260);
    [popOverController presentPopoverFromBarButtonItem:sender
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    sortViewController.criteria = ^ (NSString * type) {
        if (![type isEqualToString:INCLUDE_DISCONTINUED]) {
            selectedSortType =  type;
        }
         [popOverController dismissPopoverAnimated:YES];
    };
}

- (void)displayAdministrationViewForMedicationSlot:(NSDictionary *)medicationSLotsDictionary
                                       atIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    DCCalendarSlotDetailViewController *detailViewController = [administerStoryboard instantiateViewControllerWithIdentifier:CALENDAR_SLOT_DETAIL_STORYBOARD_ID];
    if ([displayMedicationListArray count] > 0) {
        DCMedicationScheduleDetails *medicationList =  [displayMedicationListArray objectAtIndex:indexPath.item];
        detailViewController.medicationDetails = medicationList;
    }
    if ([[medicationSLotsDictionary allKeys] containsObject:@"timeSlots"]) {
        NSMutableArray *slotsArray = [[NSMutableArray alloc] initWithArray:[medicationSLotsDictionary valueForKey:@"timeSlots"]];
        if ([slotsArray count] > 0) {
            detailViewController.medicationSlotsArray = slotsArray;
        }
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - administer view tag delegate method called
- (void)administerMedicationWithMedicationSlots: (NSDictionary *)slotsDictionary
                                    atIndexPath:(NSIndexPath *)indexPath {
    
    [self displayAdministrationViewForMedicationSlot:slotsDictionary atIndexPath:indexPath];
}

@end
