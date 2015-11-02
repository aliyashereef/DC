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

@interface DCAddMedicationInitialViewController () <UITableViewDelegate, UITableViewDataSource, AddMedicationDetailDelegate,InstructionCellDelegate> {
    
    __weak IBOutlet UITableView *medicationDetailsTableView;
    __weak IBOutlet UILabel *orderSetLabel;
    UIBarButtonItem *addButton;
    
    NSMutableArray *dosageArray;
    NSArray *warningsArray;
    NSInteger lastSection;
    BOOL doneClicked;// for validation purpose
    BOOL showWarnings;//to check if warnings section is displayed
}

@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
 
@end

@implementation DCAddMedicationInitialViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureViewForEditMedicationState];
    [self configureViewElements];
}

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
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
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
        self.segmentedContolTopLayoutViewHeight.constant = -50;
        if([self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED]){
            self.selectedMedication.medicineCategory = WHEN_REQUIRED_VALUE;
        }
        if (self.selectedMedication.endDate == nil) {
            self.selectedMedication.noEndDate = YES;
            
        }
        self.selectedMedication.timeArray = [self getTimesArrayFromScheduleArray:self.selectedMedication.scheduleTimesArray];
    }
}

//Setting the layout margins and seperator space for the table view to zero.
- (void)configureViewElements {
    
    medicationDetailsTableView.layoutMargins = UIEdgeInsetsZero;
    medicationDetailsTableView.separatorInset = UIEdgeInsetsZero;
    self.preferredContentSize = CGSizeMake(medicationDetailsTableView.contentSize.width, medicationDetailsTableView.frame.size.height);
    if ([self respondsToSelector:@selector(loadViewIfNeeded)]) {
        [self loadViewIfNeeded];
    }
}

//Configuring the medication name cell in the medication detail table view.If the table view is loaded before the medication name is selected,it is loaded with the place holder string.
- (UITableViewCell *)getPopulatedMedicationNameTableCell {
    
    static NSString *cellIdentifier = ADD_MEDICATION_CELL_IDENTIFIER;
    UITableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layoutMargins = UIEdgeInsetsZero;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = SYSTEM_FONT_SIZE_FIFTEEN;
    cell.textLabel.numberOfLines = 0;
    if ([self.selectedMedication.name isEqualToString:EMPTY_STRING] ||  self.selectedMedication.name == nil) {
        self.navigationItem.rightBarButtonItem.enabled = false;
        cell.textLabel.textColor = [UIColor getColorForHexString:@"#8f8f95"];
        cell.textLabel.text = NSLocalizedString(@"MEDICATION_NAME", @"hint string");
    } else {
        self.navigationItem.rightBarButtonItem.enabled = true;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = self.selectedMedication.name;
    }
    return cell;
}

