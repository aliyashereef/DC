//
//  DCAdministrationStatusTableViewController.m
//  DrugChart
//
//  Created by aliya on 14/10/15.
//
//

#import "DCAdministrationStatusTableViewController.h"

#import "DCUser.h"
#import "DrugChart-Swift.h"

#define TABLE_REUSE_IDENTIFIER @"StatusCell"

@interface DCAdministrationStatusTableViewController () <NamesListDelegate, NotesCellDelegate, BatchCellDelegate , AdministrationDateDelegate> {
    
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
    usersListArray = [DCAdministrationHelper fetchAdministersAndPrescribersList];
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
    [self rowCountAccordingToStatus];
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStatusArrayWithStatusValue {
    if ([self.status  isEqual: ADMINISTER_NOW] || [self.status  isEqual: STARTED]) {
        _namesArray = @[STARTED, NOT_ADMINISTRATED];
    } else if ([self.status  isEqual: IN_PROGRESS] || [@[ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED] containsObject:self.status]){
        _namesArray = @[ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED];
    } else {
        _namesArray = @[ADMINISTERED, NOT_ADMINISTRATED];
    }
}

- (void)rowCountAccordingToStatus {
    
    if ([_previousSelectedValue isEqualToString: STOPED_DUE_TO_PROBLEM] || [_previousSelectedValue isEqualToString:CONTINUED_AFTER_PROBLEM]) {
        isSecondSectionExpanded = YES;
        rowCount = 1;
        [self.tableView reloadData];
    } else if ([_previousSelectedValue isEqualToString: FLUID_CHANGED]) {
        isSecondSectionExpanded = YES;
        rowCount = 4;
        [self.tableView reloadData];
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
        } else if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM] || [_previousSelectedValue isEqualToString: STOPED_DUE_TO_PROBLEM] || [_previousSelectedValue isEqualToString:CONTINUED_AFTER_PROBLEM]) {
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
            if ([_status isEqualToString: FLUID_CHANGED] || [_previousSelectedValue isEqualToString: FLUID_CHANGED]) {
                switch (indexPath.row) {
                    case 0:{
                        DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                        cell.titleLabel.text = @"Restarted on";
                        if (self.medicationSlot.medicationAdministration.restartedDate != nil) {
                            cell.detailLabel.text = [DCDateUtility dateStringFromDate:self.medicationSlot.medicationAdministration.restartedDate inFormat:ADMINISTER_DATE_TIME_FORMAT];
                        }
                        cell.titleLabel.textColor = (!_isValid && self.medicationSlot.medicationAdministration.restartedDate == nil ? [UIColor redColor] : [UIColor blackColor]);
                        return cell;
                    }
                    case 1:{
                        if([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                            DCAdministrationDatePickerCell *pickerCell = [self datePickerTableCell];
                            pickerCell.selectedIndexPath = indexPath;
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
                            return [self expiryDateCellAtIndexPath:indexPath];
                        }
                    }
                    case 4:
                        if ([self hasInlineDatePicker] && datePickerIndexPath == indexPath) {
                            DCAdministrationDatePickerCell *pickerCell = [self datePickerTableCell];
                            pickerCell.selectedIndexPath = indexPath;
                            return pickerCell;
                        } else {
                            return [self expiryDateCellAtIndexPath:indexPath];
                        }
                    default:{
                        DCAdministrationDatePickerCell *pickerCell = [self datePickerTableCell];
                        pickerCell.selectedIndexPath = indexPath;
                        return pickerCell;
                    }
                }
                
            } else  if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM] || [_previousSelectedValue isEqualToString: STOPED_DUE_TO_PROBLEM] || [_previousSelectedValue isEqualToString:CONTINUED_AFTER_PROBLEM]) {
                return [self notesCellAtIndexPath:indexPath];
            }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected medication status to parent
    [self resignKeyboard];
    if (indexPath.section == 0) {
        datePickerIndexPath = nil;
        _status = [_namesArray objectAtIndex:indexPath.item];
        _previousSelectedValue = _status;
        [self collapseOpenedSection];
        if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
            self.medicationSlot.medicationAdministration.administeredNotes = EMPTY_STRING;
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
                    [self collapseOpenedPickerCell];
                    [self displayPrescribersAndAdministersView];
                }
            }
                break;
            case 2:{
                if ([self hasInlineDatePicker] && datePickerIndexPath.row == 1) {
                    [self collapseOpenedPickerCell];
                    [self displayPrescribersAndAdministersView];
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

- (void)dateCellSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL dateValueChanged = NO;
    if (indexPath.row == 0 && self.medicationSlot.medicationAdministration.restartedDate == nil) {
        self.medicationSlot.medicationAdministration.restartedDate = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
        dateValueChanged = YES;
    } else if (self.medicationSlot.medicationAdministration.restartedDate == nil) {
        if (indexPath.row == 3 || indexPath.row ==4 ){
            self.medicationSlot.medicationAdministration.expiryDateTime = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
            dateValueChanged = YES;
        }
    }
    if (dateValueChanged) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self performSelector:@selector(displayInlineDatePickerForRowAtIndexPath:) withObject:indexPath afterDelay:0.1];
    } else {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
}

