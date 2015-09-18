//
//  DCPatientListViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "DCPatientListViewController.h"
#import "DCPatientListCell.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCSettingsViewController.h"
#import "DCSettingsPopOverBackgroundView.h"
#import "DCWardsPatientsListingViewController.h"

#import "DCMedicationListWebService.h"
#import "DCMedicationSchedulesWebService.h"
#import "DCLogOutWebService.h"
#import "DCBedWebService.h"

#import "DCPatient.h"
#import "DCBed.h"
#import "DCMedicationScheduleDetails.h"
#import "DCBedsAndPatientsWebService.h"

#define ROW_HEIGHT_FOR_PATIENT_CELL 53.0f
#define PATIENT_LIST_SECTION_HEIGHT 40.0f
#define TABLE_VIEW_INITIAL_Y    -20.0f
#define SEARCH_VISIBLE_CONTENT_OFFSET -64
#define SEARCH_HIDDEN_CONTENT_OFFSET -20
#define SEARCH_HEADER_HEIGHT 44

#define NEXT_MEDICATION_DATE_KEY @"nextMedicationDate"
#define OVERDUE_KEY @"Overdue"
#define IMMEDIATE_KEY @"Immediate"
#define NOT_IMMEDIATE_KEY @"Upcoming"

typedef enum : NSUInteger {
    
    eOverDue,
    eImmediate,
    eNotImmediate
} SectionCount;

@interface DCPatientListViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, DCSettingsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    BOOL isSearching;
    NSInteger selectedIndex;
    NSIndexPath *selectedIndexPath;
    BOOL isAlphabeticSorted;
    NSMutableArray *alphabeticallySortedPatientList;
    NSMutableArray *patientsListArray;
    NSMutableArray *bedsArray;
    NSMutableArray *nextMedicationSortedPatientList;//patient list sorted with next medication date.
    NSMutableArray *searchedPatientsArray;
    NSMutableArray *patientsArray;
    UIPopoverController *settingsPopOverController;
    BOOL selectedPatient;
    UIRefreshControl *refreshControl;
    NSString *previousSearchText;
    CGPoint previousContentOffset;
}


@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation DCPatientListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    isSearching = NO;
    patientsListArray = [[NSMutableArray alloc] init];
    bedsArray = [[NSMutableArray alloc] init];
    searchedPatientsArray = [[NSMutableArray alloc] init];
    nextMedicationSortedPatientList = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [_activityIndicatorView startAnimating];
        [self fetchPatientsInWardsToGetPatientList];
    } else {
        DCWardsPatientsListingViewController *wardsPatientsListingViewController  = (DCWardsPatientsListingViewController *)self.parentViewController;
        [wardsPatientsListingViewController recievedPatientListingResponse];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAvailable:) name:kNetworkAvailable object:nil];
    [self configureSearchBarViewProperties];    
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    previousContentOffset = self.tableView.contentOffset;
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)configureSearchBarViewProperties {

    if (isSearching) {
        self.tableView.contentOffset = CGPointMake(0,0);
    } else {
        [self performSelector:@selector(hideSearchBar) withObject:nil afterDelay:0.0];
        selectedPatient = NO;
    }
    [self.view layoutSubviews];
}

