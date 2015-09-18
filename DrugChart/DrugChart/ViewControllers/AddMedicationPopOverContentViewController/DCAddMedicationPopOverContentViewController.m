//
//  DCAddMedicationPopOverContentViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 4/17/15.
//
//

#import "DCAddMedicationPopOverContentViewController.h"
#import "DCPlistManager.h"
#import "DCAddNewDosageCell.h"
#import "DCPopOverTableViewCell.h"

#define TABLECELL_IDENTIFIER @"AddMedicationCellIdentifier"
#define TICK_IMAGE @"AddNewTick"

@interface DCAddMedicationPopOverContentViewController () <UITextFieldDelegate> {
    
    NSMutableArray *contentArray;
    NSMutableArray *medicineListArray;
    BOOL isSearching;
}

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation DCAddMedicationPopOverContentViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    [self populateViewForSelectedContentType];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.view.superview.layer.cornerRadius = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLayoutSubviews {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    [super viewDidLayoutSubviews];
    
}

#pragma mark _ Private Methods

- (void)configureViewElements {
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90.0;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    [self.view clipsToBounds];
}

- (void)populateViewForSelectedContentType {
    
    contentArray = [[NSMutableArray alloc] init];
    switch (_contentType) {
        case eRoute:
            [self getMedicationRoutesList];
            break;
        case eMedicationType:
            [self getMedicationTypes];
            break;
        case eMedicationName:
            [self getMedicationNames];
            break;
        case eDosage:
            [self getDosagesList];
            break;
        default:
            break;
    }
}

- (void)getMedicationRoutesList {
    
    //get Medication routes
    contentArray = [NSMutableArray arrayWithArray:[DCPlistManager getMedicationRoutesList]];
    [self.tableView reloadData];
}

- (void)getMedicationTypes {
    
    contentArray = [NSMutableArray arrayWithArray:@[REGULAR_MEDICATION, ONCE_MEDICATION, @"When Required"]];
}

- (void)getMedicationNames {
    
    contentArray = [NSMutableArray arrayWithArray:[DCPlistManager getMedicineNamesList]];
    medicineListArray = contentArray;
}

- (void)getDosagesList {
    
    //currently hard coded values
    if ([_dosageArray count] > 0) {
        contentArray = [NSMutableArray arrayWithArray:_dosageArray];
    } else {
        contentArray = [NSMutableArray arrayWithArray:@[]];
    }
}

- (void)searchMedicineListWithText:(NSString *)searchText {
    
    NSString *medicineNameString = [NSString stringWithFormat:@"name contains[c] '%@'", searchText];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:medicineNameString];
    contentArray = (NSMutableArray *)[medicineListArray filteredArrayUsingPredicate:searchPredicate];
    [self.tableView reloadData];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_contentType == eDosage) {
        return [contentArray count] + 1;
    } else {
         return [contentArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_contentType == eDosage && indexPath.row == 0) {
        
        DCAddNewDosageCell *newDosageCell = (DCAddNewDosageCell *)[[[NSBundle mainBundle] loadNibNamed:@"DCAddNewDosageCell" owner:self options:nil] objectAtIndex:0];
        __weak typeof(DCAddNewDosageCell *) weakdosageCell = newDosageCell;
        newDosageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newDosageCell.separatorInset = UIEdgeInsetsZero;
        newDosageCell.layoutMargins = UIEdgeInsetsZero;
        newDosageCell.newDosageAdded = ^ (NSString *dosage) {
            [contentArray addObject:dosage];
            self.selectedDosage = dosage;
            weakdosageCell.addNewTextField.text = NSLocalizedString(@"ADD_NEW", @"");
            [self.tableView reloadData];
            self.newDosageRecieved(dosage);
        };
        
        return newDosageCell;
    } else {
        
        DCPopOverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLECELL_IDENTIFIER forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DCPopOverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLECELL_IDENTIFIER];
        }
        cell.separatorInset = UIEdgeInsetsZero;
        cell.titleLabel.numberOfLines = 0;
        cell.titleLabel.font = [DCFontUtility getLatoRegularFontWithSize:14.0f];
        cell.layoutMargins = UIEdgeInsetsZero;
        NSString *content;
        if (_contentType == eDosage) {
            content = [contentArray objectAtIndex:indexPath.row - 1];
            if ([self.selectedDosage isEqualToString:content]) {
                
                [cell.accessorySelectionImageView setImage:[UIImage imageNamed:TICK_IMAGE]];
            } else {
                
                [cell.accessorySelectionImageView setImage:nil];
            }

        } else {
            content = [contentArray objectAtIndex:indexPath.row];
             [cell.accessorySelectionImageView setImage:nil];
        }
        if (_contentType == eMedicationName) {
            cell.titleLabel.text = [content valueForKey:@"name"];
        } else {
            cell.titleLabel.text = content;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedValue;
    if (indexPath.row == 0 && _contentType == eDosage) {
        // Do nothing
    } else {
        if (_contentType == eDosage && indexPath.row != 0) {
            selectedValue = [contentArray objectAtIndex:indexPath.row - 1];
        } else {
            selectedValue = [contentArray objectAtIndex:indexPath.row];
        }
        NSDictionary *notificationInfo = @{@"value" : selectedValue, @"contentType" : [NSNumber numberWithInteger:self.contentType]};
        self.entrySelected (notificationInfo);
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0f;
}

@end