- (DCAddMedicationContentCell *)getPopulatedAddMedicationCellForIndexPath:(NSIndexPath *)indexPath forIndex:(NSInteger)index {
    
    //configuring warning cell, medication details cell, administration time cell
    static NSString *cellIdentifier = ADD_MEDICATION_CONTENT_CELL;
    DCAddMedicationContentCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layoutMargins = UIEdgeInsetsZero;
    if (cell == nil) {
        cell = [[DCAddMedicationContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (index == WARNINGS_CELL_INDEX) {
        cell.titleLabel.text = NSLocalizedString(@"WARNINGS", @"Warnings cell title");
        NSInteger warningsCount = self.selectedMedication.severeWarningCount + self.selectedMedication.mildWarningCount;
        [cell configureMedicationContentCellWithWarningsCount:warningsCount];
    } else if (index == MEDICATION_DETAILS_CELL_INDEX) {
        cell = [self getUpdatedMedicationDetailsCell:cell atIndexPath:indexPath];
    } else {
        if (indexPath.row == ADMINISTRATING_TIME_ROW_INDEX) {
            cell.titleLabel.text = NSLocalizedString(@"ADMINISTRATING_TIME", @"");
            [cell configureMedicationAdministratingTimeCell];
        }
    }
    return cell;
}

- (DCDosageMultiLineCell *)getDosageCellAtIndexPath: (NSIndexPath *)indexPath {
    DCDosageMultiLineCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDosageMultiLineCellID];
    cell.layoutMargins = UIEdgeInsetsZero;
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

- (DCAddMedicationContentCell *)getUpdatedMedicationDetailsCell:(DCAddMedicationContentCell *)cell
                                                    atIndexPath:(NSIndexPath *)indexPath {
    
    //doneClicked bool checks if validation is to be done
    if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length <= MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
        //check if dosage is valid, if not valid highlight field in red
        if (doneClicked) {
            if ([self.selectedMedication.dosage isEqualToString:EMPTY_STRING] || self.selectedMedication.dosage == nil) {
                cell.titleLabel.textColor = [UIColor redColor];
            } else {
                cell.titleLabel.textColor = [UIColor blackColor];
            }
        }
        cell.titleLabel.text = NSLocalizedString(@"DOSAGE", @"Dosage cell title");
        [cell configureContentCellWithContent:self.selectedMedication.dosage];
    } else if (indexPath.row == ROUTE_INDEX) {
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

- (DCDateTableViewCell *)getUpdatedDateAndTimeCellatIndexPath:(NSIndexPath *)indexPath {
    
    //configuring date time section for the selected medication type. This method configures the date and time section based on the selected medication type. Regular medication will have start date, no end date ,end date, administration times cells. ONCE - has only date field. When Required has start date, no end date, end date cells
    DCDateTableViewCell *cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:kDateCellID];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.isEditMedication = self.isEditMedication;
    if(self.isEditMedication) {
        cell.previousSwitchState = self.selectedMedication.noEndDate;
    }
    if (cell == nil) {
        cell = [[DCDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDateCellID];
    }
    if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        cell = [self getRegularMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        cell = [self getOnceMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    } else {
        cell = [self getWhenScheduledMedicationUpdatedDateAndTimeCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (DCDateTableViewCell *)getRegularMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                        atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section table cells for regular medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        //when inline picker is not shown
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
        dateAndTimeCell = [self getPopulatedStartDateTableCell:dateAndTimeCell];
    } else {
        if (self.datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            //  Start date cell has inline picker shown, So the very next cell to inline picker will be no wnd date cell. If opted to have end date, datePickerIndexPath.row + 2 shows end date cell and the last row will be administartion times cell. If no end date is chosen, datePickerIndexPath.row + 2 displays administration times cell
            if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 1) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            }
            if (!self.selectedMedication.noEndDate) {
                //has end date,
                if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 2)  {
                    dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
                } else if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 3) {
                    dateAndTimeCell = [self getUpdatedAdministrationTimeTableCell:dateAndTimeCell];
                }
            } else {
                if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 2)  {
                    dateAndTimeCell = [self getUpdatedAdministrationTimeTableCell:dateAndTimeCell];
                }
            }
        } else if (self.datePickerIndexPath.row == DATE_PICKER_INDEX_END_DATE) {
            //has inline picker at end date cell. End date cell has inline date picker displayed, the very next and last row will be the administration times cell. datePickerIndexPath.row - 1 is the end date cell. datePickerIndexPath.row - 2 is the no end date cell.
            if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 2) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            } else if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 1)  {
                dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
            } else if (indexPath.row == DATE_PICKER_INDEX_END_DATE + 1) {
                dateAndTimeCell = [self getUpdatedAdministrationTimeTableCell:dateAndTimeCell];
            }
        } else {
            //no inline date picker.
            if (indexPath.row == NO_END_DATE_ROW_INDEX) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            } else {
                if (!self.selectedMedication.noEndDate) { //has end date
                    if (indexPath.row == END_DATE_ROW_INDEX) {
                        dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
                    } else {
                        dateAndTimeCell = [self getUpdatedAdministrationTimeTableCell:dateAndTimeCell];
                    }
                } else {
                    dateAndTimeCell = [self getUpdatedAdministrationTimeTableCell:dateAndTimeCell];
                }
            }
        }
    }
    return dateAndTimeCell;
}