- (void)hideSearchBar {
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
    self.tableView.contentOffset = CGPointMake(0,-20);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionCount = [self getSectionCountForPatientTableView];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    NSInteger rowCount = [self getRowCountForSection:section];
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPatientListCell *patientCell = [tableView dequeueReusableCellWithIdentifier:PATIENT_CELL_IDENTIFIER];
    if (patientCell == nil) {
        patientCell = [[DCPatientListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:PATIENT_CELL_IDENTIFIER];
    }
    DCPatient *patient = [self getPatientForTableCellAtIndexPath:indexPath];
    [patientCell populatePatientCellWithPatientDetails:patient];
    patientCell.layoutMargins = UIEdgeInsetsZero;
    return patientCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [self getHeaderViewForSection:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return PATIENT_LIST_SECTION_HEIGHT;
}

#pragma mark - Table view Delegate Implementation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedPatient = YES;
    selectedIndex = indexPath.item;
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:SHOW_PATIENT_MEDICATION_HOME sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Configure Segue for Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destinationViewController = [segue destinationViewController];
    
    if ([destinationViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController =
        (DCPatientMedicationHomeViewController *)destinationViewController;
        DCPatient *patient = [self getPatientForTableCellAtIndexPath:selectedIndexPath];
        patientMedicationHomeViewController.patient = patient;
    }
}

#pragma mark - UISearch bar implementation

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    isSearching = NO;
    searchBar.showsCancelButton = NO;
    searchBar.text = EMPTY_STRING;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    if([searchText length] == 0) {
        isSearching = NO;
        if (!selectedPatient) {
            [self.tableView reloadData];
        } 
    } else {
        isSearching = YES;
        [self searchPatientListWithText:searchText];
    }
}

- (void)searchBar:(UISearchBar *)searchedBar textDidChange:(NSString *)searchText {
    
    if (searchText.length > 0) {
        // Search and Reload data source
        isSearching = YES;
        //_searchBar.showsCancelButton = YES;
        [self searchPatientListWithText:searchText];
    } else {
        isSearching = NO;
        _searchBar.showsCancelButton = NO;
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    isSearching = YES;
    [self.view endEditing:YES];
}


#pragma mark - Button click action
- (void)filterPatientListButtonPressed:(id)sender {
    
    UIButton *filterButton = (UIButton *)sender;
    if (filterButton.selected) {
        [filterButton setSelected:NO];
        isAlphabeticSorted = NO;
    } else {
        [filterButton setSelected:YES];
        isAlphabeticSorted = YES;
        [self getAlphabeticallySortedPatientList];
    }
    [self.tableView reloadData];
}

- (void)settingsAction:(id)sender {
    
//    if (_patientListSearchController.isActive) {
//        [_patientListSearchController setActive:NO];
//    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCSettingsViewController *settingsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SETTINGS_VIEW_STORYBOARD_ID];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewController.delegate = self;
    
    settingsPopOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    settingsPopOverController.popoverContentSize = CGSizeMake(170.0, 110.0);
    settingsPopOverController.popoverBackgroundViewClass = [DCSettingsPopOverBackgroundView class];
    [settingsPopOverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - DCSettingsViewControllerDelegate implementation

- (void)logOutTapped {
    
    DCLogOutWebService *logOutWebService = [[DCLogOutWebService alloc] init];
    [logOutWebService logoutUserWithToken:nil callback:^(id response, NSDictionary *error) {
        
    }];
    [settingsPopOverController dismissPopoverAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - private method implementation

- (void)configureViewElements {
    
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self configureNavigationBarForDisplay];
    //[self addSearchControllerForPatientList];
    [self performSelector:@selector(updateTableViewContentOffset) withObject:nil afterDelay:0.0];
    [self addRefreshControl];
}

- (void)addRefreshControl {
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(patientListRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)patientListRefresh:(id)sender {
    
    [self fetchPatientsInWardsToGetPatientList];
}

- (NSString *)getSectionTitleForSection:(NSInteger)section {
    
    //get section title
    NSString *sectionTitle = EMPTY_STRING;
    NSArray *contentArray = isSearching ? searchedPatientsArray: patientsArray;
    NSArray *overDueArray = [[contentArray objectAtIndex:0] valueForKey:OVERDUE_KEY];
    NSArray *immediateArray = [[contentArray objectAtIndex:1] valueForKey:IMMEDIATE_KEY];
    NSArray *nonImmediateArray = [[contentArray objectAtIndex:2] valueForKey:NOT_IMMEDIATE_KEY];
    switch (section) {
        case eOverDue:
            if (overDueArray.count > 0) {
                sectionTitle = OVERDUE_KEY;
            } else {
                if (immediateArray.count > 0) {
                    sectionTitle = IMMEDIATE_KEY;
                } else {
                    sectionTitle = NOT_IMMEDIATE_KEY;
                }
            }
            break;
        case eImmediate:
            if (immediateArray.count > 0) {
                sectionTitle = IMMEDIATE_KEY;
            } else {
                sectionTitle = NOT_IMMEDIATE_KEY;
            }
            break;
        case eNotImmediate:
            
            if (nonImmediateArray.count > 0) {
                sectionTitle = IMMEDIATE_KEY;
            }
            break;
        default:
            break;
    }
    return sectionTitle;
}

- (UIView *)getHeaderViewForSection:(NSInteger)section {
    
    //add header view with section name
    if ([patientsListArray count] > 0) {
        NSString *sectionTitle = [self getSectionTitleForSection:section];
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.frame = CGRectMake(10, 8, 320, 20);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:13];
        headerLabel.text = sectionTitle;
        UIView *headerView = [[UIView alloc] init];
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

- (NSInteger )getSectionCountForPatientTableView {
    
    NSArray *contentArray = isSearching ? searchedPatientsArray: patientsArray;
    NSArray *overDueArray = [[contentArray objectAtIndex:0] valueForKey:OVERDUE_KEY];
    NSArray *immediateArray = [[contentArray objectAtIndex:1] valueForKey:IMMEDIATE_KEY];
    NSArray *nonImmediateArray = [[contentArray objectAtIndex:2] valueForKey:NOT_IMMEDIATE_KEY];
    NSInteger sectionCount = 0;
    if (overDueArray.count > 0) {
        sectionCount ++ ;
    }
    if (immediateArray.count > 0) {
        sectionCount ++;
    }
    if (nonImmediateArray.count > 0) {
        sectionCount ++;
    }
    return sectionCount;
}

- (NSInteger )getRowCountForSection:(NSInteger)section {
    
    NSArray *contentArray = isSearching ? searchedPatientsArray: patientsArray;
    NSArray *overDueArray = [[contentArray objectAtIndex:0] valueForKey:OVERDUE_KEY];
    NSArray *immediateArray = [[contentArray objectAtIndex:1] valueForKey:IMMEDIATE_KEY];
    NSArray *nonImmediateArray = [[contentArray objectAtIndex:2] valueForKey:NOT_IMMEDIATE_KEY];
    if (section == eOverDue) {
        if (overDueArray.count > 0) {
            return overDueArray.count;
        } else {
            if (immediateArray.count > 0) {
                return immediateArray.count;
            } else {
                return nonImmediateArray.count;
            }
        }
    } else if (section == eImmediate) {
        if (immediateArray.count > 0) {
            return immediateArray.count;
        } else {
            return nonImmediateArray.count;
        }
    } else {
        return nonImmediateArray.count;
    }
    return 0;
}

- (void)updateTableViewContentOffset {
    
    self.tableView.contentOffset = CGPointMake(0, TABLE_VIEW_INITIAL_Y);
}

- (DCPatient *)getPatientForTableCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPatient *patient;
    NSArray *contentArray = isSearching ? searchedPatientsArray: patientsArray;
    NSArray *overDueArray = [[contentArray objectAtIndex:0] valueForKey:OVERDUE_KEY];
    NSArray *immediateArray = [[contentArray objectAtIndex:1] valueForKey:IMMEDIATE_KEY];
    NSArray *nonImmediateArray = [[contentArray objectAtIndex:2] valueForKey:NOT_IMMEDIATE_KEY];
    switch (indexPath.section) {
        case eOverDue:
            if (overDueArray.count > 0) {
                patient = [overDueArray objectAtIndex:indexPath.row];
            } else {
                if (immediateArray.count > 0) {
                    patient = [immediateArray objectAtIndex:indexPath.row];
                } else {
                    patient = [nonImmediateArray objectAtIndex:indexPath.row];
                }
            }
            break;
        case eImmediate:
            if (immediateArray.count > 0) {
                patient = [immediateArray objectAtIndex:indexPath.row];
            } else {
                patient = [nonImmediateArray objectAtIndex:indexPath.row];
            }
            break;
        case eNotImmediate:
            patient = [nonImmediateArray objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    return patient;
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    DCMedicationSchedulesWebService *medicationSchedulesWebService = [[DCMedicationSchedulesWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    [medicationSchedulesWebService getMedicationSchedulesForPatientId:patientId withCallBackHandler:^(NSArray *medicationsList, NSError *error) {
        
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationsList];
        for (NSDictionary *medicationDetails in medicationArray) {
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

- (void)getPatientsMedicationListArrayWithCompletionHandler:(void(^)(NSString *status))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DCPatient *patient in patientsListArray) {
            [self fetchMedicationListForPatientId:patient.patientId
                            withCompletionHandler:^(NSArray *result, NSError *error) {
                                
                                patient.medicationListArray = result;
                                if ([patientsListArray indexOfObject:patient] == patientsListArray.count - 1) {
                                    [_activityIndicatorView stopAnimating];
                                    completionHandler (SUCCESS);
                                }
                            }];
        }
        DCDebugLog(@"the patient list array: %@",patientsListArray);
    });
}

- (void)sortPatientListArrayWithNextMedicationDate {
    
    NSArray *sortedArray = [DCUtility sortArray:patientsListArray
                                     basedOnKey:NEXT_MEDICATION_DATE_KEY
                                      ascending:YES];
    NSMutableArray *noMedicationDateArray = [[NSMutableArray alloc] init];
    // the sorted patients with nextMedicationDate has to be shown on top
    // and patients without nextMedicationDate to be shown below it.
    for (DCPatient *patient in sortedArray) {
        if (patient.nextMedicationDate) {
            [nextMedicationSortedPatientList addObject:patient];
        }
        else {
            [noMedicationDateArray addObject:patient];
        }
    }
    if ([noMedicationDateArray count] > 0) {
        [nextMedicationSortedPatientList addObjectsFromArray:noMedicationDateArray];
    }
}

- (NSArray *)categorizePatientListBasedOnEmergency:(NSArray *)contentArray {
    
    //categorize patient list
    NSMutableArray *overDueArray = [[NSMutableArray alloc] init];
    NSMutableArray *immediateArray = [[NSMutableArray alloc] init];
    NSMutableArray *nonImmediateArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    NSArray *nextMedicationSortedArray = [DCUtility sortArray:contentArray
                                     basedOnKey:NEXT_MEDICATION_DATE_KEY
                                      ascending:YES];
    for (DCPatient *patient in nextMedicationSortedArray) {
        //split sorted array in to specific categories
        if (patient.emergencyStatus == kMedicationDue) {
            [overDueArray addObject:patient];
        } else if (patient.emergencyStatus == kMedicationInHalfHour || patient.emergencyStatus == kMedicationInOneHour) {
            [immediateArray addObject:patient];
        } else {
            [nonImmediateArray addObject:patient];
        }
    }
    [sortedArray addObject:@{OVERDUE_KEY : overDueArray}];
    [sortedArray addObject:@{IMMEDIATE_KEY : immediateArray}];
    [sortedArray addObject:@{NOT_IMMEDIATE_KEY : nonImmediateArray}];
    return sortedArray;
}

// once the bedArray is populated its set to the graphical view of the wards.
// the bed details are used to draw the wards graphical display.
- (void)setBedsArrayToWardsGraphicalViewController {
    
    DCBedsAndPatientsWebService *bedWebService = [[DCBedsAndPatientsWebService alloc] init];
    [bedWebService getBedsPatientsDetailsFromUrl:self.selectedWard.bedsUrl withCallBackHandler:^(NSArray *responseObject, NSError *error) {
        if (!error) {
            [_activityIndicatorView stopAnimating];
            DCWardsPatientsListingViewController *wardsPatientsListingViewController  = (DCWardsPatientsListingViewController *)self.parentViewController;
            [wardsPatientsListingViewController recievedPatientListingResponse];
            for (NSDictionary *bedDetailDictionary in responseObject) {
                DCBed *bed = [[DCBed alloc] initWithDictionary:bedDetailDictionary];
                [bedsArray addObject:bed];
                DCPatient *patient = bed.patient;
                if (patient) {
                    for (DCPatient *occupyingPatient in patientsListArray) {
                        if ([occupyingPatient.patientId isEqualToString:patient.patientId]) {
                            occupyingPatient.bedId = patient.bedId;
                            occupyingPatient.bedNumber = patient.bedNumber;
                            occupyingPatient.bedType = patient.bedType;
                            bed.patient = occupyingPatient;
                        }
                    }
                }
            }            
            wardsPatientsListingViewController.bedsArray = bedsArray;
            [self.tableView reloadData];
        }
    }];
}

- (void)fetchPatientsInWardsToGetPatientList {

    DCBedsAndPatientsWebService *bedWebService = [[DCBedsAndPatientsWebService alloc] init];
    [bedWebService getBedsPatientsDetailsFromUrl:self.selectedWard.patientsUrl withCallBackHandler:^(NSArray *responseObject, NSError *error) {
        
        if (!error) {
            [patientsListArray removeAllObjects];
            for (NSDictionary *patientDictionary in responseObject) {
                DCPatient *patient = [[DCPatient alloc] initWithPatientDictionary:patientDictionary];
                [patient getAdditionalInformationAboutPatientFromUrlwithCallBackHandler:^(NSError *error) {
                    if (!error) {
                        [self setBedsArrayToWardsGraphicalViewController];
                    }
                }];
                [patientsListArray addObject:patient];
            }
            if ([patientsListArray count] > 0) {
                // we need not have to fetch the medication list here, instead we
                // now call it on selecting a particular patient.
                [self sortPatientListArrayWithNextMedicationDate];
                patientsArray = (NSMutableArray *)[self categorizePatientListBasedOnEmergency:patientsListArray];
            } else {
                [_messageLabel setHidden:NO];
            }
        } else {
            [self handleErrorResponseForPatientList:error];
        }
        [refreshControl endRefreshing];
    }];
}


- (void)handleErrorResponseForPatientList:(NSError *)error {
    
    if (error.code == NETWORK_NOT_REACHABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
    } else if (error.code == WEBSERVICE_UNAVAILABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
    } else {
        [_messageLabel setHidden:NO];
    }
    [_activityIndicatorView stopAnimating];
}

- (void)configureNavigationBarForDisplay {
    
    self.title = NSLocalizedString(@"IN_PATIENT_TITLE" , @"title string");
    self.navigationItem.rightBarButtonItems = [DCUtility getBarButtonItemsItemsInPatientViewController:self andAction:@selector(settingsAction:)];
}

- (void)resetNavigationBarPropertiesOnViewDisapper {
    
    self.navigationItem.hidesBackButton = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)getAlphabeticallySortedPatientList {
    
    if (alphabeticallySortedPatientList == nil) {
        alphabeticallySortedPatientList = [[NSMutableArray alloc] initWithArray:[DCUtility sortArray:patientsListArray basedOnKey:PATIENT_NAME ascending:YES]];
    }
}

- (void)logoutAction {
    
    DCLogOutWebService *logOutWebService = [[DCLogOutWebService alloc] init];
    [logOutWebService logoutUserWithToken:nil callback:^(id response, NSDictionary *error) {
        
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// searches the patient list with patient name and patient id.
- (void)searchPatientListWithText:(NSString *)searchText {
    
    NSString *patientNameString = [NSString stringWithFormat:@"patientName contains[c] '%@'", searchText];
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:patientNameString];
    NSString *patientIdString = [NSString stringWithFormat:@"patientNumber contains[c] '%@'", searchText];
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:patientIdString];
    NSPredicate *searchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate,idPredicate]];
    searchedPatientsArray = (NSMutableArray *)[patientsListArray filteredArrayUsingPredicate:searchPredicates];
    searchedPatientsArray = (NSMutableArray *)[self categorizePatientListBasedOnEmergency:searchedPatientsArray];
    [self.tableView reloadData];
}

- (void)cancelPatientListSearching {
    
    isSearching = NO;
    [_searchBar resignFirstResponder];
    _searchBar.text  = EMPTY_STRING;
}

#pragma mark - Notification Methods

- (void)networkAvailable:(NSNotification *)notification {
    
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [_activityIndicatorView startAnimating];
        [self fetchPatientsInWardsToGetPatientList];
    }
}

@end
