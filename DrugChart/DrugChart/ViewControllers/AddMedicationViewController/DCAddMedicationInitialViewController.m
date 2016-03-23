//
//  DCAddMedicationPopOverViewController.m
//  DrugChart
//
//  Created by aliya on 25/08/15.
//
//

#import "DCAddMedicationInitialViewController.h"
#import "DCMedicationListViewController.h"
#import "DCAddMedicationContentCell.h"
#import "DCInstructionsTableCell.h"
#import "DCDateTableViewCell.h"
#import "DCDatePickerCell.h"
#import "DCAddMedicationHelper.h"
#import "DCAddMedicationWebService.h"
#import "DCAddMedicationWebServiceManager.h"
#import "DCInfusion.h"
#import "DrugChart-Swift.h"

@interface DCAddMedicationInitialViewController () <UITableViewDelegate, UITableViewDataSource, AddMedicationDetailDelegate,InstructionCellDelegate, NewDosageValueEntered, RoutesDelegate> {
    
    __weak IBOutlet UITableView *medicationDetailsTableView;
    __weak IBOutlet UILabel *orderSetLabel;
    UILabel *titleLabel;
    UIBarButtonItem *addButton;
    NSMutableArray *dosageArray;
    NSArray *warningsArray;
    BOOL doneClicked;// for validation purpose
    BOOL showWarnings;//to check if warnings section is displayed
    NSInteger dateAndTimeSection;
    BOOL isNewMedication; // to decide on whether the new medication is selected from list
    BOOL reviewDatePickerExpanded;
    DCDosageSelectionViewController *dosageSelectionViewController;
    CGFloat previousScrollOffset;
}

@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
 
@end

@implementation DCAddMedicationInitialViewController

#pragma mark - View Management Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    medicationDetailsTableView.contentInset = UIEdgeInsetsMake(-25.0f, 0.0f, 0.0f, 0.0f);
    [self configureNavigationBar];
    [self modifyViewForEditMedicationState];
    [self configureContentSizeForView];
    medicationDetailsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.preferredContentSize =  [DCUtility popOverPreferredContentSize];
    self.navigationController.preferredContentSize = [DCUtility popOverPreferredContentSize];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addMedicationViewDismissed)]) {
        [self.delegate addMedicationViewDismissed];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Memory Management methods

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [medicationDetailsTableView reloadData];
}

#pragma mark - Private Methods

- (void)configureNavigationBar {
    
    // navigation bar configuration includes adding save button(right), cancel button(left)
    // and the title can be either Add Medication / Edit Medication.
    addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:SAVE_BUTTON_TITLE style:UIBarButtonItemStylePlain  target:self action:@selector(addMedicationButtonPressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(addMedicationCancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIView *titleView = [[UIView alloc]initWithFrame:TITLE_VIEW_RECT];
    titleLabel = [[UILabel alloc]initWithFrame:TITLE_VIEW_RECT];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.isEditMedication) {
        [titleLabel setText:EDIT_MEDICATION];
    } else {
        [titleLabel setText:ADD_MEDICATION];
    }
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    self.navigationItem.rightBarButtonItem.enabled = false;
}

- (void)modifyViewForEditMedicationState {
    
    if (self.isEditMedication) {
        self.segmentedContolTopLayoutViewHeight.constant = -VIEW_TOP_LAYOUT_VIEW_HEIGHT;
        if([self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED]){
            self.selectedMedication.medicineCategory = WHEN_REQUIRED_VALUE;
        }
        self.selectedMedication.hasReviewDate = (self.selectedMedication.endDate == nil) ? NO : YES;
        self.selectedMedication.hasEndDate = (self.selectedMedication.endDate == nil) ? NO : YES;
        self.selectedMedication.timeArray = [DCAddMedicationHelper timesArrayFromScheduleArray:self.selectedMedication.scheduleTimesArray];
        dateAndTimeSection = 3; //TODO: temporarily added as warnings are not displayed for the time being
    }
}

//Setting the layout margins and seperator space for the table view to zero.

- (void)configureContentSizeForView {
    
    self.preferredContentSize = CGSizeMake(medicationDetailsTableView.contentSize.width, medicationDetailsTableView.frame.size.height);
    if ([self respondsToSelector:@selector(loadViewIfNeeded)]) {
        [self loadViewIfNeeded];
    }
}

// Configures the medication name cell in the medication detail table view.
// If the table view is loaded before the medication name is selected,it is loaded with the place holder string.
- (UITableViewCell *)medicationNameTableViewCell {
    
    static NSString *cellIdentifier = ADD_MEDICATION_CELL_IDENTIFIER;
    UITableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = SYSTEM_FONT_SIZE_FIFTEEN;
    cell.textLabel.numberOfLines = 0;
    if ([self.selectedMedication.name isEqualToString:EMPTY_STRING] ||  self.selectedMedication.name == nil) {
        // place holder string displayed.
        self.navigationItem.rightBarButtonItem.enabled = false;
        cell.textLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
        cell.textLabel.text = NSLocalizedString(@"MEDICATION_NAME", @"hint string");
    } else {
        // otherwise the selecetd medication name is displayed in the cell.
        self.navigationItem.rightBarButtonItem.enabled = true;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = self.selectedMedication.name;
    }
    return cell;
}

// Configures the warning cell, medication details cell, scheduling/frequency cell,
// administration time cell, repeat cell.
- (DCAddMedicationContentCell *)addMedicationCellAtIndexPath:(NSIndexPath *)indexPath
                                                withCellType:(CellType)type {

    static NSString *cellIdentifier = ADD_MEDICATION_CONTENT_CELL;
    DCAddMedicationContentCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DCAddMedicationContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (type) {
        case eWarningsCell: {
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.titleLabel.text = NSLocalizedString(@"WARNINGS", @"Warnings cell title");
            NSInteger warningsCount = self.selectedMedication.severeWarningCount + self.selectedMedication.mildWarningCount;
            [cell configureMedicationContentCellWithWarningsCount:warningsCount];
        }
            break;
        case eMedicationDetailsCell: {
            cell = [self updatedMedicationDetailsCell:cell atIndexPath:indexPath];
        }
            break;
        case eSchedulingCell: {
            cell.titleLabel.text = NSLocalizedString(@"FREQUENCY", @"");
            if (doneClicked) {
                if ([DCAddMedicationHelper frequencyIsValidForSelectedMedication:self.selectedMedication]) {
                    cell.titleLabel.textColor = [UIColor blackColor];
                } else {
                    cell.titleLabel.textColor = [UIColor redColor];
                }
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
            }
            NSMutableString *schedulingDescription = [[NSMutableString alloc] initWithString:EMPTY_STRING];
            if ([self.selectedMedication.scheduling.type isEqualToString: SPECIFIC_TIMES] && self.selectedMedication.scheduling.specificTimes.specificTimesDescription != nil) {
                schedulingDescription = [NSMutableString stringWithString:self.selectedMedication.scheduling.specificTimes.specificTimesDescription];
            } else if ([self.selectedMedication.scheduling.type isEqualToString: INTERVAL] && self.selectedMedication.scheduling.interval.intervalDescription != nil) {
                schedulingDescription = [NSMutableString stringWithString:self.selectedMedication.scheduling.interval.intervalDescription];
            }
            if (![schedulingDescription isEqualToString:EMPTY_STRING] && schedulingDescription != nil) {
                schedulingDescription = [NSMutableString stringWithString:[DCAddMedicationHelper considatedFrequencyDescriptionFromString:schedulingDescription]];
            }
            [cell configureContentCellWithContent: schedulingDescription];
        }
            break;
    }
    return cell;
}

- (DCDosageMultiLineCell *)dosageCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCDosageMultiLineCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDosageMultiLineCellID];
    if (cell == nil) {
        cell = [[DCDosageMultiLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDosageMultiLineCellID];
    }
    //check if dosage is valid, if not valid highlight field in red
    [DCAddMedicationHelper configureAddMedicationCellLabel:cell.titleLabel
                                                forContentText:self.selectedMedication.dosage forSaveButtonAction:doneClicked];
    cell.titleLabel.text = NSLocalizedString(@"DOSE", @"Dosage cell title");
    cell.descriptionLabel.numberOfLines = 0;
    cell.descriptionLabel.text = self.selectedMedication.dosage;
    return cell;
}

