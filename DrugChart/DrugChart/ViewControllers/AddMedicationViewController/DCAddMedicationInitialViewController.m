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
#import "DCAddMedicationDetailViewController.h"
#import "DCDatePickerCell.h"
#import "DCAddMedicationHelper.h"
#import "DCAddMedicationWebService.h"
#import "DCAddMedicationWebServiceManager.h"
#import "DrugChart-Swift.h"

@interface DCAddMedicationInitialViewController () <UITableViewDelegate, UITableViewDataSource, AddMedicationDetailDelegate,InstructionCellDelegate, NewDosageValueEntered> {
    
    __weak IBOutlet UITableView *medicationDetailsTableView;
    __weak IBOutlet UILabel *orderSetLabel;
    UIBarButtonItem *addButton;
    NSMutableArray *dosageArray;
    NSArray *warningsArray;
    BOOL doneClicked;// for validation purpose
    BOOL showWarnings;//to check if warnings section is displayed
    
    DCDosageSelectionViewController *dosageSelectionViewController;
}

@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
 
@end

@implementation DCAddMedicationInitialViewController

#pragma mark - View Management Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewForEditMedicationState];
    [self configureViewElements];
    medicationDetailsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

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

//configuring the add button and cancel button as navigation button items on the navigation bar.

- (void)configureNavigationBar {
    
    addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:SAVE_BUTTON_TITLE style:UIBarButtonItemStylePlain  target:self action:@selector(addMedicationButtonPressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(addMedicationCancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIView *titleView = [[UIView alloc]initWithFrame:TITLE_VIEW_RECT];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:TITLE_VIEW_RECT];
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

- (void)configureViewForEditMedicationState {
    
    if (self.isEditMedication) {
        self.segmentedContolTopLayoutViewHeight.constant = -VIEW_TOP_LAYOUT_VIEW_HEIGHT;
        if([self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED]){
            self.selectedMedication.medicineCategory = WHEN_REQUIRED_VALUE;
        }
        if (self.selectedMedication.endDate == nil) {
            self.selectedMedication.hasEndDate = NO;
        } else {
            self.selectedMedication.hasEndDate = YES;
        }
        self.selectedMedication.timeArray = [DCAddMedicationHelper timesArrayFromScheduleArray:self.selectedMedication.scheduleTimesArray];
    }
}

//Setting the layout margins and seperator space for the table view to zero.

- (void)configureViewElements {
    
    self.preferredContentSize = CGSizeMake(medicationDetailsTableView.contentSize.width, medicationDetailsTableView.frame.size.height);
    if ([self respondsToSelector:@selector(loadViewIfNeeded)]) {
        [self loadViewIfNeeded];
    }
}

//Configuring the medication name cell in the medication detail table view.If the table view is loaded before the medication name is selected,it is loaded with the place holder string.

- (UITableViewCell *)populatedMedicationNameTableCell {
    
    static NSString *cellIdentifier = ADD_MEDICATION_CELL_IDENTIFIER;
    UITableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = SYSTEM_FONT_SIZE_FIFTEEN;
    cell.textLabel.numberOfLines = 0;
    if ([self.selectedMedication.name isEqualToString:EMPTY_STRING] ||  self.selectedMedication.name == nil) {
        self.navigationItem.rightBarButtonItem.enabled = false;
        cell.textLabel.textColor = [UIColor colorForHexString:@"#8f8f95"];
        cell.textLabel.text = NSLocalizedString(@"MEDICATION_NAME", @"hint string");
    } else {
        self.navigationItem.rightBarButtonItem.enabled = true;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = self.selectedMedication.name;
    }
    return cell;
}

- (DCAddMedicationContentCell *)populatedAddMedicationCellForIndexPath:(NSIndexPath *)indexPath forCellType:(CellType)type {
    
    //configuring warning cell, medication details cell, administration time cell
    static NSString *cellIdentifier = ADD_MEDICATION_CONTENT_CELL;
    DCAddMedicationContentCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DCAddMedicationContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (type == eWarningsCell) {
        cell.titleLabel.text = NSLocalizedString(@"WARNINGS", @"Warnings cell title");
        NSInteger warningsCount = self.selectedMedication.severeWarningCount + self.selectedMedication.mildWarningCount;
        [cell configureMedicationContentCellWithWarningsCount:warningsCount];
    } else if (type == eMedicationDetailsCell) {
        cell = [self updatedMedicationDetailsCell:cell atIndexPath:indexPath];
    } else if (type == eSchedulingCell) {
        cell.titleLabel.text = NSLocalizedString(@"FREQUENCY", @"");
        if (doneClicked) {
            //TODO: currently hard coding time values for interval
            if ([self.selectedMedication.scheduling.type isEqualToString:INTERVAL]) {
                NSArray *intervalTimes = @[@{@"time" : @"10:00", @"selected" : @1}];
                self.selectedMedication.timeArray = [NSMutableArray arrayWithArray:intervalTimes];
            }
            cell.titleLabel.textColor = (self.selectedMedication.scheduling.type == nil || self.selectedMedication.timeArray.count == 0)? [UIColor redColor] : [UIColor blackColor];
        }
        cell.descriptionLabel.text = self.selectedMedication.scheduling.type;
    } else if (type == eAdministratingTimeCell) {
        cell.titleLabel.text = NSLocalizedString(@"ADMINISTRATING_TIME", @"");
        [cell configureMedicationAdministratingTimeCell];
        cell = [self updatedAdministrationTimeTableCell:cell];
    } else if (type == eRepeatCell) {
        cell.titleLabel.text = NSLocalizedString(@"REPEAT", @"");
        [cell configureContentCellWithContent:self.selectedMedication.scheduling.specificTimes.repeatObject.repeatType];
    }
    return cell;
}

- (DCDosageMultiLineCell *)dosageCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCDosageMultiLineCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDosageMultiLineCellID];
    if (cell == nil) {
        cell = [[DCDosageMultiLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDosageMultiLineCellID];
    }
    //check if dosage is valid, if not valid highlight field in red
    if (doneClicked) {
        if ([self.selectedMedication.dosage isEqualToString:EMPTY_STRING] || self.selectedMedication.dosage == nil) {
            cell.titleLabel.textColor = [UIColor redColor];
        } else {
            cell.titleLabel.textColor = [UIColor blackColor];
        }
    }
    cell.titleLabel.text = NSLocalizedString(@"DOSAGE", @"Dosage cell title");
    cell.descriptionLabel.numberOfLines = 0;
    cell.descriptionLabel.text = self.selectedMedication.dosage;
    return cell;
}

- (DCAddMedicationContentCell *)updatedMedicationDetailsCell:(DCAddMedicationContentCell *)cell
                                                    atIndexPath:(NSIndexPath *)indexPath {
    
    //doneClicked bool checks if validation is to be done
    if (indexPath.row == ROUTE_INDEX) {
        //if route is not valid, highlight the field in red
        if (doneClicked) {
            if ([self.selectedMedication.route isEqualToString:EMPTY_STRING] || self.selectedMedication.route == nil) {
                cell.titleLabel.textColor = [UIColor redColor];
            } else {
               cell.titleLabel.textColor = [UIColor blackColor];
            }
        }
        cell.titleLabel.text = NSLocalizedString(@"ROUTE", @"Route cell title");
        [cell configureContentCellWithContent:self.selectedMedication.route];
    } else {
        if (doneClicked) {
            if ([self.selectedMedication.medicineCategory isEqualToString:EMPTY_STRING] || self.selectedMedication.medicineCategory == nil) {
                cell.titleLabel.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
            }
        }
        cell.titleLabel.text = NSLocalizedString(@"TYPE", @"Type cell title");
        [cell configureContentCellWithContent:self.selectedMedication.medicineCategory];
    }
    return cell;
}

- (DCDateTableViewCell *)updatedDateAndTimeCellatIndexPath:(NSIndexPath *)indexPath {
    
    //configuring date time section for the selected medication type. This method configures the date and time section based on the selected medication type. Regular medication will have start date, no end date ,end date, administration times cells. ONCE - has only date field. When Required has start date, no end date, end date cells
    DCDateTableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDateCellID];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.isEditMedication = self.isEditMedication;
    if(self.isEditMedication) {
        cell.previousSwitchState = self.selectedMedication.hasEndDate;
    }
    if (cell == nil) {
        cell = [[DCDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDateCellID];
    }
    if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        cell = [self regularMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        cell = [self onceMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    } else {
        cell = [self whenScheduledMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (DCDateTableViewCell *)regularMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                        atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section table cells for regular medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        //when inline picker is not shown
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
        dateAndTimeCell = [self populatedStartDateTableCell:dateAndTimeCell];
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
        NSDate *dateInCurrentZone = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
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
            if (!self.selectedMedication.endDate) {
                tableCell.dateTypeLabel.textColor = [UIColor redColor];
            } else {
                tableCell.dateTypeLabel.textColor = [UIColor blackColor];
            }
        } else {
            tableCell.dateTypeLabel.textColor = [UIColor blackColor];
        }
    } else {
         tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    }
    tableCell.dateTypeLabel.text = NSLocalizedString(@"END_DATE", @"end date cell title");
    NSDate *endDate = [DCDateUtility dateFromSourceString:self.selectedMedication.endDate];
    NSString *dateString = [DCDateUtility dateStringFromDate:endDate inFormat:START_DATE_FORMAT];
    [tableCell configureContentCellWithContent:dateString];
    return tableCell;
}

- (DCDateTableViewCell *)noEndDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //no end date cell configuration
    tableCell.dateTypeLabel.text = NSLocalizedString(@"NO_END_DATE", @"no end date title");
    tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    [tableCell configureCellWithNoEndDateSwitchState:self.selectedMedication.hasEndDate];
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.noEndDateStatus = ^ (BOOL state) {
        if (_datePickerIndexPath != nil) {
            [self collapseOpenedPickerCell];
        }
        self.selectedMedication.hasEndDate = state;
        [self performSelector:@selector(configureNoEndDateTableCellDisplayBasedOnSwitchState) withObject:nil afterDelay:0.1];
    };
    return tableCell;
}

- (void)configureNoEndDateTableCellDisplayBasedOnSwitchState {

    //hide/show no date table cell
    [self collapseOpenedPickerCell];
    NSInteger dateSection = showWarnings? 3 : 2;
    if (!self.selectedMedication.hasEndDate) {
        //hide tablecell
        NSIndexPath *endDateIndexPath;
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            endDateIndexPath = [NSIndexPath indexPathForRow:3 inSection:dateSection];
        } else {
            endDateIndexPath = [NSIndexPath indexPathForRow:2 inSection:dateSection];
        }
        NSMutableArray *indexpaths = [NSMutableArray arrayWithArray:@[endDateIndexPath]];
        if (_datePickerIndexPath.row == (endDateIndexPath.row + 1)) {
            [indexpaths addObject:_datePickerIndexPath];
            _datePickerIndexPath = nil;
        }
         DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endDateIndexPath.row - 1 inSection:endDateIndexPath.section]];
        [tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self deleteEndDateCellAfterDelay:tableCell withEndDateIndexPath:endDateIndexPath];
    } else {
        NSIndexPath *endDateIndexPath;
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            endDateIndexPath = [NSIndexPath indexPathForRow:3 inSection:dateSection];
        } else {
            endDateIndexPath = [NSIndexPath indexPathForRow:2 inSection:dateSection];
        }
        DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endDateIndexPath.row - 1 inSection:3]];
        [tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self insertEndDateCellAfterDelay:tableCell withEndDateIndexPath:endDateIndexPath];
    }
}