- (DCDateTableViewCell *)getPopulatedStartDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //configure start date cell
    tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    tableCell.dateTypeWidth.constant = TIME_TITLE_LABEL_WIDTH;
    if (!self.selectedMedication.startDate || [self.selectedMedication.startDate isEqualToString:EMPTY_STRING]) {
        NSDate *dateInCurrentZone = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
        NSString *dateString = [DCDateUtility convertDate:dateInCurrentZone FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
//        NSString *dateString = [DCDateUtility getDisplayDateForAddMedication:
//                                [DCDateUtility getDateInCurrentTimeZone:[NSDate date]] dateAndTime:YES];
        self.selectedMedication.startDate = dateString;
        [tableCell configureContentCellWithContent:dateString];
    }
    NSDate *startDate = [DCDateUtility dateFromSourceString:self.selectedMedication.startDate];
    NSString *dateString = [DCDateUtility convertDate:startDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
    
    [tableCell configureContentCellWithContent:dateString];
    return tableCell;
}

- (DCDateTableViewCell *)getUpdatedEndDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //doneClicked bool checks if validation is to be performed or not.
    if (doneClicked) {
        if (!self.selectedMedication.noEndDate) {//has end date
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
    NSString *dateString = [DCDateUtility convertDate:endDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
    [tableCell configureContentCellWithContent:dateString];
    return tableCell;
}

- (DCDateTableViewCell *)getNoEndDateTableCell:(DCDateTableViewCell *)tableCell {
    
    //no end date cell configuration
    tableCell.dateTypeLabel.text = NSLocalizedString(@"NO_END_DATE", @"no end date title");
    tableCell.dateTypeLabel.textColor = [UIColor blackColor];
    [tableCell configureCellWithNoEndDateSwitchState:self.selectedMedication.noEndDate];
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.noEndDateStatus = ^ (BOOL state) {
        if (_datePickerIndexPath != nil) {
            [self collapseOpenedPickerCell];
            self.selectedMedication.noEndDate = state;
            [self performSelector:@selector(configureNoEndDateTableCellDisplayBasedOnSwitchState) withObject:nil afterDelay:0.1];
        } else {
            self.selectedMedication.noEndDate = state;
            [self configureNoEndDateTableCellDisplayBasedOnSwitchState];
        }
    };
    return tableCell;
}

- (void)configureNoEndDateTableCellDisplayBasedOnSwitchState {
    if(_isEditMedication) {
        if (self.selectedMedication.hasWarning) {
            lastSection = eFourthSection;
        } else {
            lastSection = eThirdSection;
        }
    }
    
    //hide/show no date table cell
    if (self.selectedMedication.noEndDate) {
        //hide tablecell
        NSIndexPath *endDateIndexPath;
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            endDateIndexPath = [NSIndexPath indexPathForRow:3 inSection:lastSection];
        } else {
            endDateIndexPath = [NSIndexPath indexPathForRow:2 inSection:lastSection];
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
            endDateIndexPath = [NSIndexPath indexPathForRow:3 inSection:lastSection];
        } else {
            endDateIndexPath = [NSIndexPath indexPathForRow:2 inSection:lastSection];
        }
        DCDateTableViewCell *tableCell = (DCDateTableViewCell *)[medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endDateIndexPath.row - 1 inSection:endDateIndexPath.section]];
        [tableCell.noEndDateSwitch setUserInteractionEnabled:NO];
        [self insertEndDateCellAfterDelay:tableCell withEndDateIndexPath:endDateIndexPath];
    }
}

- (void)insertEndDateCellAfterDelay:(DCDateTableViewCell *)tableCell withEndDateIndexPath:(NSIndexPath *)endDateIndexPath {
    
    //insert end date cell after delay
    [medicationDetailsTableView insertRowsAtIndexPaths:@[endDateIndexPath]
                                      withRowAnimation:UITableViewRowAnimationRight];
    
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

- (DCDateTableViewCell *)getUpdatedAdministrationTimeTableCell:(DCDateTableViewCell *)tableCell {
    
    tableCell.dateTypeWidth.constant =  ADMINISTRATING_TITLE_LABEL_WIDTH;
    if (doneClicked) {
        if ([self.selectedMedication.timeArray count] == 0) {
            tableCell.dateTypeLabel.textColor = [UIColor redColor];
        } else {
            tableCell.dateTypeLabel.textColor = [UIColor blackColor];
        }
    }
    tableCell.dateTypeLabel.text = NSLocalizedString(@"ADMINISTRATING_TIME", @"administration time title");
    return tableCell;
}

- (DCDateTableViewCell *)getOnceMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                        atIndexPath:(NSIndexPath *)indexPath {
    
    dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"DATE", @"date cell title");
    dateAndTimeCell = [self getPopulatedStartDateTableCell:dateAndTimeCell];
    return dateAndTimeCell;
}

- (DCDateTableViewCell *)getWhenScheduledMedicationUpdatedDateAndTimeCell:(DCDateTableViewCell *)dateAndTimeCell
                                                     atIndexPath:(NSIndexPath *)indexPath {
    
    //Date and time section for when required medication
    if (indexPath.row == START_DATE_ROW_INDEX) {
        dateAndTimeCell.dateTypeLabel.text = NSLocalizedString(@"START_DATE", @"start date cell title");
        dateAndTimeCell = [self getPopulatedStartDateTableCell:dateAndTimeCell];
    } else {
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 1) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            } else  {
                if (!self.selectedMedication.noEndDate) {
                    dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
                }
            }
        } else if (_datePickerIndexPath.row == DATE_PICKER_INDEX_END_DATE) {
            if (indexPath.row == DATE_PICKER_INDEX_END_DATE - 2) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            } else {
                if (!self.selectedMedication.noEndDate) {
                    dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
                }
            }
        } else {
            if (indexPath.row == NO_END_DATE_ROW_INDEX) {
                dateAndTimeCell = [self getNoEndDateTableCell:dateAndTimeCell];
            } else {
                dateAndTimeCell = [self getUpdatedEndDateTableCell:dateAndTimeCell];
            }
        }
    }
    return dateAndTimeCell;
}