- (UITableViewCell *)reviewDateCellatIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case eZerothSection:{
            DCDateTableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDateCellID];
            //no end date cell configuration
            cell.dateTypeLabel.text = NSLocalizedString(@"REVIEW_DATE", @"review date title");
            cell.dateTypeLabel.textColor = [UIColor blackColor];
            [cell configureCellWithReviewDateSwitchState:self.selectedMedication.hasReviewDate];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.noEndDateStatus = ^ (BOOL state) {
                if (state != self.selectedMedication.hasReviewDate) {
                    if (_datePickerIndexPath != nil) {
                        [self collapseOpenedPickerCell];
                    }
                    self.selectedMedication.hasReviewDate = state;
                    [self performSelector:@selector(configureReviewDateTableCellDisplayBasedOnSwitchState) withObject:nil afterDelay:0.1];
                    if (!state) {
                        if (self.selectedMedication.reviewDate != nil) {
                            self.selectedMedication.reviewDate = nil;
                        }
                    }
                }
             };
           // cell.previousSwitchState = self.selectedMedication.hasReviewDate;
            return cell;
        }
        case eFirstSection:{
            static NSString *cellIdentifier = ADD_MEDICATION_CONTENT_CELL;
            DCAddMedicationContentCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.titleLabel.text = NSLocalizedString(@"Review Frequency", @"Date cell title");
            NSMutableString *reviewFrequency = [[NSMutableString alloc] initWithString:EMPTY_STRING];
            if ([self.selectedMedication.medicationReview.reviewType isEqualToString:REVIEW_INTERVAL]) {
                if (self.selectedMedication.medicationReview.reviewInterval.intervalCount != nil && self.selectedMedication.medicationReview.reviewInterval.unit != nil) {
                    [reviewFrequency appendFormat:@"in %@ %@", self.selectedMedication.medicationReview.reviewInterval.intervalCount, self.selectedMedication.medicationReview.reviewInterval.unit];
                }
            } else if ([self.selectedMedication.medicationReview.reviewType isEqualToString:REVIEW_DATE]) {
                if (self.selectedMedication.medicationReview.reviewDate.dateAndTime != nil) {
                    [reviewFrequency appendFormat:@"on %@", self.selectedMedication.medicationReview.reviewDate.dateAndTime];
                }
            }
            [cell configureContentCellWithContent:reviewFrequency];
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)configureReviewDateTableCellDisplayBasedOnSwitchState {
    
    //hide/show no date table cell
    [self collapseOpenedPickerCell];
    if (!self.selectedMedication.hasReviewDate) {
        //hide tablecell
        NSIndexPath *reviewDateIndexPath;
        reviewDateIndexPath = [NSIndexPath indexPathForRow:1 inSection:eFirstSection];
        NSMutableArray *indexpaths = [NSMutableArray arrayWithArray:@[reviewDateIndexPath]];
        if (_datePickerIndexPath.row == (reviewDateIndexPath.row + 1)) {
            [indexpaths addObject:_datePickerIndexPath];
            _datePickerIndexPath = nil;
        }
        _selectedMedication.hasReviewDate = NO;
        DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:reviewDateIndexPath.section]];
        [tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self deleteReviewDateCellAfterDelay:tableCell withIndexPath:reviewDateIndexPath];
    } else {
        NSIndexPath *reviewDateIndexPath;
        reviewDateIndexPath = [NSIndexPath indexPathForRow:1 inSection:eFirstSection];
        DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:eFirstSection]];
        [tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self insertReviewDateCellAfterDelay:tableCell withIndexPath:reviewDateIndexPath];
    }
}

- (DCAddMedicationContentCell *)updatedMedicationDetailsCell:(DCAddMedicationContentCell *)cell
                                                 atIndexPath:(NSIndexPath *)indexPath {
    //doneClicked bool checks if validation is to be done
    if (indexPath.row == ROUTE_INDEX) {
        //if route is not valid, highlight the field in red
        [DCAddMedicationHelper configureAddMedicationCellLabel:cell.titleLabel forContentText:self.selectedMedication.route forSaveButtonAction:doneClicked];
        cell.titleLabel.text = NSLocalizedString(@"ROUTE", @"Route cell title");
        [cell configureContentCellWithContent:self.selectedMedication.route];
    } else {
        if ([self.selectedMedication.infusion.administerAsOption  isEqual: RATE_BASED_INFUSION]) {
            self.selectedMedication.medicineCategory = ONCE_MEDICATION;
        }
        [DCAddMedicationHelper configureAddMedicationCellLabel:cell.titleLabel forContentText:self.selectedMedication.medicineCategory forSaveButtonAction:doneClicked];
        cell.titleLabel.text = NSLocalizedString(@"TYPE", @"Type cell title");
        [cell configureContentCellWithContent:self.selectedMedication.medicineCategory];
        if ([self.selectedMedication.infusion.administerAsOption  isEqual: RATE_BASED_INFUSION]) {
            cell.userInteractionEnabled = NO;
            cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            cell.titleLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
            cell.descriptionLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
        } else {
            cell.accessoryView = nil;
            cell.userInteractionEnabled = YES;
            cell.titleLabel.textColor = [UIColor blackColor];
//            cell.descriptionLabel.textColor = [UIColor scrollViewTexturedBackgroundColor];
        }

    }
    return cell;
}