- (void)insertEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell withEndDateIndexPath:(NSIndexPath *)endDateIndexPath {
    
    //insert end date cell after delay
    [medicationDetailsTableView beginUpdates];
    [medicationDetailsTableView insertRowsAtIndexPaths:@[endDateIndexPath]
                                      withRowAnimation:UITableViewRowAnimationRight];
    [medicationDetailsTableView endUpdates];
    
    double delayInSeconds = 0.2;
    dispatch_time_t insertTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(insertTime, dispatch_get_main_queue(), ^(void){
        [self enableNoEndDateCellAfterDelay:tableCell];
    });
}

- (void)deleteEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell withEndDateIndexPath:(NSIndexPath *)endDateIndexPath {
    
    NSMutableArray *indexpaths = [NSMutableArray arrayWithArray:@[endDateIndexPath]];
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
    dateAndTimeCell = [self populatedStartDateTableCell:dateAndTimeCell];
    return dateAndTimeCell;
}

- (DCDateTableViewCell *)whenScheduledMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                     atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section for when required medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
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
    [instructionsCell populatePlaceholderForFieldIsInstruction:YES];
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
    return pickerCell;
}

- (NSInteger)numberOfRowsInMedicationTableViewSection:(NSInteger)section {
    
    //checks if warnings section is to be shown and gets the row count based on that.
    switch (section) {
        case eZerothSection:
            return MEDICATION_NAME_ROW_COUNT;
        case eFirstSection:
            return (showWarnings ? WARNINGS_ROW_COUNT : MEDICATION_DETAILS_ROW_COUNT);
        case eSecondSection:
            return (showWarnings ? MEDICATION_DETAILS_ROW_COUNT : [self numberOfRowsInDateAndTimeSectionForSelectedMedicationType]);
        case eThirdSection: {
            NSInteger rowCount = [self numberOfRowsInDateAndTimeSectionForSelectedMedicationType];
            return (showWarnings ? rowCount : 1);
        }
        default:
            return 1;
    }
    return MEDICATION_NAME_ROW_COUNT;
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
    } else {
        showWarnings = NO;
    }
    self.selectedMedication = [[DCMedicationScheduleDetails alloc] init];
    self.selectedMedication.name = medication.name;
    self.selectedMedication.medicationId = medication.medicationId;
    self.selectedMedication.dosage = medication.dosage;
    self.selectedMedication.hasEndDate = NO;
    self.selectedMedication.severeWarningCount = severeArray.count;
    self.selectedMedication.mildWarningCount = mildArray.count;
    self.selectedMedication.medicineCategory = REGULAR_MEDICATION;
    self.selectedMedication.scheduling = [[DCScheduling alloc] init];
