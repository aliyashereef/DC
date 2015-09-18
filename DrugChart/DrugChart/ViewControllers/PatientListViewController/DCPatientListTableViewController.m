//
//  DCPatientListTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 03/03/15.
//
//

#import "DCPatientListTableViewController.h"
#import "DCPatientTableViewCell.h"
#import "DCPatientListFilterMenuCell.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCSettingsViewController.h"
#import "DCSettingsPopOverBackgroundView.h"

#import "DCPatientListWebService.h"
#import "DCMedicationListWebService.h"
#import "DCLogOutWebService.h"
#import "DCBedWebService.h"

#import "UIImage+DCImage.h"
#import "DCPatient.h"
#import "DCMedicationSlot.h"
#import "DCBed.h"

#define ROW_HEIGHT_FOR_FILTER_CELL 47.0f
#define ROW_HEIGHT_FOR_PATIENT_CELL 90.0f
#define SECTIONS_COUNT 2
#define FIRST_SECTION_ROWS_COUNT 1

#define TABLEVIEW_OFFSET CGPointMake(0.0, 44)

#define NEXT_MEDICATION_DATE_KEY @"nextMedicationDate"

@interface DCPatientListTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, DCSettingsViewControllerDelegate> {
    
    BOOL isSearching;
    NSInteger selectedIndex;
    BOOL isAlphabeticSorted;
    NSMutableArray *alphabeticallySortedPatientList;
    NSMutableArray *patientsListArray;
    NSMutableArray *nextMedicationSortedPatientList;//patient list sorted with next medication date.
    NSMutableArray *searchedPatientsArray;
    UIPopoverController *settingsPopOverController;
}

@property (nonatomic, strong) UISearchController *patientListSearchController;
@end

@implementation DCPatientListTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    isSearching = NO;
    patientsListArray = [[NSMutableArray alloc] init];
    searchedPatientsArray = [[NSMutableArray alloc] init];
    nextMedicationSortedPatientList = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self fetchBedsInWardsToGetPatientList];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self configureNavigationBarForDisplay];
    //[self.tableView setContentOffset:TABLEVIEW_OFFSET];//offset added to hide search bar at first.
    [self addSearchControllerForPatientList];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:YES];
    [self resetNavigationBarPropertiesOnViewDisapper];
    [self hideSearchBar];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    DCDebugLog(@"Memory warning on %@",NSStringFromClass([self class]));
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTIONS_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return FIRST_SECTION_ROWS_COUNT;
    } else {
        //There are 3 datastructure: 1.table displays search results. 2. alphabetically sorted list
        //3. patient list shown by the next medication date.
        if (!isSearching) {
            if (isAlphabeticSorted) {
                return [alphabeticallySortedPatientList count];
            }
            return [nextMedicationSortedPatientList count];
        }
        return [searchedPatientsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        DCPatientListFilterMenuCell *filterMenuCell = [self getPatientListFilterMenuCell];
        return filterMenuCell;
    }
    else {
        DCPatientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PATIENT_CELL_IDENTIFIER];
        if (cell == nil) {
            cell = [[DCPatientTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:PATIENT_CELL_IDENTIFIER];
        }
        DCPatient *patient = [self getPatientForTableCellAtIndexPath:indexPath];
        [cell configurePatientCellWithPatientDetails:patient];
        return cell;
    }
}

#pragma mark - Table view Delegate Implementation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath.item;
    [self performSegueWithIdentifier:SHOW_PATIENT_MEDICATION_HOME sender:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EMPTY_STRING
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return ROW_HEIGHT_FOR_FILTER_CELL;
    } else {
        return ROW_HEIGHT_FOR_PATIENT_CELL;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.section == 0 )  {
        return nil; // first cell is not selectable.
    }
    return indexPath;
}

#pragma mark - Configure Segue for Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destinationViewController = [segue destinationViewController];
    if (_patientListSearchController.isActive) {
        [_patientListSearchController setActive:NO];
    }

    if ([destinationViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController =
        (DCPatientMedicationHomeViewController *)destinationViewController;
        DCPatient *patient;
        if (isSearching) {
            
            patient = [searchedPatientsArray objectAtIndex:selectedIndex];
        } else {
            
             patient = isAlphabeticSorted ? [alphabeticallySortedPatientList objectAtIndex:selectedIndex] : [nextMedicationSortedPatientList objectAtIndex:selectedIndex];
        }
        patientMedicationHomeViewController.patient = patient;
    }
}

#pragma mark - UISearch bar implementation
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    isSearching = NO;
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    if([searchText length] == 0) {
        
        isSearching = NO;
        [self.tableView reloadData];
    } else {
        
        isSearching = YES;
        _patientListSearchController.searchBar.showsCancelButton = YES;
        [self searchPatientListWithText:searchText];
    }
}

#pragma mark - Button click action
- (void)filterPatientListButtonPressed:(id)sender {
    
    UIButton *filterButton = (UIButton *)sender;
    if (filterButton.selected) {
        [filterButton setSelected:NO];
        isAlphabeticSorted = NO;
    }
    else {
        [filterButton setSelected:YES];
        isAlphabeticSorted = YES;
        [self getAlphabeticallySortedPatientList];
    }
    [self.tableView reloadData];
}