- (DCDateTableViewCell *)updatedDateAndTimeCellatIndexPath:(NSIndexPath *)indexPath {
    
    //configuring date time section for the selected medication type. This method configures the date and time section based on the selected medication type. Regular medication will have start date, no end date ,end date, administration times cells. ONCE - has only date field. When Required has start date, no end date, end date cells
    DCDateTableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDateCellID];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.isEditMedication = self.isEditMedication;
   // if(self.isEditMedication) {
      //  cell.previousSwitchState = self.selectedMedication.hasEndDate;
   // }
    if (cell == nil) {
        cell = [[DCDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDateCellID];
    }
    if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        cell = [self updatedRegularMedicationDateAndTimeCell:cell atIndexPath:indexPath];
    } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        cell = [self onceMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    } else {
        cell = [self whenScheduledMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (DCDateTableViewCell *)updatedRegularMedicationDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                        atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section table cells for regular medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        //when inline picker is not shown
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
        dateAndTimeCell = [self populatedStartDateTableCell:dateAndTimeCell];
        dateAndTimeCell.accessoryType = UITableViewCellAccessoryNone;
        if (self.isEditMedication) {
            dateAndTimeCell.userInteractionEnabled = NO;
            dateAndTimeCell.dateTypeLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
            dateAndTimeCell.dateValueLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
        } else {
            dateAndTimeCell.userInteractionEnabled = YES;
        }
    } else {
        if (self.datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            //  Start date cell has inline picker shown, So the very next cell to inline picker will be no wnd date cell. If opted to have end date, datePickerIndexPath.row + 2 shows end date cell
            if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 1) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            }
            if (self.selectedMedication.hasEndDate) {
                //has end date,
                if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 2)  {
                    dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
                }
            }
        } else if (self.datePickerIndexPath.row == DATE_PICKER_INDEX_END_DATE) {
            //has inline picker at end date cell. End date cell has inline date picker displayed. datePickerIndexPath.row - 1 is the end date cell. datePickerIndexPath.row - 2 is the no end date cell.
            if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 2) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            } else if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 1)  {
                dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
            }
        } else {
            //no inline date picker.
            if (indexPath.row == NO_END_DATE_ROW_INDEX) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            } else {
                if (self.selectedMedication.hasEndDate) { //has end date
                    if (indexPath.row == END_DATE_ROW_INDEX) {
                        dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
                    }
                }
            }
        }
    }
    return dateAndTimeCell;
}

- (DCDateTableViewCell *)populatedStartDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //configure start date cell
    tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    tableCell.dateTypeWidth.constant = TIME_TITLE_LABEL_WIDTH;
    if (!self.selectedMedication.startDate || [self.selectedMedication.startDate isEqualToString:EMPTY_STRING]) {
        NSDate *dateInCurrentZone = [NSDate date];
        NSString *dateString = [DCDateUtility dateStringFromDate:dateInCurrentZone inFormat:START_DATE_FORMAT];
        self.selectedMedication.startDate = dateString;
        [tableCell configureContentCellWithContent:dateString];
    }
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.selectedMedication.startDate];
    NSString *dateString = [DCDateUtility dateStringFromDate:startDate inFormat:START_DATE_FORMAT];
    [tableCell configureContentCellWithContent:dateString];
    return tableCell;
}

- (DCDateTableViewCell *)updatedEndDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //doneClicked bool checks if validation is to be performed or not.
    if (doneClicked) {
        if (self.selectedMedication.hasEndDate) {//has end date
            //If opted to choose end date
            tableCell.dateTypeLabel.textColor = (!self.selectedMedication.endDate) ? [UIColor redColor] : [UIColor blackColor];
        } else {
            tableCell.dateTypeLabel.textColor = [UIColor blackColor];
        }
    } else {
         tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    }
    tableCell.dateTypeLabel.text = NSLocalizedString(@"END_DATE", @"end date cell title");
    NSDate *endDate = [DCDateUtility dateFromSourceString:self.selectedMedication.endDate];
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    NSString *dateString = [DCDateUtility dateStringFromDate:endDate inFormat:START_DATE_FORMAT];
    [tableCell configureContentCellWithContent:dateString];
    return tableCell;
}

- (DCDateTableViewCell *)noEndDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //no end date cell configuration
    tableCell.dateTypeLabel.text = NSLocalizedString(@"SET_END_DATE", @"set end date title");
    tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    [tableCell configureCellWithNoEndDateSwitchState:self.selectedMedication.hasEndDate];
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
   __weak DCDateTableViewCell *weakTableCell = tableCell;
    tableCell.noEndDateStatus = ^ (BOOL state) {
        if (state != self.selectedMedication.hasEndDate) {
            if (_datePickerIndexPath != nil) {
                [self collapseOpenedPickerCell];
            }
            [weakTableCell.noEndDateSwitch setUserInteractionEnabled:NO];
            self.selectedMedication.hasEndDate = state;
            if (!state) {
                if (self.selectedMedication.endDate != nil) {
                    self.selectedMedication.endDate = nil;
                }
            }
           // [self performSelector:@selector(configureNoEndDateTableCellDisplayBasedOnSwitchState) withObject:nil afterDelay:0.1];
            [self configureNoEndDateTableCellDisplayBasedOnSwitchState];
        }
    };
    return tableCell;
}

- (void)configureNoEndDateTableCellDisplayBasedOnSwitchState {

    //hide/show no date table cell
    [self collapseOpenedPickerCell];
    NSInteger dateSection = showWarnings? eFourthSection : eThirdSection;
    NSIndexPath *endDateIndexPath;
    if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
        endDateIndexPath = [NSIndexPath indexPathForRow:3 inSection:dateSection];
    } else {
        endDateIndexPath = [NSIndexPath indexPathForRow:2 inSection:dateSection];
    }
    if (!self.selectedMedication.hasEndDate) {
        //hide tablecell
        NSMutableArray *indexpaths = [NSMutableArray arrayWithArray:@[endDateIndexPath]];
        if (_datePickerIndexPath.row == (endDateIndexPath.row + 1)) {
            [indexpaths addObject:_datePickerIndexPath];
            _datePickerIndexPath = nil;
        }
         DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endDateIndexPath.row - 1 inSection:endDateIndexPath.section]];
        //[tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self deleteEndDateCellAfterDelay:tableCell withEndDateIndexPath:endDateIndexPath];
    } else {
        DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endDateIndexPath.row - 1 inSection:dateSection]];
        [self insertEndDateCellAfterDelay:tableCell withEndDateIndexPath:endDateIndexPath];
    }
}

- (void)insertEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell withEndDateIndexPath:(NSIndexPath *)endDateIndexPath {
    
    //insert end date cell after delay
    [medicationDetailsTableView beginUpdates];
    [medicationDetailsTableView insertRowsAtIndexPaths:@[endDateIndexPath]
                                      withRowAnimation:UITableViewRowAnimationRight];
    [medicationDetailsTableView endUpdates];
//    double delayInSeconds = 0.2;
//    dispatch_time_t insertTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(insertTime, dispatch_get_main_queue(), ^(void){
        [self enableNoEndDateCellAfterDelay:tableCell];
  //  });
}

- (void)insertReviewDateCellAfterDelay:(DCDateTableViewCell *)tableCell withIndexPath:(NSIndexPath *)dateIndexPath {
    
    //insert end date cell after delay
    [medicationDetailsTableView beginUpdates];
    [medicationDetailsTableView insertRowsAtIndexPaths:@[dateIndexPath]
                                      withRowAnimation:UITableViewRowAnimationRight];
    [medicationDetailsTableView endUpdates];
    [self enableNoEndDateCellAfterDelay:tableCell];
}

