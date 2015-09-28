//
//  PrescriberMedicationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 27/09/15.
//
//

#import "PrescriberMedicationViewController.h"
#import "DrugChart-Swift.h"
#import "PrescriberMedicationCellTableViewCell.h"
#import "DCCalendarNavigationTitleView.h"
#import "DCAddMedicationInitialViewController.h"
#import "DCAlertsAllergyPopOverViewController.h"

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
    
    IBOutlet UITableView *medicationsTableView;
    
    UIBarButtonItem *addButton;
    NSMutableArray *alertsArray;
    NSMutableArray *allergiesArray;
    
    NSMutableArray *displayMedicationListArray;
}

@end

@implementation PrescriberMedicationViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    displayMedicationListArray = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMedicationButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    medicationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        if (!_patient.medicationListArray) {
            [self fetchMedicationListForPatient];
        } else {
            [self configureAlertsAndAllergiesArray];
            [self addSortBarButtonToNavigationBar];
            displayMedicationListArray = [NSMutableArray arrayWithArray:_patient.medicationListArray];
            [medicationsTableView reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addCustomTitleViewToNavigationBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [displayMedicationListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PrescriberMedicationCellTableViewCell *medicationCell = (PrescriberMedicationCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"prescriberIdentifier"];
    if (medicationCell == nil) {
        
        medicationCell = [[PrescriberMedicationCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"prescriberIdentifier"];
    }
    
    DCMedicationScheduleDetails *medicationList = [displayMedicationListArray objectAtIndex:indexPath.item];
    if (medicationList) {
        medicationCell.medicineName.text = medicationList.name;
        medicationCell.route.text = medicationList.route;
        medicationList.instruction = medicationList.instruction;
    }
    return medicationCell;
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationsList];
        for (NSDictionary *medicationDetails in medicationArray) {
            DCDebugLog(@"the medication details dictionary:\n %@",medicationDetails);
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



- (void)fetchMedicationListForPatient {
    
    [activityIndicatorView startAnimating];
    [self fetchMedicationListForPatientId:self.patient.patientId
                    withCompletionHandler:^(NSArray *result, NSError *error) {
                        
                        if (!error) {
                            _patient.medicationListArray = result;
                            [self configureAlertsAndAllergiesArray];
                            [self addSortBarButtonToNavigationBar];
                            NSString *predicateString = @"isActive == YES";
                            NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
                            displayMedicationListArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
                            
                            [medicationsTableView reloadData];
                            
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

@end
