//
//  DCMedicationListViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/2/15.
//
//

#import "DCMedicationListViewController.h"
#import "DCMedicationSearchWebService.h"
#import "DCMedicationListTableViewCell.h"
#import "DCContraIndicationWebService.h"
#import "DrugChart-Swift.h"

#define CELL_PADDING 24
#define CELL_MININUM_HEIGHT 44
#define TABLEVIEW_TOP_CONSTRAINT -20.0f

@interface DCMedicationListViewController () <WarningsDelegate> {
    
    __weak IBOutlet UITableView *medicationListTableView;
    __weak IBOutlet UISearchBar *medicationSearchBar;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet NSLayoutConstraint *tableViewTopConstraint;
    
    NSMutableArray *medicationListArray;
    DCMedicationSearchWebService *medicationWebService;
    NSMutableArray *warningsArray;
    DCMedication *updatedMedication;
    DCWarningsListViewController *warningsListViewController;
}

@end

@implementation DCMedicationListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if ([DCAPPDELEGATE windowState] == halfWindow ||
        [DCAPPDELEGATE windowState] == oneThirdWindow) {
        self.isLoadingForFirstTimeInHalfScreen = YES;
        self.valueForTableTopConstraint = ZERO_CONSTRAINT;
        tableViewTopConstraint.constant = ZERO_CONSTRAINT;
    } else {
        self.valueForTableTopConstraint = TABLEVIEW_TOP_CONSTRAINT;
    }
    [self configureViewElements];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [medicationSearchBar becomeFirstResponder];
    medicationListTableView.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [medicationWebService cancelPreviousRequest];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLayoutSubviews {
    
    [self ajustTableViewConstraints];
    [super viewDidLayoutSubviews];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    [self configureNavigationBarItems];
    [self configureFetchListTableView];
}

- (void)configureNavigationBarItems {
    
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)ajustTableViewConstraints {
    
    NSInteger windowWidth = [DCUtility mainWindowSize].width;
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    tableViewTopConstraint.constant = (windowWidth > screenWidth/2) ? ZERO_CONSTRAINT : self.valueForTableTopConstraint;
    if (([DCAPPDELEGATE windowState] == twoThirdWindow ||
        [DCAPPDELEGATE windowState] == fullWindow) && self.isLoadingForFirstTimeInHalfScreen) {
        tableViewTopConstraint.constant = 20.0;
    }
    
 }

- (void)configureFetchListTableView {
    
    medicationListTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    medicationWebService = [[DCMedicationSearchWebService alloc] init];
    medicationListArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"SEARCH_MEDICATION_MIN_LIMIT", @"")]];
}

- (void)fetchMedicationListForString:(NSString *)searchString {
    
    //get list of medications for search string
    medicationWebService = [[DCMedicationSearchWebService alloc] init];
    medicationWebService.searchString = searchString;
    [activityIndicator startAnimating];
    [medicationWebService getCompleteMedicationListWithCallBackHandler:^(id response, NSDictionary *errorDict) {
        if (!errorDict) {
            medicationListArray = [NSMutableArray arrayWithArray:response];
            if ([medicationListArray count] == 0) {
                medicationListArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"NO_MEDICATIONS", @"")]];
            }
            [medicationListTableView reloadData];
        } else {
            NSInteger errorCode = [[errorDict valueForKey:@"code"] integerValue];
            if (errorCode != NSURLErrorCancelled) {
                medicationListArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"NO_MEDICATIONS", @"")]];
                [medicationListTableView reloadData];
                if (errorCode == NETWORK_NOT_REACHABLE) {
                    [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
                } else if (errorCode == NSURLErrorTimedOut) {
                    //time out error here
                    [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:@"Webservice call has timed out."];
                } else {
                    DDLogError(@"error response info %ld", (long)errorCode);
                }
            }
        }
    }];
}
- (NSString *)medicationNameFromIndexPath :(NSIndexPath *)indexPath {
    
    if ([[medicationListArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedication class]]) {
        DCMedication *searchMedication = [medicationListArray objectAtIndex:indexPath.row];
        return searchMedication.name ;
    } else {
        return (NSString *)[medicationListArray objectAtIndex:indexPath.row];
    }
}