- (void)deleteEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell withEndDateIndexPath:(NSIndexPath *)endDateIndexPath {
    
    NSMutableArray *indexpaths = [NSMutableArray arrayWithArray:@[endDateIndexPath]];
    [medicationDetailsTableView deleteRowsAtIndexPaths:indexpaths
                                      withRowAnimation:UITableViewRowAnimationRight];
    [self enableNoEndDateCellAfterDelay:tableCell];
}

- (void)deleteReviewDateCellAfterDelay:(DCDateTableViewCell *)tableCell withIndexPath:(NSIndexPath *)reviewDateIndexPath {
    NSMutableArray *indexpaths;
    if (reviewDatePickerExpanded) {
        reviewDatePickerExpanded = NO;
        NSIndexPath *datePickerIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
        indexpaths = [NSMutableArray arrayWithArray:@[reviewDateIndexPath,datePickerIndexPath]];
    } else {
        indexpaths = [NSMutableArray arrayWithArray:@[reviewDateIndexPath]];
    }
    [medicationDetailsTableView deleteRowsAtIndexPaths:indexpaths
                                      withRowAnimation:UITableViewRowAnimationRight];
    double delayInSeconds = 0.2;
    dispatch_time_t deleteTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(deleteTime, dispatch_get_main_queue(), ^(void){
        [self enableNoEndDateCellAfterDelay:tableCell];
    });
}

- (void)enableNoEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell {
    
    [tableCell.noEndDateSwitch setUserInteractionEnabled:YES];
}

- (DCAddMedicationContentCell *)updatedAdministrationTimeTableCell:(DCAddMedicationContentCell *)tableCell {
    
    if (doneClicked) {
        if ([self.selectedMedication.timeArray count] == 0) {
            tableCell.titleLabel.textColor = [UIColor redColor];
        } else {
            tableCell.titleLabel.textColor = [UIColor blackColor];
        }
    }
    tableCell.titleLabel.text = NSLocalizedString(@"ADMINISTRATING_TIME", @"administration time title");
    return tableCell;
}

- (DCDateTableViewCell *)onceMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                        atIndexPath:(NSIndexPath *)indexPath {
    
    dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"DATE", @"date cell title");
    dateAndTimeCell.accessoryType = UITableViewCellAccessoryNone;
    dateAndTimeCell = [self populatedStartDateTableCell:dateAndTimeCell];
    return dateAndTimeCell;
}

- (DCDateTableViewCell *)whenScheduledMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                     atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section for when required medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
        dateAndTimeCell.accessoryType = UITableViewCellAccessoryNone;
        dateAndTimeCell = [self populatedStartDateTableCell:dateAndTimeCell];
    } else {
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 1) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            } else  {
                if (self.selectedMedication.hasEndDate) {
                    dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
                }
            }
        } else if (_datePickerIndexPath.row == DATE_PICKER_INDEX_END_DATE) {
            if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 2) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            } else {
                if (self.selectedMedication.hasEndDate) {
                    dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
                }
            }
        } else {
            if (indexPath.row == NO_END_DATE_ROW_INDEX) {
                dateAndTimeCell = [self noEndDateTableCell:dateAndTimeCell];
            } else {
                dateAndTimeCell = [self updatedEndDateTableCell:dateAndTimeCell];
            }
        }
    }
    return dateAndTimeCell;
}

- (DCInstructionsTableCell *)instructionsTableCell {
    
    static NSString *cellIdentifier = INSTRUCTIONS_CELL_IDENTIFIER;
    DCInstructionsTableCell *instructionsCell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    instructionsCell.delegate = self;
    if (instructionsCell == nil) {
        instructionsCell = [[DCInstructionsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.selectedMedication.instruction) {
        instructionsCell.instructionsTextView.text = self.selectedMedication.instruction;
    } else {
        instructionsCell.instructionsTextView.textColor = [UIColor colorForHexString:@"#8f8f95"];
        instructionsCell.instructionsTextView.text = NSLocalizedString(@"INSTRUCTIONS", @"Instructions field placeholder");
    }
    return instructionsCell;
}

- (DCDatePickerCell *)datePickerTableCell {
    
    static NSString *pickerCellId = DATE_PICKER_CELL_IDENTIFIER;
    DCDatePickerCell *pickerCell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:pickerCellId];
    if (pickerCell == nil) {
        pickerCell = [[DCDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pickerCellId];
    }
    [pickerCell configureDatePickerPropertiesForAddMedication];
    return pickerCell;
}

- (NSInteger)numberOfRowsInMedicationTableViewSection:(NSInteger)section {
    
    //checks if warnings section is to be shown and gets the row count based on that.
    switch (section) {
        case eZerothSection:
            return MEDICATION_NAME_ROW_COUNT;
        case eFirstSection:{
            NSInteger rowCount = self.selectedMedication.hasReviewDate ? 2 : 1 ;
            if (reviewDatePickerExpanded) {
                rowCount ++;
            }
            return rowCount;
        }
        case eSecondSection:
            return (showWarnings ? WARNINGS_ROW_COUNT : MEDICATION_DETAILS_ROW_COUNT);
        case eThirdSection:
            return (showWarnings ? MEDICATION_DETAILS_ROW_COUNT : [self numberOfRowsInDateAndTimeSectionForSelectedMedicationType]);
        case eFourthSection: {
            NSInteger rowCount = [self numberOfRowsInDateAndTimeSectionForSelectedMedicationType];
            return (showWarnings ? rowCount : 1);
        }
        default:
            return MEDICATION_NAME_ROW_COUNT;
    }
}

- (NSInteger)numberOfRowsInDateAndTimeSectionForSelectedMedicationType {
    
    NSInteger rowCount;
    if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        rowCount = self.selectedMedication.hasEndDate ? REGULAR_DATEANDTIME_ROW_COUNT : REGULAR_DATEANDTIME_ROW_COUNT - 1;
    } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        rowCount = ONCE_DATEANDTIME_ROW_COUNT;
    } else {
        rowCount = self.selectedMedication.hasEndDate ? WHEN_REQUIRED_DATEANDTIME_ROW_COUNT : WHEN_REQUIRED_DATEANDTIME_ROW_COUNT - 1;
    }
    if ([self hasInlineDatePicker]) {
        rowCount ++;
    }
    return rowCount;
}