//    self.selectedMedication.scheduling.type = SPECIFIC_TIMES;
//    self.selectedMedication.scheduling.repeat = [[DCRepeat alloc] init];
//    self.selectedMedication.scheduling.repeat.repeatType = DAILY;
//    self.selectedMedication.scheduling.repeat.frequency = @"1 day";
    dosageArray = [NSMutableArray arrayWithObjects:medication.dosage, nil];
    [medicationDetailsTableView reloadData];
}

- (void)displayWarningsListView {
    
    //display Warnings list view
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCWarningsListViewController *warningsListViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:WARNINGS_LIST_STORYBOARD_ID];
    [warningsListViewController populateWarningsListWithWarnings:warningsArray showOverrideView:NO];
    [self.navigationController pushViewController:warningsListViewController animated:YES];
}

- (void)updateMedicationDetailsTableViewWithSelectedValue:(NSString *)selectedValue
                                           withDetailType:(AddMedicationDetailType)detailType {
    
    switch (detailType) {
        case eDetailType:
            self.selectedMedication.medicineCategory = selectedValue;
            [self resetDateAndTimeSection];
            break;
        case eDetailRoute:
            self.selectedMedication.route =  selectedValue;
            break;
        case eDetailDosage:
            if (![selectedValue isEqualToString:NSLocalizedString(@"ADD_NEW", @"")]) {
                self.selectedMedication.dosage = selectedValue;
            }
            break;
        default:
            break;
    }
    [medicationDetailsTableView reloadData];
}

- (void)displayAddMedicationDetailViewForTableRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //display add medication detail view
    if ([DCAddMedicationHelper medicationDetailTypeForIndexPath:indexPath hasWarnings:showWarnings] == 1) {
        
        UIStoryboard *dosageStoryboard = [UIStoryboard storyboardWithName:DOSAGE_STORYBORD bundle:nil];
        dosageSelectionViewController = [dosageStoryboard instantiateViewControllerWithIdentifier:DOSAGE_SELECTION_SBID];
        dosageSelectionViewController.newDosageAddedDelegate = self;
        dosageSelectionViewController.dosageArray = dosageArray;
        dosageSelectionViewController.menuType = eDosageMenu;
        [self.navigationController pushViewController:dosageSelectionViewController animated:YES];
        
    } else {
        
        UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
        DCAddMedicationDetailViewController *medicationDetailViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAIL_STORYBOARD_ID];
        medicationDetailViewController.delegate = self;
        __weak DCAddMedicationDetailViewController *weakDetailVc = medicationDetailViewController;
        medicationDetailViewController.selectedEntry = ^ (NSString *value) {
            [self updateMedicationDetailsTableViewWithSelectedValue:value withDetailType:weakDetailVc.detailType];
        };
        medicationDetailViewController.detailType = [DCAddMedicationHelper medicationDetailTypeForIndexPath:indexPath hasWarnings:showWarnings];
        DCAddMedicationContentCell *selectedCell = [self selectedCellAtIndexPath:indexPath];
        if (indexPath.section != 3) {
            medicationDetailViewController.previousFilledValue = selectedCell.descriptionLabel.text;
        }
        if (medicationDetailViewController.detailType == eDetailDosage) {
            if (self.isEditMedication) {
                medicationDetailViewController.contentArray = [NSMutableArray arrayWithObject:selectedCell.descriptionLabel.text];
            } else {
                medicationDetailViewController.contentArray = dosageArray;
            }
        } else if (medicationDetailViewController.detailType == eDetailAdministrationTime) {
            medicationDetailViewController.contentArray = self.selectedMedication.timeArray;
        }
        [self.navigationController pushViewController:medicationDetailViewController animated:YES];
    }
}

