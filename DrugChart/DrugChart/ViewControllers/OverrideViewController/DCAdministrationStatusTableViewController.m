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
    int rowCount;
    NSMutableArray *usersListArray;
    NSString *checkedByUser;
    NSIndexPath *datePickerIndexPath;
}

#pragma mark - View Management Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.restartedDate = EMPTY_STRING;
    checkedByUser = EMPTY_STRING;
    datePickerIndexPath = nil;
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
        if ([self indexPathHasPicker:indexPath]) {
                return 216;
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
            if([self hasInlineDatePicker]) {
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
                        if([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                            DCDatePickerCell *pickerCell = [self datePickerTableCell];
                            return pickerCell;
                        } else {
                            return [self checkedByCellAtIndexPath:indexPath];
                        }
                    }
                    case 2:{
                        if ([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                            return [self checkedByCellAtIndexPath:indexPath];
                        } else {
                            return [self configureBatchCellWithText:@"Batch No" AtIndexPath:indexPath];
                        }
                    }
                    case 3:{
                        if ([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                            // Batch number cell
                            return [self configureBatchCellWithText:@"Batch No" AtIndexPath:indexPath];
                        } else {
                            // expiry date cell
                            DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                            cell.titleLabel.text = @"Expiry Date";
                            cell.detailLabel.text = self.expiryDate;
                            return cell;
                        }
                    }
                    case 4:
                        if ([self hasInlineDatePicker] && datePickerIndexPath == indexPath) {
                            DCDatePickerCell *pickerCell = [self datePickerTableCell];
                            return pickerCell;
                        } else {
                            DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                            cell.titleLabel.text = @"Expiry Date";
                            cell.detailLabel.text = self.expiryDate;
                            return cell;
                        }
                    default:{
                        DCDatePickerCell *pickerCell = [self datePickerTableCell];
                        return pickerCell;
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
        batchCell.batchNumberTextField.placeholder = placeholder;
    return batchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected medication status to parent
    if (indexPath.section == 0) {
        datePickerIndexPath = nil;
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
                    [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
                break;
            case 1:{
                if (![self hasInlineDatePicker] || datePickerIndexPath.row != 1) {
                    [self displayPrescribersAndAdministersViewAtIndexPath:indexPath];
                }
            }
                break;
            case 2:{
                if ([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                    [self displayPrescribersAndAdministersViewAtIndexPath:indexPath];
                }
            }
                break;
            case 3:{
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
                break;
            case 4:{
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
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
        if (datePickerIndexPath.row  == 1) {
            self.restartedDate = [DCDateUtility dateStringFromDate:date inFormat:START_DATE_FORMAT];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            self.expiryDate = [DCDateUtility dateStringFromDate:date inFormat:START_DATE_FORMAT];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerIndexPath.row-1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }
       
    };
    return pickerCell;
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
// MARK: Date Picker Methods

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath {
    BOOL hasDatePicker = NO;
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    UITableViewCell *checkDatePickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:indexPath.section]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:99];
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
    return ([self hasInlineDatePicker] && datePickerIndexPath.row == indexPath.row);
}

- (BOOL)hasInlineDatePicker {
    return (datePickerIndexPath != nil);
}

- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker]) {
        before = datePickerIndexPath.row < indexPath.row;
    }
    BOOL sameCellClicked = (datePickerIndexPath.row - 1 == indexPath.row);
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker]) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerIndexPath.row inSection:1]]
                                          withRowAnimation:UITableViewRowAnimationFade];
        datePickerIndexPath = nil;
    }
    if (!sameCellClicked) {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:indexPath.section];
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:indexPath.section];
    }
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
}

- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath]) {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                                          withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                                          withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

@end