- (void)displayMedicationSearchListView {
    
    //display medication list view
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCMedicationListViewController *medicationListViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:MEDICATION_LIST_STORYBOARD_ID];
    medicationListViewController.patientId = self.patientId;
    medicationListViewController.selectedMedication = ^(DCMedication *medication, NSArray *warnings) {
        isNewMedication = true;
        doneClicked = false;
        [self refreshViewWithSelectedMedication:medication withWarnings:warnings];
    };
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:medicationListViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)refreshViewWithSelectedMedication:(DCMedication *)medication withWarnings:(NSArray *)warnings {
    
    //set the selected medication and refresh view with that
    warningsArray = warnings;
    NSArray *severeArray = [[warningsArray objectAtIndex:0] valueForKey:SEVERE_WARNING];
    NSArray *mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
    if ([severeArray count] > 0 || [mildArray count] > 0) {
        showWarnings = YES;
        dateAndTimeSection = eFourthSection;
    } else {
        showWarnings = NO;
        dateAndTimeSection = eThirdSection;
    }
    self.selectedMedication = [[DCMedicationScheduleDetails alloc] init];
    self.selectedMedication.name = medication.name;
    self.selectedMedication.routeArray = [[NSMutableArray alloc] initWithArray:medication.routeArray];
    self.selectedMedication.medicationId = medication.medicationId;
    self.selectedMedication.dosage = medication.dosage;
    self.selectedMedication.hasEndDate = NO;
    self.selectedMedication.overriddenReason = medication.overriddenReason;
    self.selectedMedication.severeWarningCount = severeArray.count;
    self.selectedMedication.mildWarningCount = mildArray.count;
    self.selectedMedication.medicineCategory = REGULAR_MEDICATION;
    self.selectedMedication.scheduling = [[DCScheduling alloc] init];
    self.selectedMedication.dose = [[DCDosage alloc] init];
    dosageArray = [NSMutableArray arrayWithObjects:medication.dosage, nil];
    self.selectedMedication.infusion = [[DCInfusion alloc] init];
    self.selectedMedication.medicationReview = [[DCMedicationReview alloc] init];
    [medicationDetailsTableView reloadData];
}

- (void)displayWarningsListView {
    
    //display Warnings list view
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCWarningsListViewController *warningsListViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:WARNINGS_LIST_STORYBOARD_ID];
    //warningsListViewController.backButtonText = titleLabel.text;
    [self configureNavigationBackButtonTitle];
    warningsListViewController.overiddenReason = self.selectedMedication.overriddenReason;
    [warningsListViewController populateWarningsListWithWarnings:warningsArray showOverrideView:NO];
    [self.navigationController pushViewController:warningsListViewController animated:YES];
}

- (void)displayRoutesAndInfusionsView {
    
    //navigate to routes and infusions view
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCRouteViewController *routesInfusionsViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ROUTE_STORYBOARD_ID];
    routesInfusionsViewController.delegate = self;
    routesInfusionsViewController.previousRoute = self.selectedMedication.route;
    routesInfusionsViewController.infusion = self.selectedMedication.infusion;
    routesInfusionsViewController.dosage = self.selectedMedication.dose;
    routesInfusionsViewController.patientId = self.patientId;
    NSMutableArray *routeArray = [[NSMutableArray alloc] init];
    if (self.isEditMedication) {
        [routeArray addObject:self.selectedMedication.route];
    } else {
        for (NSDictionary *routeDictionary in self.selectedMedication.routeArray) {
            for (NSString *key in routeDictionary){
                NSString *route = routeDictionary[key];
                [routeArray addObject:route];
            }
        }
    }
    routesInfusionsViewController.routesArray = routeArray;
    [self configureNavigationBackButtonTitle];
    [self.navigationController pushViewController:routesInfusionsViewController animated:YES];
}

- (void)displayDosageView {
    
    UIStoryboard *dosageStoryboard = [UIStoryboard storyboardWithName:DOSAGE_STORYBORD bundle:nil];
    dosageSelectionViewController = [dosageStoryboard instantiateViewControllerWithIdentifier:DOSAGE_SELECTION_SBID];
    //TODO: Update the dosage to the selectedMedication in this Block.
    dosageSelectionViewController.selectedDosage = ^ (DCDosage *dosage) {
        
    };
    dosageSelectionViewController.newDosageAddedDelegate = self;
    dosageSelectionViewController.dosageArray = dosageArray;
    dosageSelectionViewController.timeArray = self.selectedMedication.timeArray;
    dosageSelectionViewController.menuType = eDosageMenu;
    if (self.isEditMedication) {
        if (self.selectedMedication.dose == nil) {
            self.selectedMedication.dose = [[DCDosage alloc] init];
        }
    }
    if ([self.selectedMedication.medicineCategory  isEqualToString: @"Regular"]) {
        dosageSelectionViewController.isReducingIncreasingPresent = true;
        if ([self.selectedMedication.scheduling.type  isEqualToString:SPECIFIC_TIMES] && self.selectedMedication.scheduling.specificTimes != nil && [self.selectedMedication.scheduling.specificTimes.repeatObject.repeatType  isEqualToString: @"Daily"]) {
            dosageSelectionViewController.isSplitDailyPresent = true;
        }
    }
    dosageSelectionViewController.dosage = self.selectedMedication.dose;
    [self configureNavigationBackButtonTitle];
    [self.navigationController pushViewController:dosageSelectionViewController animated:YES];
}

- (void)configureNavigationBackButtonTitle {
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:titleLabel.text
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)displaySchedulingDetailViewForTableViewAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCSchedulingInitialViewController *schedulingViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:SCHEDULING_INITIAL_STORYBOARD_ID];
    schedulingViewController.selectedSchedulingValue = ^ (DCScheduling *scheduling) {
        self.selectedMedication.scheduling = scheduling;
        if ([self.selectedMedication.scheduling.type isEqualToString:SPECIFIC_TIMES]) {
            self.selectedMedication.timeArray = self.selectedMedication.scheduling.specificTimes.administratingTimesArray;
        } else if ([self.selectedMedication.scheduling.type isEqualToString:INTERVAL]) {
            self.selectedMedication.timeArray = self.selectedMedication.scheduling.interval.administratingTimes;
        }
    };
    if (self.isEditMedication) {
        if (self.selectedMedication.scheduling == nil) {
            self.selectedMedication.scheduling = [[DCScheduling alloc] init];
        }
    }
    schedulingViewController.scheduling = self.selectedMedication.scheduling;
    schedulingViewController.validate = doneClicked;
    [self configureNavigationBackButtonTitle];
    [self.navigationController pushViewController:schedulingViewController animated:YES];
}

- (DCAddMedicationContentCell *)selectedCellAtIndexPath:(NSIndexPath *)indexPath {
    
    //selected cell at indexpath
    DCAddMedicationContentCell *selectedCell = (DCAddMedicationContentCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
    return selectedCell;
}

- (void)collapseOpenedPickerCell {
    
    //close inline pickers if any present in table cell
    if (_datePickerIndexPath) {
        NSIndexPath *previousPickerIndexPath = [NSIndexPath indexPathForItem:_datePickerIndexPath.row - 1
                                                                   inSection:_datePickerIndexPath.section];
        [self displayInlineDatePickerForRowAtIndexPath:previousPickerIndexPath];
    }
}

- (void)collapseReviewDatePicker {
    
    if (reviewDatePickerExpanded) {
        // display the date picker inline with the table content
        reviewDatePickerExpanded = NO;
        [medicationDetailsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]]
                                          withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSIndexPath*)indexPathForLastRow {
    
    NSInteger sectionCount = [DCAddMedicationHelper numberOfSectionsInMedicationTableViewForSelectedMedication:self.selectedMedication  showWarnings:showWarnings];
    return [NSIndexPath indexPathForRow:[self numberOfRowsInMedicationTableViewSection:sectionCount - 1] - 1
                              inSection:sectionCount - 1];
}

- (void)resignKeyboard {
    
    //resign keyboard
    DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
    if ([instructionsCell.instructionsTextView isFirstResponder]) {
        [instructionsCell.instructionsTextView resignFirstResponder];
    }
    [self.view endEditing:YES];
}

- (void)displayReviewViewController {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCReviewViewController *reviewViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:REVIEW_VIEW_CONTROLLER_SB_ID];
    reviewViewController.title = NSLocalizedString(@"Review Frequency", @"screen title");
    reviewViewController.review = self.selectedMedication.medicationReview;
    reviewViewController.updatedReviewObject = ^ (DCMedicationReview *review){
        self.selectedMedication.medicationReview = review;
    };
    [self configureNavigationBackButtonTitle];
    [self.navigationController pushViewController:reviewViewController animated:YES];
}