- (void)displaySchedulingDetailViewForTableViewAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCSchedulingInitialViewController *schedulingViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:SCHEDULING_INITIAL_STORYBOARD_ID];
   // AddMedicationDetailType detailType = [DCAddMedicationHelper medicationDetailTypeForIndexPath:indexPath hasWarnings:showWarnings];
//    schedulingDetailViewController.detailType = detailType;
    //TODO: temporarrly added... remove this on actual scheduling data from api
//    if (self.isEditMedication) {
//        if (self.selectedMedication.scheduling == nil) {
//            self.selectedMedication.scheduling = [[DCScheduling alloc] init];
//            self.selectedMedication.scheduling.type = SPECIFIC_TIMES;
//        }
//        if (self.selectedMedication.scheduling.repeat == nil) {
//            self.selectedMedication.scheduling.repeat = [[DCRepeat alloc] init];
//            self.selectedMedication.scheduling.repeat.repeatType = DAILY;
//            self.selectedMedication.scheduling.repeat.frequency = @"1 day";
//        }
//    }
//    schedulingDetailViewController.repeatValue = self.selectedMedication.scheduling.repeat;
//    schedulingDetailViewController.selectedEntry = ^ (NSString *selectedValue){
//        if (detailType == eDetailSchedulingType) {
//            self.selectedMedication.scheduling.type = selectedValue;
//        }
//    };
//    schedulingDetailViewController.repeatCompletion = ^ (DCRepeat *repeat) {
//        self.selectedMedication.scheduling.repeat = repeat;
//    };
//    DCAddMedicationContentCell *selectedCell = [self selectedCellAtIndexPath:indexPath];
//    schedulingDetailViewController.previousFilledValue = selectedCell.descriptionLabel.text;
    schedulingViewController.selectedSchedulingValue = ^ (DCScheduling *scheduling) {
        
    };
    schedulingViewController.updatedTimeArray = ^ (NSMutableArray *timeArray) {
        self.selectedMedication.timeArray = timeArray;
    };
    if (self.isEditMedication) {
        if (self.selectedMedication.scheduling == nil) {
            self.selectedMedication.scheduling = [[DCScheduling alloc] init];
        }
    }
    schedulingViewController.scheduling = self.selectedMedication.scheduling;
    schedulingViewController.timeArray = self.selectedMedication.timeArray;
    schedulingViewController.validate = doneClicked;
    
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