- (DCInstructionsTableCell *)getInstructionsTableCell {
    
    static NSString *cellIdentifier = INSTRUCTIONS_CELL_IDENTIFIER;
    DCInstructionsTableCell *instructionsCell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    instructionsCell.delegate = self;
    instructionsCell.layoutMargins = UIEdgeInsetsZero;
    if (instructionsCell == nil) {
        instructionsCell = [[DCInstructionsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.selectedMedication.instruction) {
        instructionsCell.instructionsTextView.text = self.selectedMedication.instruction;
    }
    return instructionsCell;
}

- (DCDatePickerCell *)getDatePickerTableCell {
    
    static NSString *pickerCellId = DATE_PICKER_CELL_IDENTIFIER;
    DCDatePickerCell *pickerCell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:pickerCellId];
    if (pickerCell == nil) {
        pickerCell = [[DCDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pickerCellId];
    }
    return pickerCell;
}

- (NSInteger)numberOfSectionsInMedicationTableView {
    
    //If medicine name is not selected, the number of sections in tableview will be 1 , On medicine name selection, the section count vary based on warnings presence
    if ([self.selectedMedication.name isEqualToString:EMPTY_STRING] || self.selectedMedication.name == nil) {
        return INITIAL_SECTION_COUNT;
    } else {
       return (showWarnings ? COMPLETE_MEDICATION_SECTION_COUNT : COMPLETE_MEDICATION_SECTION_COUNT - 1);
    }
    return INITIAL_SECTION_COUNT;
}

- (NSInteger)numberOfRowsInMedicationTableViewSection:(NSInteger)section {
    
    //checks if warnings section is to be shown and gets the row count based on that.
    switch (section) {
        case eZerothSection:
            return MEDICATION_NAME_ROW_COUNT;
            break;
        case eFirstSection:
            return (showWarnings ? WARNINGS_ROW_COUNT : MEDICATION_DETAILS_ROW_COUNT);
            break;
        case eSecondSection:
            return (showWarnings ? MEDICATION_DETAILS_ROW_COUNT : INSTRUCTIONS_ROW_COUNT);
            break;
        case eThirdSection:
            return (showWarnings ? INSTRUCTIONS_ROW_COUNT : [self getNumberOfRowsInDateAndTimeSectionForSelectedMedicationType]);
            break;
        case eFourthSection: {
            NSInteger rowCount = [self getNumberOfRowsInDateAndTimeSectionForSelectedMedicationType];
            return (showWarnings ? rowCount : MEDICATION_NAME_ROW_COUNT);
        }
            break;
        default:
            break;
    }
    return MEDICATION_NAME_ROW_COUNT;
}

- (NSInteger)getNumberOfRowsInDateAndTimeSectionForSelectedMedicationType {
    
    NSInteger rowCount;
    if ([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]) {
        rowCount = self.selectedMedication.noEndDate ? REGULAR_DATEANDTIME_ROW_COUNT - 1 : REGULAR_DATEANDTIME_ROW_COUNT;
    } else if ([self.selectedMedication.medicineCategory isEqualToString:ONCE_MEDICATION]) {
        rowCount = ONCE_DATEANDTIME_ROW_COUNT;
    } else {
        rowCount = self.selectedMedication.noEndDate ? WHEN_REQUIRED_DATEANDTIME_ROW_COUNT - 1 : WHEN_REQUIRED_DATEANDTIME_ROW_COUNT;
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
        lastSection = eFourthSection;
    } else {
        showWarnings = NO;
        lastSection = eThirdSection;
    }
    self.selectedMedication = [[DCMedicationScheduleDetails alloc] init];
    self.selectedMedication.name = medication.name;
    self.selectedMedication.medicationId = medication.medicationId;
    self.selectedMedication.dosage = medication.dosage;
    self.selectedMedication.noEndDate = YES;
    self.selectedMedication.severeWarningCount = severeArray.count;
    self.selectedMedication.mildWarningCount = mildArray.count;
    self.selectedMedication.medicineCategory = REGULAR_MEDICATION;
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
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCAddMedicationDetailViewController *medicationDetailViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAIL_STORYBOARD_ID];
    medicationDetailViewController.delegate = self;
    __weak DCAddMedicationDetailViewController *weakDetailVc = medicationDetailViewController;
    medicationDetailViewController.selectedEntry = ^ (NSString *value) {
        NSLog(@"value is %@", value);
        [self updateMedicationDetailsTableViewWithSelectedValue:value withDetailType:weakDetailVc.detailType];
    };
    medicationDetailViewController.detailType = [self getMedicationDetailTypeForIndexPath:indexPath];
    DCAddMedicationContentCell *selectedCell = (DCAddMedicationContentCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section != lastSection) {
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

- (AddMedicationDetailType)getMedicationDetailTypeForIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eFirstSection: {
            if (showWarnings) {
                return eDetailWarning;
            } else {
                if (indexPath.row == DOSAGE_INDEX) {
                    return eDetailDosage;
                } else if (indexPath.row == ROUTE_INDEX) {
                    return eDetailRoute;
                } else {
                    return eDetailType;
                }
            }
        }
        break;
        case eSecondSection: {
            if (showWarnings) {
                if (indexPath.row == DOSAGE_INDEX) {
                    return eDetailDosage;
                } else if (indexPath.row == ROUTE_INDEX) {
                    return eDetailRoute;
                } else {
                    return eDetailType;
                }
            }
        }
        break;
        case eFourthSection: {
            if (!showWarnings) {
                return eDetailAdministrationTime;
            }
            break;
        }
        default:
            break;
    }
    return 0;
}

- (void)collapseOpenedPickerCell {
    
    //close inline pickers if any present in table cell
    if (_datePickerIndexPath) {
        NSIndexPath *previousPickerIndexPath = [NSIndexPath indexPathForItem:_datePickerIndexPath.row - 1
                                                                   inSection:_datePickerIndexPath.section];
        [self displayInlineDatePickerForRowAtIndexPath:previousPickerIndexPath];
    }
}

- (void)scrollToInstructionsCellPosition {
    
    //scroll table view to instructions cell position
    [medicationDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)resignKeyboard {
    
    //resign keyboard
    DCInstructionsTableCell *instructionsCell = [self getInstructionsTableCell];
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
                DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                [instructionsCell.instructionsTextView becomeFirstResponder];
            }
            break;
        case eThirdSection: {
            if (showWarnings) { // If Warnings section is shown, third section present instruction text view keyboard,, otherwise load date and time detail section
                DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:indexPath];
                [instructionsCell.instructionsTextView becomeFirstResponder];
            } else {
                [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
            }
        }
            break;
        case eFourthSection:
            [self loadDetailViewForDateAndTimeCellOnSelectionAtIndexPath:indexPath];
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
        [self displayDetailViewForRegularMedicationAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:lastSection]];
    }
}

- (void)displayDetailViewForRegularMedicationAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_datePickerIndexPath) { // If inline datepicker is not shown
        if (!self.selectedMedication.noEndDate) { //has end date
            if (indexPath.row == ADMINISTRATING_TIME_ROW_INDEX) { // if last row is selected, show administartion times detail view
                [self presentAdministrationTimeView];
            } else if (indexPath.row != NO_END_DATE_ROW_INDEX) { // disable section of no end date cell, show inline date pickers on other cell selection
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
         } else {
             if (indexPath.row == START_DATE_ROW_INDEX + 2) { // If 
                 [self presentAdministrationTimeView];
             } else if (indexPath.row != NO_END_DATE_ROW_INDEX) {
                 [self displayInlineDatePickerForRowAtIndexPath:indexPath];
             }
         }
    } else {
        if (_datePickerIndexPath.row == DATE_PICKER_INDEX_START_DATE) {
            if (indexPath.row == DATE_PICKER_INDEX_START_DATE + 3) {
                [self presentAdministrationTimeView];
            } else if (indexPath.row != DATE_PICKER_INDEX_START_DATE + 1) {
                //skip no end date cell
                [self displayInlineDatePickerForRowAtIndexPath:indexPath];
            }
        } else {
            if (indexPath.row == DATE_PICKER_INDEX_END_DATE + 1) {
                [self presentAdministrationTimeView];
            } else if (indexPath.row != NO_END_DATE_ROW_INDEX) {
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
        NSLog(@"value is %@", value);
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
    self.selectedMedication.noEndDate = YES;
    self.selectedMedication.timeArray = [NSMutableArray arrayWithArray:@[]];
}

- (void)callAddMedicationWebService {

    //On adding a medication the details of the added medication is passed to the server, when the method fails it shows an alert, while successful addition of data dismisses the add medication popover.
    DCAddMedicationWebServiceManager *webServiceManager = [[DCAddMedicationWebServiceManager alloc] init];
    NSDictionary *medicationDictionary = [webServiceManager getMedicationDetailsDictionaryForMedicationDetail:self.selectedMedication];
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

- (UITableViewCell *)getDateSectionTableViewCellAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *cellID = ([self indexPathHasPicker:indexPath]) ? kDatePickerID : kDateCellID;
    cell = [medicationDetailsTableView dequeueReusableCellWithIdentifier:cellID];
    if ([cellID isEqualToString:kDateCellID]){
        DCDateTableViewCell *dateCell = [self getUpdatedDateAndTimeCellatIndexPath:indexPath];
        return dateCell;
    } else if ([cellID isEqualToString:kDatePickerID]){
        DCDatePickerCell *pickerCell = [self getDatePickerTableCell];
        pickerCell.isStartDate = (indexPath.row == 1) ? YES : NO;
        __weak DCDatePickerCell *weakPickerCell = pickerCell;
        pickerCell.selectedDate = ^ (NSDate *date) {
            NSIndexPath *indexPathToUpdate = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            DCDateTableViewCell *dateCell = [self getUpdatedDateAndTimeCellatIndexPath:indexPathToUpdate];
            NSDate *dateInCurrentZone = [DCDateUtility getDateInCurrentTimeZone:date];
            NSString *dateString = [DCDateUtility convertDate:dateInCurrentZone FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
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

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionCount = [self numberOfSectionsInMedicationTableView];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rowCount = [self numberOfRowsInMedicationTableViewSection:section];
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case eZerothSection: { // zeroth section will always have medicine name field
            UITableViewCell *cell = [self getPopulatedMedicationNameTableCell];
            return cell;
        }
        break;
        case eFirstSection: { // first section will have warnings or medication details based on warnings section display
            if (!showWarnings) {
                if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    DCDosageMultiLineCell *dosageCell = [self getDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCAddMedicationContentCell *contentCell = [self getPopulatedAddMedicationCellForIndexPath:indexPath forIndex:MEDICATION_DETAILS_CELL_INDEX];
                    return contentCell;
                }
            } else {
                DCAddMedicationContentCell *contentCell = [self getPopulatedAddMedicationCellForIndexPath:indexPath forIndex:WARNINGS_CELL_INDEX];
                return contentCell;
            }
        }
        break;
        case eSecondSection: {
            if (showWarnings) {
                if (indexPath.row == DOSAGE_INDEX && self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    DCDosageMultiLineCell *dosageCell = [self getDosageCellAtIndexPath:indexPath];
                    return dosageCell;
                } else {
                    DCAddMedicationContentCell *contentCell = [self getPopulatedAddMedicationCellForIndexPath:indexPath forIndex:MEDICATION_DETAILS_CELL_INDEX];
                    return contentCell;
                }
            } else {
                DCInstructionsTableCell *instructionsCell = [self getInstructionsTableCell];
                return instructionsCell;
            }
        }
        break;
        case eThirdSection: {
            if (showWarnings) {
                DCInstructionsTableCell *instructionsCell = [self getInstructionsTableCell];
                return instructionsCell;
            } else {
                UITableViewCell *dateCell = [self getDateSectionTableViewCellAtIndexPath:indexPath];
                return dateCell;
            }
        }
        break;
        case eFourthSection: {
            UITableViewCell *dateCell = [self getDateSectionTableViewCellAtIndexPath:indexPath];
            return dateCell;
            }
        break;
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
            nameHeight = [DCAddMedicationHelper getHeightForMedicineName:self.selectedMedication.name];
            nameHeight = (nameHeight < TABLE_CELL_DEFAULT_ROW_HEIGHT) ? TABLE_CELL_DEFAULT_ROW_HEIGHT : nameHeight;
        }
        return nameHeight;
    } else if (indexPath.section == eFirstSection){
        if (!showWarnings) {
            if (indexPath.row == DOSAGE_INDEX) {
                // calculate the height for the given text
                if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                    CGSize textSize = [DCUtility getTextViewSizeWithText:self.selectedMedication.dosage maxWidth:258 font:[UIFont systemFontOfSize:15]];
                    return textSize.height + 40; // padding size of 40
                }
            }
        }
    } else if (indexPath.section == eSecondSection){
        if (showWarnings) {
                if (indexPath.row == DOSAGE_INDEX) {
                    // calculate the height for the given text
                    if (self.selectedMedication.dosage.length > MAXIMUM_CHARACTERS_INCLUDED_IN_ONE_LINE) {
                        CGSize textSize = [DCUtility getTextViewSizeWithText:self.selectedMedication.dosage maxWidth:258 font:[UIFont systemFontOfSize:15]];
                        return textSize.height + 40; // padding size of 40
                    }
                }else {
                    return TABLE_CELL_DEFAULT_ROW_HEIGHT;
                }
        } else {
            return INSTRUCTIONS_ROW_HEIGHT;
        }
    } else if (indexPath.section == eThirdSection){
        if (showWarnings) {
            return INSTRUCTIONS_ROW_HEIGHT;
        } else {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        }
    } if (indexPath.section == eFourthSection) {
        if (showWarnings) {
            return ([self indexPathHasPicker:indexPath] ? PICKER_VIEW_CELL_HEIGHT : medicationDetailsTableView.rowHeight);
        }
    }
    return TABLE_CELL_DEFAULT_ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_isEditMedication) {
        if (self.selectedMedication.hasWarning) {
            lastSection = eFourthSection;
        } else {
            lastSection = eThirdSection;
        }
    }

    //shrink already opened date picker cell
    [self resignKeyboard];
    if ((indexPath.section != _datePickerIndexPath.section)) {
         [self collapseOpenedPickerCell];
    } else {
        //date and time section, check for the administarting time row and collapse any
        //picker if opened for Regular medication
        if (([self.selectedMedication.medicineCategory isEqualToString:REGULAR_MEDICATION]  || [self.selectedMedication.medicineCategory isEqualToString:WHEN_REQUIRED_VALUE]) &&
            indexPath.row == [self numberOfRowsInMedicationTableViewSection:lastSection] - 1) {
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
//                NSDate *dateInCurrentZone = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
//                NSString *dateString = [DCDateUtility convertDate:dateInCurrentZone FromFormat:DEFAULT_DATE_FORMAT ToFormat:@"d-MMM-yyyy HH:mm"];
//                self.selectedMedication.startDate = dateString;
//                [self callDeleteMedicationWebServicewithCallBackHandler:^(NSError *error) {
//                    if (!error) {
//                        [self callAddMedicationWebService];
//                    } else {
//                        [self displayAlertWithTitle:@"ERROR" message:@"Edit medication failed"];
//                    }
//                }];
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
    UITableViewCell *checkDatePickerCell = [medicationDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:lastSection]];
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
        [medicationDetailsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:lastSection]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    if (!sameCellClicked) {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:lastSection];
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:lastSection];
    }
    // always deselect the row containing the start or end date
    [medicationDetailsTableView deselectRowAtIndexPath:indexPath animated:YES];
    [medicationDetailsTableView endUpdates];
}

- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    [medicationDetailsTableView beginUpdates];
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:lastSection]];
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