- (void)displayMedicationTypeView {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCMedicationTypeViewController *medicationTypeViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:MEDICATION_TYPE_STORYBOARD_ID];
    medicationTypeViewController.previousValue = self.selectedMedication.medicineCategory;
    medicationTypeViewController.typeCompletion = ^ (NSString *type) {
        self.selectedMedication.medicineCategory = type;
        [self resetDateAndTimeSection];
        [medicationDetailsTableView reloadData];
    };
    [self configureNavigationBackButtonTitle];
    [self.navigationController pushViewController:medicationTypeViewController animated:YES];
}

- (void)displayDetailViewForSelectedCellAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eZerothSection:// display medicine name in initial section and detail view will be MedicationListView
            if (!self.isEditMedication) {
                [self displayMedicationSearchListView];
            }
            break;
        case eFirstSection:{
            if (indexPath.row == 1 && self.selectedMedication.hasReviewDate){
                [self displayReviewViewController];
            }
            break;
        }
        case eSecondSection:
            if (showWarnings) {
                //if tableview has warnings section, 'Warnings' selection displays Warnings List, Other wise detail screen display will be that of dosage, route, type
                [self displayWarningsListView];
            } else {
                if (indexPath.row == 0) {
                    [self displayRoutesAndInfusionsView];
                } else {
                    [self displayMedicationTypeView];
                }
            }
            break;
        case eThirdSection:
            if (showWarnings) { //If tableview has warnings section, Second section cell selection shows detail screen for dosage/route/type, otherwise present keyboard in instructions text view
                if (indexPath.row == 0) {
                    [self displayRoutesAndInfusionsView];
                } else {
                    [self displayMedicationTypeView];
                }
            } else {
                [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
            }
            break;
        case eFourthSection: {
            if (showWarnings) { // If Warnings section is shown, third section present instruction text view keyboard,, otherwise load date and time detail section
                [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
            } else {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    [self displaySchedulingDetailViewForTableViewAtIndexPath:indexPath];
                } else {
                    [self displayDosageView];
                }
            }
        }
            break;
        case eFifthSection:
            if (showWarnings) {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    [self displaySchedulingDetailViewForTableViewAtIndexPath:indexPath];
                } else {
                    [self displayDosageView];
                }
            } else {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    [self displayDosageView];
                } else {
                    DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                    [instructionsCell.instructionsTextView becomeFirstResponder];
                }
            }
            break;
        case eSixthSection:
            if (showWarnings) {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    [self displayDosageView];
                } else {
                    DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                    [instructionsCell.instructionsTextView becomeFirstResponder];
                }
            } else {
                DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                [instructionsCell.instructionsTextView becomeFirstResponder];
            }
            break;
        case eSeventhSection: {
            DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
            [instructionsCell.instructionsTextView becomeFirstResponder];
        }
            break;
        default:
            break;
    }
    [medicationDetailsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)isRegularMedicationWithWarnings {
    
    //selected medication type is regular and has warnings
    return (showWarnings && [self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]);
}

- (void)loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [medicationDetailsTableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID) {
        if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
            [self displayDetailViewForRegularMedicationAtIndexPath:indexPath];
        } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        } else {
            [self displayDatePickerViewForWhenRequiredMedicationAtIndexPath:indexPath];
        }
    } else {
        [self displayDetailViewForRegularMedicationAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    }
}

- (void)displayDetailViewForRegularMedicationAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_datePickerIndexPath) { // If inline datepicker is not shown
        if (indexPath.row != NO_END_DATE_ROW_INDEX) { // disable section of no end date cell, show inline date pickers on other cell selection
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        }
    } else {
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            if (indexPath.row != DATE_PICKER_INDEX_START_DATE + 1) {
                //skip no end date cell
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
        } else {
            if (indexPath.row != NO_END_DATE_ROW_INDEX) {
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
        }
    }
}

- (void)displayDatePickerViewForWhenRequiredMedicationAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_datePickerIndexPath) {
        if (indexPath.row != START_DATE_ROW_INDEX + 1) {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        }
    } else if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
        if (indexPath.row != DATE_PICKER_INDEX_START_DATE + 1) {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        }
    } else {
        if (indexPath.row != START_DATE_ROW_INDEX + 1) {
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        }
    }
}

- (void)resetDateAndTimeSection {
    
    self.selectedMedication.startDate = EMPTY_STRING;
    self.selectedMedication.endDate = EMPTY_STRING;
    self.selectedMedication.hasEndDate = NO;
    self.selectedMedication.timeArray = [NSMutableArray arrayWithArray:@[]];
}

- (void)callAddMedicationWebService {

    //On adding a medication the details of the added medication is passed to the server, when the method fails it shows an alert, while successful addition of data dismisses the add medication popover.
    DCAddMedicationWebServiceManager *webServiceManager = [[DCAddMedicationWebServiceManager alloc] init];
    NSDictionary *medicationDictionary = [webServiceManager medicationDetailsDictionaryForMedicationDetail:self.selectedMedication];
    [webServiceManager addMedicationServiceCallWithParameters:medicationDictionary ForMedicationType:self.selectedMedication.medicineCategory WithPatientId:self.patientId withCallbackHandler:^(NSError *error) {
        if (!error) {
            if (self.delegate) {
                [self.delegate addedNewMedicationForPatient];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [self updateAddButton:YES];
    }];
}

- (UITableViewCell *)dateSectionTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *cellID = ([self indexPathHasPicker:indexPath]) ? kDatePickerID : kDateCellID;
    cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellID];
    if ([cellID isEqualToString:kDateCellID]){
        DCDateTableViewCell *dateCell = [self updatedDateAndTimeCellatIndexPath:indexPath];
        return dateCell;
    } else if ([cellID isEqualToString:kDatePickerID]){
        DCDatePickerCell *pickerCell = [self datePickerTableCell];
        //identify start/end date picker and set minimum date. end date should not be less than start date 
        if (indexPath.row == 1) {
            pickerCell.isStartDate = YES;
            pickerCell.datePicker.minimumDate = nil;
            if (self.selectedMedication.startDate != nil) {
                pickerCell.datePicker.date = [DCDateUtility dateFromSourceString: self.selectedMedication.startDate];
            }
        } else {
            pickerCell.isStartDate = NO;
            if (self.selectedMedication.startDate != nil) {
                 pickerCell.datePicker.minimumDate = [DCDateUtility dateFromSourceString: self.selectedMedication.startDate];
            }
            if (self.selectedMedication.endDate != nil && ![self.selectedMedication.endDate isEqualToString:EMPTY_STRING]) {
                pickerCell.datePicker.date = [DCDateUtility dateFromSourceString: self.selectedMedication.endDate];
            }
        }
        __weak DCDatePickerCell *weakPickerCell = pickerCell;
        pickerCell.selectedDate = ^ (NSDate *date) {
            NSIndexPath *indexPathToUpdate = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            DCDateTableViewCell *dateCell = [self updatedDateAndTimeCellatIndexPath:indexPathToUpdate];
            NSString *dateString = [DCDateUtility dateStringFromDate:date inFormat:START_DATE_FORMAT];
            [dateCell configureContentCellWithContent:dateString];
            if (weakPickerCell.isStartDate) {
                self.selectedMedication.startDate = dateString;
            } else {
                self.selectedMedication.endDate = dateString;
            }
            [medicationDetailsTableView beginUpdates];
            [medicationDetailsTableView reloadRowsAtIndexPaths:@[indexPathToUpdate] withRowAnimation:UITableViewRowAnimationNone];
            [medicationDetailsTableView endUpdates];
        };
        return pickerCell;
    }
    return nil;
}