- (void)scrollToTextViewCellIfInstructionField:(BOOL)isInstruction {
    
    //scroll table view to instructions cell position
    NSIndexPath *scrollIndexPath;
    if (isInstruction) {
         if (showWarnings) {
             scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:6];
         } else {
             scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:5];
         }
    } else {
        if (showWarnings) {
            scrollIndexPath = [NSIndexPath indexPathForRow:2 inSection:6];
        } else {
            scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:5];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//TODO: check why scrollto indexpath not working
//        [medicationDetailsTableView scrollToRowAtIndexPath:scrollIndexPath
//                                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
          [medicationDetailsTableView setContentOffset:CGPointMake(0, 400) animated:YES];
    });
}

- (void)resignKeyboard {
    
    //resign keyboard
    DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
    if ([instructionsCell.instructionsTextView isFirstResponder]) {
        [instructionsCell.instructionsTextView resignFirstResponder];
    }
    [self.view endEditing:YES];
}

- (void)displayDetailViewForSelectedCellAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eZerothSection:// display medicine name in initial section and detail view will be MedicationListView
            [self displayMedicationSearchListView];
            break;
        case eFirstSection:
            if (showWarnings) { //if tableview has warnings section, 'Warnings' selection displays Warnings List, Other wise detail screen display will be that of dosage, route, type
                [self displayWarningsListView];
            } else {
                [self displayAddMedicationDetailViewForTableRowAtIndexPath:indexPath];
            }
            break;
        case eSecondSection:
            if (showWarnings) { //If tableview has warnings section, Second section cell selection shows detail screen for dosage/route/type, otherwise present keyboard in instructions text view
                [self displayAddMedicationDetailViewForTableRowAtIndexPath:indexPath];
            } else {
                [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
                
            }
            break;
        case eThirdSection: {
            if (showWarnings) { // If Warnings section is shown, third section present instruction text view keyboard,, otherwise load date and time detail section
                [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
            } else {
                [self displaySchedulingDetailViewForTableViewAtIndexPath:indexPath];
            }
        }
            break;
        case eFourthSection:
            if (showWarnings) {
                [self displaySchedulingDetailViewForTableViewAtIndexPath:indexPath];
            } else {
                [self displayAddMedicationDetailViewForTableRowAtIndexPath:indexPath];
            }
            break;
        case eFifthSection:
            if (showWarnings) {
                [self displayAddMedicationDetailViewForTableRowAtIndexPath:indexPath];
            } else {
                DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                [instructionsCell.instructionsTextView becomeFirstResponder];
            }
            break;
        case eSixthSection: {
            DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
            [instructionsCell.instructionsTextView becomeFirstResponder];
        }
            break;
        default:{
            [self displayAddMedicationDetailViewForTableRowAtIndexPath:indexPath];
        }
            break;
    }
    [medicationDetailsTableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)presentAdministrationTimeView {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCAddMedicationDetailViewController *medicationDetailViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAIL_STORYBOARD_ID];
    medicationDetailViewController.delegate = self;
    __weak DCAddMedicationDetailViewController *weakDetailVc = medicationDetailViewController;
    medicationDetailViewController.selectedEntry = ^ (NSString *value) {
        [self updateMedicationDetailsTableViewWithSelectedValue:value withDetailType:weakDetailVc.detailType];
    };
    medicationDetailViewController.detailType = eDetailAdministrationTime;
    medicationDetailViewController.contentArray = self.selectedMedication.timeArray;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medicationDetailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navigationController animated:YES completion:nil];
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
        [addButton setEnabled:YES];
    }];
}

