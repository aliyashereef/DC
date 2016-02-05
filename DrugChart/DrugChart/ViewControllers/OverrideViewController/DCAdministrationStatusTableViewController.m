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

@implementation DCAdministrationStatusTableViewController{
    BOOL isSecondSectionExpanded;
    int rowCount;
}

#pragma mark - View Management Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureStatusArrayWithStatusValue];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStatusArrayWithStatusValue {
    if ([self.status  isEqual: ADMINISTER_NOW]) {
        _namesArray = @[STARTED, REFUSED, OMITTED];
    } else if ([self.status  isEqual: IN_PROGRESS]){
        _namesArray = @[ENDED,STOPED_DUE_TO_PROBLEM,CONTINUED_AFTER_PROBLEM,FLUID_CHANGED,PAUSED];
    } else {
        _namesArray = @[ADMINISTERED, REFUSED, OMITTED];
    }
}

#pragma mark - Table View Data Source Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSecondSectionExpanded) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 1:
            return rowCount;
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
                        cell.detailLabel.text =  @"";
                        return cell;}
                    case 1:{
                        DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                        cell.titleLabel.text = @"Restarted at";
                         cell.detailLabel.text =  @"";
                        return cell;}
                    case 2:{
                        DCAdministerCell *cell = [self configureAdministrationCellAtIndexPath:indexPath];
                        cell.titleLabel.text = NSLocalizedString(@"CHECKED_BY", comment: @"Checked by title");
                        cell.detailLabel.text =  @"";
                        return cell;}
                    case 3:{
                        DCBatchNumberCell *batchCell = [self configureBatchCellAtIndexPath:indexPath];
//                        batchCell.batchDelegate = self
                        batchCell.selectedIndexPath = indexPath;
                        return batchCell;}
                    case 4:{
                        DCBatchNumberCell *batchCell = [self configureBatchCellAtIndexPath:indexPath];
//                        batchCell.batchDelegate = self
                        batchCell.selectedIndexPath = indexPath;
                        return batchCell;}
                    default:{
                        return nil;
                    }
                }
                
            } else  if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
                DCNotesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesTableCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DCNotesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesTableCell"];
                }
                cell.noteType = @"Notes";
                cell.selectedIndexPath = indexPath;
                cell.notesTextView.text = [cell hintText];
                return cell;
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

- (DCBatchNumberCell *)configureBatchCellAtIndexPath : (NSIndexPath *)indexPath {
    //batch number or expiry field
    DCBatchNumberCell *batchCell = [self.tableView dequeueReusableCellWithIdentifier:@"BatchNumberTableCell" forIndexPath:indexPath];
    if (batchCell == nil) {
        batchCell = [[DCBatchNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BatchNumberTableCell"];
    }
    return batchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected medication status to parent
    _status = [_namesArray objectAtIndex:indexPath.item];
    _previousSelectedValue = _status;
    if (indexPath.section == 0) {
        [self collapseOpenedSection];
        if ([_status isEqualToString: STOPED_DUE_TO_PROBLEM] || [_status isEqualToString:CONTINUED_AFTER_PROBLEM]) {
            isSecondSectionExpanded = YES;
            rowCount = 1;
            [self insertSection];
            [self.tableView reloadData];
        } else if ([_status isEqualToString: FLUID_CHANGED]) {
            isSecondSectionExpanded = YES;
            rowCount = 5;
            [self insertSection];
            [self.tableView reloadData];
        } else {
            isSecondSectionExpanded = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.medicationStatusDelegate && [self.medicationStatusDelegate respondsToSelector:@selector(selectedMedicationStatusEntry:)]) {
            [self.medicationStatusDelegate selectedMedicationStatusEntry:_status];
        }
    } else {
        
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

@end
