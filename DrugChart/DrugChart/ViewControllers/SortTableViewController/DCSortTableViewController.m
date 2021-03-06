//
//  DCSortTableViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 8/19/15.
//
//

#import "DCSortTableViewController.h"
#import "DCSortTableCell.h"

#define PATIENT_LIST_SECTION_COUNT 1
#define CALENDAR_SECTION_COUNT 2
#define SECTION_HEIGHT_INITIAL_SECTION 34.0f
#define SECTION_HEIGHT_NORMAL 10.0f

#define NAME @"Name"
#define DATE @"Date"

@interface DCSortTableViewController () {
    
    NSArray *contentArray;
    
}

@end

@implementation DCSortTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (DCSortTableCell *)configureTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
    
    //configure sort table cell
    DCSortTableCell *sortCell = [self.tableView dequeueReusableCellWithIdentifier:SORT_CELL_IDENTIFIER];
    if (sortCell == nil) {
        sortCell = [[DCSortTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:SORT_CELL_IDENTIFIER];
    }
    sortCell.layoutMargins = UIEdgeInsetsZero;
    sortCell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    if (_sortView == ePatientList) {
        sortCell.textLabel.text = [contentArray objectAtIndex:indexPath.row];
    } else {
        NSString *selectedCriteria = [[contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        sortCell.textLabel.text = selectedCriteria;
        if (indexPath.section == 0) {
            sortCell.accessoryType = _showDiscontinuedMedications ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else if ([selectedCriteria isEqualToString:_previousSelectedCategory]) {
            sortCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return sortCell;
}

- (void)configureViewElements {
    
   // self.tableView.layoutMargins = UIEdgeInsetsMake(-1, 0.0, 0.0, 0.0);
    [self populateContentArray];
    [self configureNavigationBarProperties];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    
    [self displayNavigationBarBasedOnSizeClass];
    [super viewDidLayoutSubviews];
}

- (void)configureNavigationBarProperties {
    
    self.title = NSLocalizedString(@"SORT", @"");
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
   
}

- (void)displayNavigationBarBasedOnSizeClass {
    
    //display navigation bar only for 1/2 or 1/3 screens
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSInteger windowWidth = [DCUtility mainWindowSize].width;
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        if (windowWidth > screenWidth/2) {
            [self showNavigationBar:NO];
        } else {
             [self showNavigationBar:YES];
        }
    } else {
        if (windowWidth <= screenWidth) {
            [self showNavigationBar:YES];
        } else {
            [self showNavigationBar:NO];
        }
    }
}

- (void)showNavigationBar:(BOOL)show {
    
    if (show) {
        [self.tableView setContentInset:UIEdgeInsetsMake(60, 0, 0, 0)];
        self.navigationController.navigationBar.hidden = NO;
    } else {
        self.navigationController.navigationBar.hidden = YES;
        [self.tableView setContentInset:UIEdgeInsetsZero];
    }
}

- (void)populateContentArray {
    
    if (_sortView == eCalendarView) {
        if (_showDiscontinuedMedications) {
            contentArray = @[@[INCLUDE_DISCONTINUED], @[START_DATE_ORDER, ALPHABETICAL_ORDER, SORT_ACTIVE_FIRST]];
        } else {
            contentArray = @[@[INCLUDE_DISCONTINUED], @[START_DATE_ORDER, ALPHABETICAL_ORDER]];
        }
    } else {
        contentArray = @[NAME, DATE];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSUInteger sectionCount = (_sortView == ePatientList) ? PATIENT_LIST_SECTION_COUNT : CALENDAR_SECTION_COUNT;
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (_sortView == ePatientList) {
        return [contentArray count];
    } else {
        return [[contentArray objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DCSortTableCell *sortCell = [self configureTableViewCellAtIndexPath:indexPath];
    return sortCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return SECTION_HEIGHT_INITIAL_SECTION;
    } else {
        return SECTION_HEIGHT_NORMAL;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedValue;
    if (_sortView == ePatientList) {
        selectedValue = [contentArray objectAtIndex:indexPath.row];
    } else {
        selectedValue = [[contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    self.criteria (selectedValue);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
