//
//  DCAdministrationStatusTableViewController.m
//  DrugChart
//
//  Created by aliya on 14/10/15.
//
//

#import "DCAdministrationStatusTableViewController.h"
#import "DCDatePickerCell.h"
#import "DCUser.h"
#import "DrugChart-Swift.h"

#define TABLE_REUSE_IDENTIFIER @"StatusCell"

@interface DCAdministrationStatusTableViewController () <NamesListDelegate> {
    
}

@end

@implementation DCAdministrationStatusTableViewController{
    BOOL isSecondSectionExpanded;
    BOOL isDatePickerExpanded;
    int rowCount;
    NSMutableArray *usersListArray;
    NSString *checkedByUser;
}

#pragma mark - View Management Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restartedDate = EMPTY_STRING;
    checkedByUser = EMPTY_STRING;
    [self fetchAdministersAndPrescribersList];
    self.navigationController.navigationBarHidden = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureStatusArrayWithStatusValue];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStatusArrayWithStatusValue {
    if ([self.status  isEqual: ADMINISTER_NOW]) {
        _namesArray = @[STARTED, NOT_ADMINISTRATED];
    } else if ([self.status  isEqual: IN_PROGRESS]){
        _namesArray = @[ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED];
    } else {
        _namesArray = @[ADMINISTERED, NOT_ADMINISTRATED];
    }
}

#pragma mark - Table View Data Source Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSecondSectionExpanded) {
        return 2;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        if(indexPath.row == 1) {
            if (isDatePickerExpanded) {
                return 216;
            }
        } else if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
            return 125;
        }
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = rowCount;
    switch (section) {
        case 1:
            if(isDatePickerExpanded) {
                row++;
            }
            return row;
        default:
            return [_namesArray count];
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLE_REUSE_IDENTIFIER];
            }
            NSString *statusString = [_namesArray objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.text = statusString;
            cell.accessoryType = ([statusString isEqualToString:_previousSelectedValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case 1:
            if ([_status isEqualToString: FLUID_CHANGED]) {
                switch (indexPath.row) {
                    case 0:{
                        DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                        cell.titleLabel.text = @"Restarted on";
                        cell.detailLabel.text =  self.restartedDate;
                        return cell;}
                    case 1:{
                        if(isDatePickerExpanded) {
                            DCDatePickerCell *pickerCell = [self datePickerTableCell];
                            return pickerCell;
                        } else {
                            return [self checkedByCellAtIndexPath:indexPath];
                        }
                    }
                    case 2:{
                        if (isDatePickerExpanded) {
                            return [self checkedByCellAtIndexPath:indexPath];
                        } else {
                            return [self configureBatchCellWithText:@"Batch No" AtIndexPath:indexPath];
                        }
                    }
                    case 3:{
                        if (isDatePickerExpanded) {
                            // Batch number cell
                            return [self configureBatchCellWithText:@"Batch No" AtIndexPath:indexPath];
                        } else {
                            // expiry date cell
                            return [self configureBatchCellWithText:@"Expiry Date" AtIndexPath:indexPath];
                        }
                    }
                    default:{
                        return [self configureBatchCellWithText:@"Expiry Date" AtIndexPath:indexPath];
                    }
                }
                
            } else  if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
                return [self notesCellAtIndexPath:indexPath];
            }
        default:
            return nil;
    }
}

