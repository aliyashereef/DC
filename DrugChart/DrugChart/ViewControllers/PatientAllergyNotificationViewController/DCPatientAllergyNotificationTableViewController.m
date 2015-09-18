//
//  DCPatientAllergyNotificationTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCPatientAllergyNotificationTableViewController.h"
#import "DCAlergyDisplayCell.h"
#import "DCPatientAllergy.h"

#define ALLERGY_CELL_HEIGHT_MIN 65
#define ALLERGY_CELL_HEIGHT_MAX 389
#define WIDTH_ALLERGY_NAME_LABEL 313
#define WIDTH_REACTION_LABEL 255
#define LATO_REGULAR_FIFTEEN [UIFont fontWithName:@"Lato-Regular" size:15]
#define LATO_REGULAR_TWELVE [UIFont fontWithName:@"Lato-Regular" size:12]
#define CELL_PADDING 50


@interface DCPatientAllergyNotificationTableViewController () {
    NSMutableArray *cellHeightArray;
}

@end

@implementation DCPatientAllergyNotificationTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        cellHeightArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.view.superview.layer.cornerRadius = 2.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBar {
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor getColorForHexString:@"#4dc8e9"]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor getColorForHexString:@"#ffffff"], NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:15.0]};
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_allergiesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCAlergyDisplayCell *alergyDisplayCell = [tableView dequeueReusableCellWithIdentifier:ALLERGY_NOTIFICATION_CELL_IDENTIFIER];
    if (alergyDisplayCell == nil) {
        alergyDisplayCell = [[DCAlergyDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:ALLERGY_NOTIFICATION_CELL_IDENTIFIER];
    }
    DCPatientAllergy *patientAllergy = [_allergiesArray objectAtIndex:indexPath.row];
    [alergyDisplayCell configurePatientAllergyCell:patientAllergy];
    return alergyDisplayCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    CGFloat heightForCell = [[cellHeightArray objectAtIndex:indexPath.row] floatValue];
    return (heightForCell > ALLERGY_CELL_HEIGHT_MIN ? heightForCell : ALLERGY_CELL_HEIGHT_MIN);
}

#pragma mark - Private Methods

- (CGFloat )computeTotalCellsHeightAndPrepareCellHeightsArrayForAllergyTableView {

    cellHeightArray = [[NSMutableArray alloc] init];
    CGFloat totalAllergyCellsHeight;
    
    return totalAllergyCellsHeight;
}

- (CGFloat)getTableViewHeight {
    
    CGFloat totalAllergyCellsHeight = [self computeTotalCellsHeightAndPrepareCellHeightsArrayForAllergyTableView];
    if (_allergiesArray.count == 1) {
        CGFloat heightForFirstCell = [[cellHeightArray objectAtIndex:0] floatValue];
        return heightForFirstCell;
    }
    else {
        if (totalAllergyCellsHeight > ALLERGY_CELL_HEIGHT_MAX || _allergiesArray.count > 5) {
            return ALLERGY_CELL_HEIGHT_MAX;
        }
        return totalAllergyCellsHeight;
    }
}

@end