- (void)callDeleteMedicationWebServicewithCallBackHandler:(void (^)(NSError *error))callBack {
    
    DCStopMedicationWebService *webServiceManager = [[DCStopMedicationWebService alloc] init];
    [webServiceManager stopMedicationForPatientWithId:self.patientId drugWithScheduleId:self.selectedMedication.scheduleId  withCallBackHandler:^(id response, NSError *error) {
        callBack(error);
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
        pickerCell.isStartDate = (indexPath.row == 1) ? YES : NO;
        __weak DCDatePickerCell *weakPickerCell = pickerCell;
        pickerCell.selectedDate = ^ (NSDate *date) {
            NSIndexPath *indexPathToUpdate = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            DCDateTableViewCell *dateCell = [self updatedDateAndTimeCellatIndexPath:indexPathToUpdate];
            NSDate *dateInCurrentZone = [DCDateUtility dateInCurrentTimeZone:date];
            NSString *dateString = [DCDateUtility dateStringFromDate:dateInCurrentZone inFormat:START_DATE_FORMAT];
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
    if (doneClicked) {
        if ([self.selectedMedication.dosage isEqualToString:EMPTY_STRING] || self.selectedMedication.dosage == nil) {
            cell.titleLabel.textColor = [UIColor redColor];
        } else {
            cell.titleLabel.textColor = [UIColor blackColor];
        }
    }
    cell.titleLabel.text = NSLocalizedString(@"DOSAGE", @"Dose cell title");
    [cell configureContentCellWithContent:self.selectedMedication.dosage];
    return cell;
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
            UITableViewCell *cell = [self populatedMedicationNameTableCell];
            return cell;
        }
        case eFirstSection: { // first section will have warnings or medication details based on warnings section display
            if (!showWarnings) {
                DCAddMedicationContentCell *contentCell = [self populatedAddMedicationCellForIndexPath:indexPath forCellType:eMedicationDetailsCell];
                return contentCell;
            } else {
                DCAddMedicationContentCell *contentCell = [self populatedAddMedicationCellForIndexPath:indexPath forCellType:eWarningsCell];
                return contentCell;
            }
        }
        case eSecondSection: {
            if (showWarnings) {
                DCAddMedicationContentCell *contentCell = [self populatedAddMedicationCellForIndexPath:indexPath forCellType:eMedicationDetailsCell];
                return contentCell;
            }
            else {
                UITableViewCell *dateCell = [self dateSectionTableViewCellAtIndexPath:indexPath];
                return dateCell;
            }
        }
        case eThirdSection: {
            if (showWarnings) {
                UITableViewCell *dateCell = [self dateSectionTableViewCellAtIndexPath:indexPath];
                return dateCell;
            } else {
                DCAddMedicationContentCell *contentCell = [self populatedAddMedicationCellForIndexPath:indexPath forCellType:eSchedulingCell];
                return contentCell;
            }
        }
        case eFourthSection: {
            if (showWarnings) {
                DCAddMedicationContentCell *contentCell = [self populatedAddMedicationCellForIndexPath:indexPath forCellType:eSchedulingCell];
                return contentCell;
            } else {
                if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    DCDosageMultiLineCell *dosageCell = [self dosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCAddMedicationContentCell *doseCell = [self singleLineDoseCellAtIndexPath:indexPath];
                    return doseCell;
                }
            }
            }
        case eFifthSection: {
            if (showWarnings) {
                if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    DCDosageMultiLineCell *dosageCell = [self dosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCAddMedicationContentCell *doseCell = [self singleLineDoseCellAtIndexPath:indexPath];
                    return doseCell;
                }
            } else {
                DCInstructionsTableCell *instructionsCell = [self instructionsTableCell];
                return instructionsCell;
            }
         }
        case eSixthSection: {
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
    } else if (indexPath.section == eSecondSection){
        if (!showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        }
    } else if (indexPath.section == eThirdSection){
        if (showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        }
    } else if (indexPath.section == eFourthSection) {
        if (showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        } else {
            if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                CGSize textSize = [DCUtility textViewSizeWithText:self.selectedMedication.dosage maxWidth:258 font:[UIFont systemFontOfSize:15]];
                return textSize.height + 40; // padding size of 40
            }
        }
    } else if (indexPath.section == eFifthSection) {
        if (showWarnings) {
            // calculate the height for the given text
            if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                CGSize textSize = [DCUtility textViewSizeWithText:self.selectedMedication.dosage maxWidth:258 font:[UIFont systemFontOfSize:15]];
                return textSize.height + 40; // padding size of 40
            }
        } else {
            return INSTRUCTIONS_ROW_HEIGHT;
        }
    } else if (indexPath.section == eSixthSection) {
        return INSTRUCTIONS_ROW_HEIGHT;
    }
    return TABLE_CELL_DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //shrink already opened date picker cell
    [self resignKeyboard];
    if ((indexPath.section != _datePickerIndexPath.section)) {
         [self collapseOpenedPickerCell];
    } else {
        //date and time section, check for the administarting time row and collapse any
        //picker if opened for Regular medication
        if (([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]  || [self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED_VALUE]) &&
            indexPath.row == [self numberOfRowsInMedicationTableViewSection:3] - 1) {
            [self collapseOpenedPickerCell];
        }
    }
    [self displayDetailViewForSelectedCellAtIndexPath:indexPath];
}

