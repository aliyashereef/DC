//
//  DCAlertsAllergyPopOverViewController.m
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import "DCAlertsAllergyPopOverViewController.h"
#import "DCAlertsAllergyTableViewCell.h"
#import "DCPatientAlert.h"
#import "DCPatientAllergy.h"

#define LATO_REGULAR_FIFTEEN [UIFont fontWithName:@"Lato-Regular" size:15]
#define WIDTH_ALERT_NAME_LABEL 280
#define ALERT_CELL_HEIGHT_MIN 34
#define ALERT_CELL_HEIGHT_MAX 390
#define ALERT_CELL_PADDING 30
#define CELL_PADDING 55

@interface DCAlertsAllergyPopOverViewController () {
    
    NSMutableArray *cellHeightArray;
    NSMutableArray *popOverDisplayArray;
    IBOutlet UITableView *alertsAllergyTableView;
}

@end

@implementation DCAlertsAllergyPopOverViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureNavigationBarItems];
    popOverDisplayArray = [NSMutableArray arrayWithArray:self.patientsAlertsArray];
    [self getAllergyAndAlertDisplayTableViewHeightForContent:popOverDisplayArray];
    [alertsAllergyTableView setSeparatorInset:UIEdgeInsetsZero];
    [alertsAllergyTableView setLayoutMargins:UIEdgeInsetsZero];
    [alertsAllergyTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [popOverDisplayArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCAlertsAllergyTableViewCell *patientAlertsAllergyTableViewCell =
    [tableView dequeueReusableCellWithIdentifier:PATIENT_ALERTS_ALLERGY_CELL_IDENTIFIER
                                    forIndexPath:indexPath];
    if (patientAlertsAllergyTableViewCell == nil) {
        patientAlertsAllergyTableViewCell =
        [[DCAlertsAllergyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:PATIENT_ALERTS_ALLERGY_CELL_IDENTIFIER];
    }
    patientAlertsAllergyTableViewCell.layoutMargins = UIEdgeInsetsZero;
    if ([[popOverDisplayArray objectAtIndex:indexPath.item] isKindOfClass:[DCPatientAlert
                                                                            class]] ) {
        DCPatientAlert *patientAlert = [popOverDisplayArray objectAtIndex:indexPath.item];
        [patientAlertsAllergyTableViewCell configurePatientsAlertCell:patientAlert];
    } else {
        DCPatientAllergy *patientAllergy = [popOverDisplayArray objectAtIndex:indexPath.item];
        [patientAlertsAllergyTableViewCell configurePatientsAllergyCell:patientAllergy];
    }
    return patientAlertsAllergyTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    CGFloat heightForCell = [[cellHeightArray objectAtIndex:indexPath.row] floatValue];
    return (heightForCell > ALERT_CELL_HEIGHT_MIN ? heightForCell : ALERT_CELL_HEIGHT_MIN);
}

- (CGFloat )getAllergyAndAlertDisplayTableViewHeightForContent:(NSArray *)displayArray {
    
    cellHeightArray = [[NSMutableArray alloc] init];
    CGFloat totalAlertCellsHeight = 35.0f;
    for (int index = 0; index < displayArray.count; index++) {
        CGSize stepSize;
        if ([[displayArray objectAtIndex:index] isKindOfClass:[DCPatientAlert
                                                                               class]] ) {
            DCPatientAlert *patientAlert = [displayArray objectAtIndex:index];
            stepSize = [DCUtility getRequiredSizeForText:patientAlert.alertText
                                                           font:LATO_REGULAR_FIFTEEN
                                                       maxWidth:WIDTH_ALERT_NAME_LABEL];
        } else {
            DCPatientAllergy *patientAllergy = [displayArray objectAtIndex:index];
            stepSize = [DCUtility getRequiredSizeForText:patientAllergy.allergyName
                                                    font:LATO_REGULAR_FIFTEEN
                                                maxWidth:WIDTH_ALERT_NAME_LABEL];

        }
        CGFloat alertCellHeight = ALERT_CELL_PADDING + stepSize.height ;
        [cellHeightArray addObject:[NSNumber numberWithFloat:alertCellHeight]];
        totalAlertCellsHeight += alertCellHeight;
    }
    return totalAlertCellsHeight;
}

- (CGFloat)getTableViewHeightwithArray :(NSArray *)displayArray {
    
    CGFloat totalAlertCellsHeight = [self getAllergyAndAlertDisplayTableViewHeightForContent:displayArray];
    CGFloat heightForFirstCell = [[cellHeightArray objectAtIndex:0] floatValue];
    if (displayArray.count == 1) {
        return heightForFirstCell;
    }
    else {
        if (totalAlertCellsHeight > ALERT_CELL_HEIGHT_MAX || displayArray.count > 5) {
            return ALERT_CELL_HEIGHT_MAX;
        }
        return totalAlertCellsHeight;
    }
}
#pragma mark - Private Methods

- (IBAction)segmentSelectionChanged:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
            popOverDisplayArray = [NSMutableArray arrayWithArray:self.patientsAlertsArray];
    } else {
            popOverDisplayArray = [NSMutableArray arrayWithArray:self.patientsAllergyArray];
    }
    [self getAllergyAndAlertDisplayTableViewHeightForContent:popOverDisplayArray];
    [alertsAllergyTableView reloadData];
    self.preferredContentSize = CGSizeMake(ALERT_ALLERGY_CELL_WIDTH,alertsAllergyTableView.contentSize.height + CELL_PADDING );
    [self forcePopoverSize];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    //cancel button action
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) forcePopoverSize {
    
    CGSize currentSetSizeForPopover = self.preferredContentSize;
    CGSize momentarySize = CGSizeMake(currentSetSizeForPopover.width, currentSetSizeForPopover.height - 1.0f);
    self.preferredContentSize = momentarySize;
    self.navigationController.preferredContentSize = momentarySize;
    self.preferredContentSize = currentSetSizeForPopover;
    self.navigationController.preferredContentSize = momentarySize;
}

- (void)configureNavigationBarItems {
    
    self.title = NSLocalizedString(@"WARNINGS", @"");
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
}

@end