-(DCAdministerCell *)expiryDateCellAtIndexPath: (NSIndexPath *)indexPath {
    
    DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
        cell.titleLabel.text = @"Expiry Date";
        cell.titleLabel.textColor = [UIColor blackColor];
        if (self.medicationSlot.medicationAdministration.expiryDateTime != nil) {
            cell.detailLabel.text = [DCDateUtility dateStringFromDate:self.medicationSlot.medicationAdministration.expiryDateTime inFormat:EXPIRY_DATE_FORMAT];
        }
    return cell;
}
    
//MARK:Configuring table view cells
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
    batchCell.batchDelegate = self;
    if (self.medicationSlot.medicationAdministration.batch != nil){
        batchCell.batchNumberTextField.placeholder = self.medicationSlot.medicationAdministration.batch;
    } else {
        batchCell.batchNumberTextField.placeholder = @"Batch No";
    }
    return batchCell;
}

- (DCAdministerCell *) checkedByCellAtIndexPath : (NSIndexPath *)indexPath {
    
    DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
    cell.titleLabel.text = NSLocalizedString(@"CHECKED_BY", comment: @"Checked by title");
    cell.detailLabel.text =  self.medicationSlot.medicationAdministration.checkingUser.displayName;
    return cell;
}

- (DCNotesTableCell *)notesCellAtIndexPath :(NSIndexPath *)indexPath {
    DCNotesTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NotesTableCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCNotesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesTableCell"];
    }
    cell.noteType = @"Reason";
    cell.selectedIndexPath = indexPath;
    cell.delegate = self;
    if (self.medicationSlot.medicationAdministration.administeredNotes == nil || [self.medicationSlot.medicationAdministration.administeredNotes  isEqual: EMPTY_STRING]){
        cell.notesTextView.text = [cell hintText];
    } else {
        cell.notesTextView.text = self.medicationSlot.medicationAdministration.administeredNotes;
    }
    return cell;
}

- (DCAdministrationDatePickerCell *)datePickerTableCell {
    
    static NSString *pickerCellId = @"StatusChangePickerCell";
    DCAdministrationDatePickerCell *pickerCell = [self.tableView dequeueReusableCellWithIdentifier:pickerCellId];
    if (pickerCell == nil) {
        pickerCell = [[DCAdministrationDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pickerCellId];
    }
    pickerCell.delegate = self;
    if (datePickerIndexPath.row == 1) {
        pickerCell.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    } else {
        pickerCell.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return pickerCell;
}

//MARK: Private methods

- (void)displayPrescribersAndAdministersView {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    DCNameSelectionTableViewController *namesViewController = [administerStoryboard instantiateViewControllerWithIdentifier:NAMES_LIST_VIEW_STORYBOARD_ID];
    namesViewController.title = CHECKED_BY;
    namesViewController.namesDelegate = self;
    namesViewController.namesArray = usersListArray;
    [self.navigationController pushViewController:namesViewController animated:YES];
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

- (void)resignKeyboard {
    DCNotesTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NotesTableCell"];
    if ([cell.notesTextView isFirstResponder]){
        [cell.notesTextView resignFirstResponder];
    }
    [self.view endEditing:YES];
}

//MARK : Names list delegate method implementation
- (void)selectedUserEntry:(DCUser *)user {
    checkedByUser = user.displayName;
    self.medicationSlot.medicationAdministration.checkingUser = user;
    [self.tableView reloadData];
}

// MARK: Date Picker Methods
- (void)collapseOpenedPickerCell {
    //close inline pickers if any present in table cell
    if ((datePickerIndexPath) != nil) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:datePickerIndexPath.row - 1 inSection:datePickerIndexPath.section];
        [self displayInlineDatePickerForRowAtIndexPath:previousIndexPath];
    }
}

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

- (void)enteredBatchDetails:(NSString *)batch {
    self.medicationSlot.medicationAdministration.batch = batch;
}

- (void)batchNumberFieldSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)notesSelected:(BOOL)editing withIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)enteredNote:(NSString *)note {
    self.medicationSlot.medicationAdministration.administeredNotes = note;
}

- (void)selectedDateAtIndexPath:(NSDate *)date indexPath:(NSIndexPath *)indexPath {
    if (datePickerIndexPath.row  == 1) {
        self.medicationSlot.medicationAdministration.restartedDate = date;
        self.restartedDate = [DCDateUtility dateStringFromDate:date inFormat:ADMINISTER_DATE_TIME_FORMAT];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        self.medicationSlot.medicationAdministration.expiryDateTime = date;
        self.expiryDate = [DCDateUtility dateStringFromDate:date inFormat:EXPIRY_DATE_FORMAT];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePickerIndexPath.row-1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }

}

@end
