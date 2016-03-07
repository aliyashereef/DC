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

#define SYSTEM_FONT_FIFTEEN [UIFont systemFontOfSize:15]
#define WIDTH_ALERT_NAME_LABEL 275
#define ALERT_CELL_HEIGHT_MIN 34
#define ALERT_CELL_HEIGHT_MAX 390
#define ALERT_CELL_PADDING 10
#define CELL_PADDING 35
#define ALERT_CELL_HEIGHT 35.0f

@interface DCAlertsAllergyPopOverViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *cellHeightArray;
    NSMutableArray *popOverDisplayArray;
    IBOutlet UITableView *alertsAllergyTableView;
}

@end

@implementation DCAlertsAllergyPopOverViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureNavigationBarItems];
    alertsAllergyTableView.estimatedRowHeight = ALERT_CELL_HEIGHT;
    alertsAllergyTableView.rowHeight = UITableViewAutomaticDimension;
    popOverDisplayArray = [NSMutableArray arrayWithArray:self.patientsAlertsArray];
    [popOverDisplayArray addObjectsFromArray:self.patientsAllergyArray];
    [alertsAllergyTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    self.preferredContentSize = alertsAllergyTableView.contentSize;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.viewDismissed();
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionCount = 0;
    if (self.patientsAlertsArray.count > 0) {
        sectionCount++;
    }
    if (self.patientsAllergyArray.count > 0) {
        sectionCount++;
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.patientsAlertsArray.count > 0) {
            return self.patientsAlertsArray.count;
        } else if (self.patientsAllergyArray.count > 0) {
            return self.patientsAllergyArray.count;
        }
    } else {
        return self.patientsAllergyArray.count;
    }
    return 0;
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
    if (indexPath.section == 0) {
        if (self.patientsAlertsArray.count > 0) {
            DCPatientAlert *patientAlert = [self.patientsAlertsArray objectAtIndex:indexPath.item];
            [patientAlertsAllergyTableViewCell configurePatientsAlertCell:patientAlert];
        } else if (self.patientsAllergyArray.count > 0) {
            DCPatientAllergy *patientAllergy = [self.patientsAllergyArray objectAtIndex:indexPath.item];
            [patientAlertsAllergyTableViewCell configurePatientsAllergyCell:patientAllergy];
        }
    } else {
        DCPatientAllergy *patientAllergy = [self.patientsAllergyArray objectAtIndex:indexPath.item];
        [patientAlertsAllergyTableViewCell configurePatientsAllergyCell:patientAllergy];
    }
    return patientAlertsAllergyTableViewCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.patientsAlertsArray.count > 0) {
            return NSLocalizedString(@"ALERTS", "");
        } else if (self.patientsAllergyArray.count > 0) {
            return NSLocalizedString(@"ALLERGIES", "");
        }
    } else {
        return NSLocalizedString(@"ALLERGIES", "");
    }
    return EMPTY_STRING;
}

#pragma mark - Private Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    //cancel button action
    self.viewDismissed();
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureNavigationBarItems {
    
    self.title = NSLocalizedString(@"WARNINGS", @"");
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
}

@end