- (DCAddMedicationContentCell *)singleLineDoseCellAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = ADD_MEDICATION_CONTENT_CELL;
    DCAddMedicationContentCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [DCAddMedicationHelper configureAddMedicationCellLabel:cell.titleLabel forContentText:self.selectedMedication.dosage forSaveButtonAction:doneClicked];
    cell.titleLabel.text = NSLocalizedString(@"DOSE", @"Dose cell title");
    [cell configureContentCellWithContent:self.selectedMedication.dosage];
    return cell;
}

- (UITableViewCell *)singleOrMultilineDosageCellAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
        DCDosageMultiLineCell *dosageCell = [self dosageCellAtIndexPath:indexPath];
        return dosageCell;
    } else {
        DCAddMedicationContentCell *doseCell = [self singleLineDoseCellAtIndexPath:indexPath];
        return doseCell;
    }
}

- (void)animateTableViewUpwardsWhenKeyboardAppears {
    
    CGFloat contentHeight = medicationDetailsTableView.contentSize.height;
    NSIndexPath *instructionIndexPath = [self indexPathForLastRow];
    DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:instructionIndexPath];
    CGFloat instructionHeight = instructionsCell.instructionsTextView.contentSize.height;
    if (instructionHeight <= INSTRUCTIONS_ROW_HEIGHT) {
        instructionHeight = INSTRUCTIONS_ROW_HEIGHT;
    }
    NSInteger scrollOffset = contentHeight - self.keyboardSize.height + instructionHeight;
    if (scrollOffset > self.view.frame.size.height) {
        scrollOffset = self.view.frame.size.height;
    }
    if (previousScrollOffset != scrollOffset) {
        double delayInSeconds = isNewMedication?  0.5 : 0.25;
        dispatch_time_t deleteTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(deleteTime, dispatch_get_main_queue(), ^(void){
            [medicationDetailsTableView setContentOffset:CGPointMake(0, scrollOffset + 5) animated:YES];
            previousScrollOffset = scrollOffset;
        });
    }
}

- (void)editMedicationWebService {
    
    // To Do: API need to be integrated.
    [self updateAddButton:YES];
}

- (void)updateAddButton:(BOOL)enable {
    
    if (enable) {
        [addButton setTarget:self];
        [addButton setAction:@selector(addMedicationButtonPressed:)];
    } else {
        [addButton setTarget:nil];
        [addButton setAction:nil];
    }
    [addButton setEnabled:enable];
}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionCount = [DCAddMedicationHelper numberOfSectionsInMedicationTableViewForSelectedMedication:self.selectedMedication  showWarnings:showWarnings];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rowCount = [self numberOfRowsInMedicationTableViewSection:section];
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eZerothSection: { // zeroth section will always have medicine name field
            UITableViewCell *cell = [self medicationNameTableViewCell];
            return cell;
        }
        case eFirstSection:{
            return [self reviewDateCellatIndexPath:indexPath];
        }
        case eSecondSection: { // first section will have warnings or medication details based on warnings section display
            CellType cellType = !showWarnings ? eMedicationDetailsCell : eWarningsCell;
            DCAddMedicationContentCell *contentCell = [self addMedicationCellAtIndexPath:indexPath
                                                                            withCellType:cellType];
            return contentCell;
        }
        case eThirdSection: {
            if (showWarnings) {
                DCAddMedicationContentCell *contentCell = [self addMedicationCellAtIndexPath:indexPath
                                                                                withCellType:eMedicationDetailsCell];
                return contentCell;
            }
            else {
                UITableViewCell *dateCell = [self dateSectionTableViewCellAtIndexPath:indexPath];
                return dateCell;
            }
        }
        case eFourthSection: {
            if (showWarnings) {
                UITableViewCell *dateCell = [self dateSectionTableViewCellAtIndexPath:indexPath];
                return dateCell;
            } else {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    DCAddMedicationContentCell *contentCell = [self addMedicationCellAtIndexPath:indexPath
                                                                                    withCellType:eSchedulingCell];
                    return contentCell;
                } else {
                    UITableViewCell *dosageCell = [self singleOrMultilineDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                }
            }
        }
        case eFifthSection: {
            if (showWarnings) {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    DCAddMedicationContentCell *contentCell = [self addMedicationCellAtIndexPath:indexPath
                                                                                    withCellType:eSchedulingCell];
                    return contentCell;
                } else {
                    UITableViewCell *dosageCell = [self singleOrMultilineDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                }
            } else {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    UITableViewCell *dosageCell = [self singleOrMultilineDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
                    return instructionsCell;
                }
            }
        }
        case eSixthSection: {
            if (showWarnings) {
                if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                    UITableViewCell *dosageCell = [self singleOrMultilineDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
                    return instructionsCell;
                }
            } else {
                DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
                return instructionsCell;
            }
         }
       case eSeventhSection: {
            DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
            return instructionsCell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //medicine name section height is zero and others will have height 10
    CGFloat sectionHeight = (section == eZerothSection) ? 0.0f : HEADER_VIEW_HEIGHT;
    return sectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //set the tableview cell heights here, Zeroth section will always display medicine name,
    if (indexPath.section == eZerothSection) {
        CGFloat nameHeight = TABLE_CELL_DEFAULT_ROW_HEIGHT;
        if (self.selectedMedication.name) {
            //calculate medicine name height in the row
            nameHeight = [DCAddMedicationHelper heightForMedicineName:self.selectedMedication.name];
            nameHeight = (nameHeight < TABLE_CELL_DEFAULT_ROW_HEIGHT) ? TABLE_CELL_DEFAULT_ROW_HEIGHT : nameHeight;
        }
        return nameHeight;
    }else if (indexPath.section == eFirstSection){
        if (indexPath.row == 2) {
            return PICKER_VIEW_CELL_HEIGHT ;
        }
    } else if (indexPath.section == eThirdSection){
        if (!showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        }
    } else if (indexPath.section == eFourthSection){
        if (showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        } else {
            if (![self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    return [DCAddMedicationHelper textContentHeightForDosage:self.selectedMedication.dosage];
                }
            }
        }
    } else if (indexPath.section == eFifthSection) {
        if (showWarnings) {
            if (![self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    return [DCAddMedicationHelper textContentHeightForDosage:self.selectedMedication.dosage];
                }
            }
        } else {
            if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    return [DCAddMedicationHelper textContentHeightForDosage:self.selectedMedication.dosage];
                }
            } else {
                return [DCAddMedicationHelper instructionCellHeightForInstruction:self.selectedMedication.instruction];
            }
        }
    } else if (indexPath.section == eSixthSection) {
        if (showWarnings) {
            if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
                if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    return [DCAddMedicationHelper textContentHeightForDosage:self.selectedMedication.dosage];
                }
            } else {
                return [DCAddMedicationHelper instructionCellHeightForInstruction:self.selectedMedication.instruction];
            }
        } else {
           return [DCAddMedicationHelper instructionCellHeightForInstruction:self.selectedMedication.instruction];
        }
    } else if (indexPath.section == eSeventhSection) {
        return [DCAddMedicationHelper instructionCellHeightForInstruction:self.selectedMedication.instruction];
    }
    return medicationDetailsTableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //shrink already opened date picker cell
    [self resignKeyboard];
    if (indexPath.section != eFirstSection){
        [self collapseReviewDatePicker];
    }
    if ((indexPath.section != _datePickerIndexPath.section)) {
         [self collapseOpenedPickerCell];
    } else {
        //date and time section, check for the administarting time row and collapse any
        //picker if opened for Regular medication
        if (([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]  || [self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED_VALUE]) &&
            indexPath.row == [self numberOfRowsInMedicationTableViewSection:dateAndTimeSection] - 1) {
            [self collapseOpenedPickerCell];
        }
    }
    [self displayDetailViewForSelectedCellAtIndexPath:indexPath];
}