- (void)callWarningsWebServiceForMedication:(DCMedication *)medicationDetails {
    
    DCContraIndicationWebService *webService = [[DCContraIndicationWebService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicator startAnimating];
    });
    [webService getContraIndicationsForPatientWithId:_patientId forDrugPreparationId:medicationDetails.medicationId withCallBackHandler:^(NSArray *alergiesArray, NSError *error) {
        if (!error) {
            warningsArray = [NSMutableArray arrayWithArray:[DCUtility categorizeContentArrayBasedOnSeverity:alergiesArray]];
            NSArray *severeArray = [[warningsArray objectAtIndex:0] valueForKey:SEVERE_WARNING];
            NSArray *mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
            updatedMedication = [[DCMedication alloc] init];
            updatedMedication.name = medicationDetails.name;
            updatedMedication.medicationId = medicationDetails.medicationId;
            updatedMedication.dosage = medicationDetails.dosage;
            updatedMedication.routeArray = medicationDetails.routeArray;
            updatedMedication.severeWarningCount = severeArray.count;
            updatedMedication.mildWarningCount = mildArray.count;
            if ([severeArray count] == 0 && [mildArray count] == 0) {
                //if there are no allergies nor severe warning, dismiss view
                self.selectedMedication (updatedMedication, warningsArray);
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                //display severe warning view here
               // [self performSelector:@selector(displayWarningsListView) withObject:nil afterDelay:0.01];
                [self displayWarningsListView];
            }
        }
        medicationListTableView.userInteractionEnabled = YES;
        [activityIndicator stopAnimating];
    }];
}

- (void)displayWarningsListView {
    
    //display Warnings list view
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    warningsListViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:WARNINGS_LIST_STORYBOARD_ID];
    warningsListViewController.delegate = self;
    [self.navigationController pushViewController:warningsListViewController animated:YES];
    [warningsListViewController populateWarningsListWithWarnings:warningsArray showOverrideView:YES];
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [medicationListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize stepSize = [DCUtility requiredSizeForText:[self medicationNameFromIndexPath:indexPath]
                                                   font:[UIFont systemFontOfSize:15.0f]
                                               maxWidth:294];
    CGFloat searchCellHeight = CELL_PADDING + stepSize.height;
    searchCellHeight = searchCellHeight < CELL_MININUM_HEIGHT? CELL_MININUM_HEIGHT :searchCellHeight ;
    return searchCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = MEDICATION_LIST_CELL_IDENTIFIER;
    DCMedicationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DCMedicationListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.medicationNameLabel.text = [self medicationNameFromIndexPath:indexPath];
    if ([[medicationListArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedication class]]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.userInteractionEnabled = NO;// to disable  multiple selection
    [self.view endEditing:YES];
    if ([[medicationListArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedication class]]) {
        DCMedication *medication = [medicationListArray objectAtIndex:indexPath.row];
        [self callWarningsWebServiceForMedication:medication];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        [activityIndicator stopAnimating];
    }
}

#pragma mark - UISearch bar implementation

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    searchBar.text = EMPTY_STRING;
    [searchBar resignFirstResponder];
    [medicationListTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchedBar textDidChange:(NSString *)searchText {
    
    if (searchText.length > 0) {
        // Search and Reload data source
        if (searchText.length < SEARCH_ENTRY_MIN_LENGTH) {
            medicationListArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"SEARCH_MEDICATION_MIN_LIMIT", @"")]];
            [medicationListTableView reloadData];
        } else {
            medicationListArray = [NSMutableArray arrayWithArray:@[]];
            [medicationListTableView reloadData];
            [self fetchMedicationListForString:searchText];
        }
    } else {
        medicationSearchBar.showsCancelButton = NO;
        [medicationListTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.view endEditing:YES];
}

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Warnings Delegate Methods

- (void)overrideReasonSubmitted:(NSString * __nonnull)reason {
    
    updatedMedication.overriddenReason = reason;
    self.selectedMedication (updatedMedication, warningsArray);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