#pragma mark - Action Methods

- (void)addMedicationButtonPressed:(id)sender {
    
    //add medication button action
    doneClicked = YES;
    [medicationDetailsTableView reloadData];
    [self configureInstructionForMedication];
    if ([DCAddMedicationHelper selectedMedicationDetailsAreValid:self.selectedMedication]) {
        if ([DCAPPDELEGATE isNetworkReachable]) {
            if (self.isEditMedication) {
                // To Do: API need to be integrated.
//                NSDate *dateInCurrentZone = [DCDateUtility dateInCurrentTimeZone:[NSDate date]];
//                NSString *dateString = [DCDateUtility convertDate:dateInCurrentZone FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
//                self.selectedMedication.startDate = dateString;
//                [self callDeleteMedicationWebServicewithCallBackHandler:^(NSError *error) {
//                    if (!error) {
//                        [self callAddMedicationWebService];
//                    } else {
//                        [self displayAlertWithTitle:@"ERROR" message:@"Edit medication failed"];
//                    }
//                }];
//TODO : temporarly added till api is available
                if (self.delegate && [self.delegate respondsToSelector:@selector(medicationEditCancelledForIndexPath:)]) {
                    [self.delegate medicationEditCancelledForIndexPath:_medicationEditIndexPath];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [addButton setEnabled:NO];
                [self callAddMedicationWebService];
            }
        }
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
        [medicationDetailsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:3]]
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

#pragma mark - Instruction Delegates

- (void)closeInlineDatePickers {
    
    [self collapseOpenedPickerCell];
}

- (void)scrollTableViewToTextViewCellIfInstructionField:(BOOL)isInstruction {
    
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToTextViewCellIfInstructionField:isInstruction];
   // });
}

- (void)updateTextViewText:(NSString *)instructions isInstruction:(BOOL)isInstruction {
    
    if (isInstruction) {
        self.selectedMedication.instruction = instructions;
    } else {
        self.selectedMedication.scheduling.schedulingDescription = instructions;
    }
}

- (void)configureInstructionForMedication {

    NSIndexPath *instructionIndexPath;
    if (showWarnings) {
        instructionIndexPath = [NSIndexPath indexPathForRow:0 inSection:eSixthSection];
    } else {
        instructionIndexPath = [NSIndexPath indexPathForRow:0 inSection:eFifthSection];
    }
    DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:instructionIndexPath];
    if (![instructionsCell.instructionsTextView.text isEqualToString:INSTRUCTIONS]) {
        self.selectedMedication.instruction = instructionsCell.instructionsTextView.text;
    }
}

- (NSMutableArray *)timesArrayFromScheduleArray:(NSArray *)scheduleArray {
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    for (NSString *time in scheduleArray) {
        NSString *dateString = [DCUtility convertTimeToHourMinuteFormat:time];
        NSDictionary *timeDictionary = @{TIME : dateString, SELECTED : @1};
        [timeArray addObject:timeDictionary];
    }
    return timeArray;
}

#pragma mark - UIPopOverPresentationCOntroller Delegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    //this method restricts the pop over dismiss on tapping pop over background. 
    return NO;
}

@end