#pragma mark - Action Methods

- (void)addMedicationButtonPressed:(id)sender {
    
    //add medication button action
    doneClicked = YES;
    [self updateAddButton:NO];
    [medicationDetailsTableView reloadData];
    if ([self.selectedMedication.instruction isEqualToString:INSTRUCTIONS]) {
        self.selectedMedication.instruction = EMPTY_STRING;
    }
    if ([DCAddMedicationHelper selectedMedicationDetailsAreValid:self.selectedMedication]) {
        if ([DCAPPDELEGATE isNetworkReachable]) {
            if (self.isEditMedication) {
 //TODO : temporarly added till api is available
                [self editMedicationWebService];
                if (self.delegate && [self.delegate respondsToSelector:@selector(medicationEditCancelledForIndexPath:)]) {
                    [self.delegate medicationEditCancelledForIndexPath:_medicationEditIndexPath];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self callAddMedicationWebService];
            }
        } else {
            [self updateAddButton:YES];
        }
    } else {
        [self updateAddButton:YES];
    }
}

- (void)addMedicationCancelButtonPressed :(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(medicationEditCancelledForIndexPath:)]) {
        [self.delegate medicationEditCancelledForIndexPath:_medicationEditIndexPath];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentedControlSelected:(UISegmentedControl *)segmentedControl {
    
    //Switches between add medication & order set views
    if (segmentedControl.selectedSegmentIndex == ADD_MEDICATION_INDEX) {
        [medicationDetailsTableView setHidden:NO];
        [orderSetLabel setHidden:YES];
    } else {
        [medicationDetailsTableView setHidden:YES];
        [orderSetLabel setHidden:NO];
    }
}

#pragma mark - Date picker methods

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath {
    
    BOOL hasDatePicker = NO;
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    UITableViewCell *checkDatePickerCell = [medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:indexPath.section]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:99];
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
    
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

- (BOOL)hasInlineDatePicker {
    
    return (self.datePickerIndexPath != nil);
}

- (void)scrollToDatePickerAtIndexPath:(NSIndexPath *)indexPath {
    
    //scroll to date picker indexpath when when any of the date field is selected
    if (indexPath.row != _datePickerIndexPath.row - 1) {
        NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        dispatch_async(dispatch_get_main_queue(), ^{
            [medicationDetailsTableView scrollToRowAtIndexPath:scrollToIndexPath
                                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
          
        });
    }
}

- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // display the date picker inline with the table content
    [self scrollToDatePickerAtIndexPath:indexPath];
    [medicationDetailsTableView beginUpdates];
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker]) {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker]) {
        [medicationDetailsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:dateAndTimeSection]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    if (!sameCellClicked) {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:indexPath.section];
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:indexPath.section];
    }
    // always deselect the row containing the start or end date
    [medicationDetailsTableView deselectRowAtIndexPath:indexPath animated:YES];
    [medicationDetailsTableView endUpdates];
}

- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    [medicationDetailsTableView beginUpdates];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath]) {
        // found a picker below it, so remove it
        [medicationDetailsTableView deleteRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // didn't find a picker below it, so we should insert it
        [medicationDetailsTableView insertRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
    }
    [medicationDetailsTableView endUpdates];
}

#pragma mark - AddMedicationDetail Delegate Methods

- (void)newDosageAdded:(NSString *)dosage {
    
    //new dosage added
    self.selectedMedication.dosage = dosage;
    [medicationDetailsTableView reloadData];
}

- (void)updatedAdministrationTimeArray:(NSArray *)timeArray {
    
    //new administration time added
    self.selectedMedication.timeArray = [NSMutableArray arrayWithArray:timeArray];
    [medicationDetailsTableView reloadData];
}

#pragma mark - Keyboard notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    
    //notification methods
    UITableViewCell *selectedCell = [medicationDetailsTableView cellForRowAtIndexPath:[self indexPathForLastRow]];
    if ([selectedCell isKindOfClass:[DCInstructionsTableCell class]]) {
        self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [self animateTableViewUpwardsWhenKeyboardAppears];
        isNewMedication = false;
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    [UIView setAnimationsEnabled:YES];
    [medicationDetailsTableView beginUpdates];
    [medicationDetailsTableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    previousScrollOffset = 0.0;
}

#pragma mark - Instruction Delegates

- (void)closeInlineDatePickers {

    [self collapseReviewDatePicker];
    [self collapseOpenedPickerCell];
}

- (void)updateInstructionsText:(NSString *)instructions {
    
    self.selectedMedication.instruction = instructions;
}

#pragma mark - RoutesAndInfusions Delegate Methods

- (void)newRouteSelected:(NSString *)route {
    
    self.selectedMedication.route = route;
    [medicationDetailsTableView reloadData];
}

- (void)updatedInfusionObject:(DCInfusion *)infusion {
    
    self.selectedMedication.infusion = infusion;
    if ([self.selectedMedication.infusion.administerAsOption  isEqual: RATE_BASED_INFUSION]) {
        self.selectedMedication.medicineCategory = ONCE_MEDICATION;
    }
}

#pragma mark - UIPopOverPresentationController Delegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    //this method restricts the pop over dismiss on tapping pop over background. 
    return NO;
}

@end