- (void)settingsAction:(id)sender {
    
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

- (DCPatientListFilterMenuCell *)getPatientListFilterMenuCell {
    
    DCPatientListFilterMenuCell *filterMenuCell = [self.tableView dequeueReusableCellWithIdentifier:FILTER_CELL_IDENTIFIER];
    if (filterMenuCell == nil) {
        filterMenuCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCPatientListFilterMenuCell class])
                                                    owner:self
                                                  options:nil] objectAtIndex:0];
    }
    [filterMenuCell.filterButton addTarget:self
                                    action:@selector(filterPatientListButtonPressed:)
                          forControlEvents:UIControlEventTouchUpInside];
    filterMenuCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [filterMenuCell.filterButton setSelected:isAlphabeticSorted];
    return filterMenuCell;
}

- (DCPatient *)getPatientForTableCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPatient *patient;
    if (isSearching) {
        patient = [searchedPatientsArray objectAtIndex:indexPath.item];
    }
    else {
        patient = isAlphabeticSorted ? [alphabeticallySortedPatientList objectAtIndex:indexPath.item] : [nextMedicationSortedPatientList objectAtIndex:indexPath.item];
    }
    return patient;
}

- (void)addSearchControllerForPatientList {
    
    //search controller has to be added via code since there is no option to add it via IB.
    //Search controller works only from iOS 8.
    _patientListSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _patientListSearchController.searchResultsUpdater = self;
    _patientListSearchController.dimsBackgroundDuringPresentation = NO;
    _patientListSearchController.hidesNavigationBarDuringPresentation = YES;
    _patientListSearchController.searchBar.scopeButtonTitles = @[];
    _patientListSearchController.searchBar.showsScopeBar = YES;
    _patientListSearchController.searchBar.delegate = self;
    //[_patientListSearchController.navigationController.navigationBar setTintColor:NAVIGATION_BAR_COLOR];
    self.tableView.tableHeaderView = _patientListSearchController.searchBar;
}

- (void)fetchMedicationListForPatientId:(NSString *)patientId
                  withCompletionHandler:(void(^)(NSArray *result, NSError *error))completionHandler {
    
    DCMedicationListWebService *medicationListWebService = [[DCMedicationListWebService alloc] init];
    NSMutableArray *medicationListArray = [[NSMutableArray alloc] init];
    DCDebugLog(@"patient id: %@", patientId);
    [medicationListWebService getMedicationListForPatient:patientId withCallBackHandler:^(NSArray *medicationList, NSDictionary *error) {
        NSMutableArray *medicationArray = [NSMutableArray arrayWithArray:medicationList];
        for (NSDictionary *medicationDetails in medicationArray) {
            @autoreleasepool {
                DCMedicationList *medicationList = [[DCMedicationList alloc] initWithDictionary:medicationDetails];
                if (medicationList) {
                    [medicationListArray addObject:medicationList];
                }
            }
        }
        completionHandler(medicationListArray, nil);
    }];
}

- (void)getPatientsListArrayWithCompletionHandler:(void(^)(NSString *status))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DCPatient *patient in patientsListArray) {
            [self fetchMedicationListForPatientId:patient.patientId
                            withCompletionHandler:^(NSArray *result, NSError *error) {
                                
                                patient.medicationListArray = result;
                                if ([patientsListArray indexOfObject:patient] == patientsListArray.count - 1) {
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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

- (NSString *)getBedTypeFromDictionaryIndex:(NSInteger )index {
    
    NSInteger modValue = index % 4;
    NSString *bedType;
    //This method for temp purpose for displaying bed type info
    switch (modValue) {
        case 0:
            bedType = BED;
            break;
        case 1:
            bedType = CHAIR;
            break;
        case 2:
            bedType = TROLLEY;
            break;
        case 3:
            bedType = CUBICLE;
            break;
        default:
            break;
    }
    return bedType;
}

- (void)fetchBedsInWardsToGetPatientList {
    
    NSNumber *wardNumber = [NSNumber numberWithInt:1];
    DCBedWebService *bedWebService = [[DCBedWebService alloc] init];
    [bedWebService getBedDetailsInWard:wardNumber
                   withCallBackHandler:^(NSArray *bedArray, NSDictionary *error) {
                       for (NSDictionary *bedDetailDictionary in bedArray) {
                           DCBed *bed = [[DCBed alloc] initWithDictionary:bedDetailDictionary];
                           DCPatient *patient = bed.patient;
                           patient.bedType = [self getBedTypeFromDictionaryIndex:[bedArray indexOfObject:bedDetailDictionary]]; //replace this with actual value form api
                           if (patient) {
                               [patientsListArray addObject:patient];
                           }
                       }
                       [self getPatientsListArrayWithCompletionHandler:^(NSString *status) {
                           if (status) {
                               [self sortPatientListArrayWithNextMedicationDate];
                               [self.tableView reloadData];
                           }
                       }];
                   }];
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
    NSString *patientIdString = [NSString stringWithFormat:@"patientId contains[c] '%@'", searchText];
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:patientIdString];
    NSPredicate *searchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate,idPredicate]];
    if (isAlphabeticSorted) {
        searchedPatientsArray = (NSMutableArray *)[alphabeticallySortedPatientList filteredArrayUsingPredicate:searchPredicates];
    }
    else {
        searchedPatientsArray = (NSMutableArray *)[patientsListArray filteredArrayUsingPredicate:searchPredicates];
    }
    [self.tableView reloadData];
}

- (void)hideSearchBar {
    
    dispatch_async(dispatch_get_main_queue(), ^{ // to hide search bar on going to next view.
        [_patientListSearchController.searchBar setHidden:YES];
        [_patientListSearchController.searchBar resignFirstResponder];
        [self searchBarCancelButtonClicked:nil];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        //_patientListSearchController = nil;
    });
}

@end