- (void)scrollTableViewToInstructionsCell {
    
    //scroll to instruction cell after delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToInstructionsCellPosition];
    });
}

- (void)configureInstructionForMedication {

    NSIndexPath *instructionIndexPath;
    if (showWarnings) {
        instructionIndexPath = [NSIndexPath indexPathForRow:0 inSection:eThirdSection];
    } else {
        instructionIndexPath = [NSIndexPath indexPathForRow:0 inSection:eSecondSection];
    }
    DCInstructionsTableCell *instructionsCell = (DCInstructionsTableCell *)[medicationDetailsTableView cellForRowAtIndexPath:instructionIndexPath];
    if (![instructionsCell.instructionsTextView.text isEqualToString:INSTRUCTIONS]) {
        self.selectedMedication.instruction = instructionsCell.instructionsTextView.text;
    }
}

- (NSMutableArray *)getTimesArrayFromScheduleArray:(NSArray *)scheduleArray {
    
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    for (NSString *time in scheduleArray) {
        NSString *dateString = [DCUtility convertTimeToHourMinuteFormat:time];
        NSDictionary *dict = @{@"time" : dateString, @"selected" : @1};
        [timeArray addObject:dict];
    }
    return timeArray;
}

#pragma mark - UIPopOverPresentationCOntroller Delegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    
    //this method restricts the pop over dismiss on tapping pop over background. 
    return NO;
}

@end