- (DCAdministerCell *)configureAdministrationCellAtIndexPath: (NSIndexPath *)indexPath {
    
    DCAdministerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AdministerTableCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCAdministerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdministerTableCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (DCBatchNumberCell *)configureBatchCellWithText :(NSString *)placeholder AtIndexPath : (NSIndexPath *)indexPath {
    //batch number or expiry field
    DCBatchNumberCell *batchCell = [self.tableView dequeueReusableCellWithIdentifier:@"BatchNumberTableCell" forIndexPath:indexPath];
    if (batchCell == nil) {
        batchCell = [[DCBatchNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BatchNumberTableCell"];
    }
    batchCell.selectedIndexPath = indexPath;
    if (indexPath.row == 2) {
        batchCell.batchNumberTextField.placeholder = @"Expiry Date";
    } else {
        batchCell.batchNumberTextField.placeholder = @"Batch No";
    }
    return batchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected medication status to parent
    if (indexPath.section == 0) {
        _status = [_namesArray objectAtIndex:indexPath.item];
        _previousSelectedValue = _status;
        [self collapseOpenedSection];
        if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
            isSecondSectionExpanded = YES;
            rowCount = 1;
            [self insertSection];
            [self.tableView reloadData];
        } else if ([_status isEqualToString: FLUID_CHANGED]) {
            isSecondSectionExpanded = YES;
            rowCount = 4;
            [self insertSection];
            [self.tableView reloadData];
        } else {
            isSecondSectionExpanded = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.medicationStatusDelegate && [self.medicationStatusDelegate respondsToSelector:@selector(selectedMedicationStatusEntry:)]) {
            [self.medicationStatusDelegate selectedMedicationStatusEntry:_status];
        }
    } else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:{
                [self displayDatePickerAtIndexPath:indexPath];
            }
                break;
            case 1:{
                if (!isDatePickerExpanded) {
                    [self displayPrescribersAndAdministersViewAtIndexPath:indexPath];
                }
            }
            case 2:{
                if (isDatePickerExpanded) {
                    [self displayPrescribersAndAdministersViewAtIndexPath:indexPath];
                }
            }
                break;
            default:
                break;
        }
    }
}

-(void)insertSection {
    
    [self.tableView beginUpdates];
    if (isSecondSectionExpanded) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (void)collapseOpenedSection {
    if (isSecondSectionExpanded) {
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        isSecondSectionExpanded = NO;
        [self.tableView endUpdates];
    }
}

- (DCAdministerCell *) checkedByCellAtIndexPath : (NSIndexPath *)indexPath {
    
    DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
    cell.titleLabel.text = NSLocalizedString(@"CHECKED_BY", comment: @"Checked by title");
    cell.detailLabel.text =  checkedByUser;
    return cell;
}

- (DCNotesTableCell *)notesCellAtIndexPath :(NSIndexPath *)indexPath {
    DCNotesTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NotesTableCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCNotesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesTableCell"];
    }
    cell.noteType = @"Notes";
    cell.selectedIndexPath = indexPath;
    cell.notesTextView.text = [cell hintText];
    return cell;
}

- (DCDatePickerCell *)datePickerTableCell {
    
    static NSString *pickerCellId = DATE_STATUS_PICKER_CELL_IDENTIFIER;
    DCDatePickerCell *pickerCell = [self.tableView dequeueReusableCellWithIdentifier:pickerCellId];
    if (pickerCell == nil) {
        pickerCell = [[DCDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pickerCellId];
    }
    [pickerCell configureDatePickerProperties];
    pickerCell.selectedDate = ^ (NSDate *date) {
        self.restartedDate = [DCDateUtility dateStringFromDate:date inFormat:START_DATE_FORMAT];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    };
    return pickerCell;
}

- (void)displayDatePickerAtIndexPath : (NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    if (isDatePickerExpanded) {
        // display the date picker inline with the table content
        isDatePickerExpanded = NO;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:1]]
                                          withRowAnimation:UITableViewRowAnimationFade];
    } else {
        isDatePickerExpanded = YES;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:1]]
                                          withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (void)displayPrescribersAndAdministersViewAtIndexPath :(NSIndexPath *)indexPath {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    DCNameSelectionTableViewController *namesViewController = [administerStoryboard instantiateViewControllerWithIdentifier:NAMES_LIST_VIEW_STORYBOARD_ID];
    namesViewController.title = CHECKED_BY;
    namesViewController.namesDelegate = self;
    namesViewController.namesArray = usersListArray;
    [self.navigationController pushViewController:namesViewController animated:YES];
}

- (void)fetchAdministersAndPrescribersList{
    
    usersListArray = [[NSMutableArray alloc] init];
    //fetch administers and prescribers list
    DCUsersListWebService *usersListWebService = [[DCUsersListWebService alloc] init];
    [usersListWebService getUsersListWithCallback:^(NSArray *usersList, NSError *error) {
        if (!error) {
            for(NSDictionary *userDictionary in usersList) {
                NSString *displayName = [userDictionary valueForKey:DISPLAY_NAME_KEY];
                NSString *identifier = [userDictionary valueForKey:IDENTIFIER_KEY];
                DCUser *user = [[DCUser alloc] init];
                user.displayName = displayName;
                user.userIdentifier = identifier;
                [usersListArray addObject:user];
            }
        }
    }];
}
- (void)selectedUserEntry:(DCUser *)user {
    checkedByUser = user.displayName;
    [self.tableView reloadData];
}

@end
